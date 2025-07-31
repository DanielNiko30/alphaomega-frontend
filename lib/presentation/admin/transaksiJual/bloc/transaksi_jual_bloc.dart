import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/controller/user/user_controller.dart';
import 'package:frontend/model/transaksiBeli/dtrans_beli_model.dart';
import 'package:frontend/model/transaksiBeli/htrans_beli_model.dart';
import 'package:frontend/model/transaksiJual/htrans_jual_model.dart';
import '../../../../controller/admin/product_controller.dart';
import '../../../../controller/admin/trans_beli_controller.dart';
import '../../../../controller/admin/trans_jual_controller.dart';
import '../../../../model/transaksiJual/dtrans_jual_model.dart';
import '../bloc/transaksi_jual_event.dart';
import '../bloc/transaksi_jual_state.dart';

class TransJualBloc extends Bloc<TransJualEvent, TransJualState> {
  TransJualBloc() : super(TransJualLoading()) {
    on<FetchProductsJual>(_onFetchProducts);
    on<AddProduct>(_onAddProduct);
    on<RemoveProduct>(_onRemoveProduct);
    on<UpdateProductQuantity>(_onUpdateProductQuantity);
    on<UpdateProductPrice>(_onUpdateProductPrice);
    on<SelectPaymentMethod>(_onSelectPaymentMethod);
    on<SearchProductByNameJual>(_onSearchProductByNameJual);
    on<SubmitTransaction>(_onSubmitTransaction);
    on<FetchSatuanByProductId>(_onFetchSatuanByProductId);
    on<UpdateProductUnit>(_onUpdateProductUnit);
    on<SelectUser>(_onSelectUser);
    on<FetchAllUsers>(_onFetchAllUsers);
    on<FetchLatestInvoice>(_onFetchLatestInvoice);
    on<InitializeTransJual>(_onInitialize);
    on<SelectUserPenjual>(_onSelectUserPenjual);
    on<UpdateNamaPembeli>(_onUpdateNamaPembeli);
    on<CetakNota>(_onCetakNotaDanPrint);
    on<TogglePrintPreview>(_onTogglePrintPreview);
  }

  void _onSubmitTransaction(
      SubmitTransaction event, Emitter<TransJualState> emit) async {
    if (state is TransJualLoaded) {
      final currentState = state as TransJualLoaded;

      final Map<String, String> errors = {};

      if (currentState.selectedUserId == null) {
        errors['user'] = 'User wajib dipilih';
      }
      if (currentState.selectedUserPenjualId == null) {
        errors['penjual'] = 'Penjual wajib dipilih';
      }
      if (currentState.namaPembeli == null ||
          currentState.namaPembeli!.isEmpty) {
        errors['namaPembeli'] = 'Nama pembeli wajib diisi';
      }
      if (currentState.paymentMethod == null ||
          currentState.paymentMethod!.isEmpty) {
        errors['payment'] = 'Metode pembayaran wajib dipilih';
      }
      if (currentState.selectedProducts.isEmpty) {
        errors['products'] = 'Minimal 1 produk harus dipilih';
      }

      if (errors.isNotEmpty) {
        emit(currentState.copyWith(formErrors: errors, isSubmitting: false));
        return;
      }

      emit(currentState.copyWith(isSubmitting: true, formErrors: null));

      try {
        // ✅ Hitung total harga
        final totalHarga = currentState.selectedProducts.fold<int>(
          0,
          (sum, item) =>
              sum +
              ((item['quantity'] as int) * (item['price'] as num).toInt()),
        );

        // ✅ Buat detail transaksi
        final detailTransaksi = currentState.selectedProducts.map((item) {
          return DTransJual(
            idProduk: item['id'],
            jumlahBarang: item['quantity'],
            hargaSatuan: item['price'],
            subtotal: (item['quantity'] * item['price']).toInt(),
            satuan: item['unit'],
          );
        }).toList();

        // ✅ Ambil nomor invoice
        final invoice = await TransaksiJualController.getLatestInvoiceNumber();

        // ✅ Buat objek transaksi
        final hTransJual = HTransJual(
          idUser: currentState.selectedUserId!,
          idUserPenjual: currentState.selectedUserPenjualId!,
          namaPembeli: currentState.namaPembeli!,
          tanggal: DateTime.now().toIso8601String().split("T").first,
          totalHarga: totalHarga,
          metodePembayaran: currentState.paymentMethod ?? "Cash",
          nomorInvoice: invoice,
          status: "Pending",
          detail: detailTransaksi,
        );

        // ✅ Kirim ke backend
        final response =
            await TransaksiJualController.createTransaction(hTransJual);

        if (response.statusCode == 201) {
          add(InitializeTransJual());
          add(ResetSelectedProducts());
        } else {
          emit(TransJualError(
              "Gagal submit transaksi: ${response.statusMessage}"));
        }
      } catch (e) {
        emit(TransJualError("Error submit transaksi: $e"));
      }
    }
  }

  void _onFetchProducts(
      FetchProductsJual event, Emitter<TransJualState> emit) async {
    try {
      final products = await ProductController.getAllProducts();
      final productList = products
          .map((p) => {
                'id': p.idProduct,
                'name': p.namaProduct,
                'image': p.gambarProduct,
              })
          .toList();

      emit(TransJualLoaded(
        products: productList,
        allProducts: productList,
      ));
    } catch (e) {
      emit(TransJualError("Error fetching products: $e"));
    }
  }

  void _onAddProduct(AddProduct event, Emitter<TransJualState> emit) async {
    if (state is TransJualLoaded) {
      final currentState = state as TransJualLoaded;
      final updatedProducts =
          List<Map<String, dynamic>>.from(currentState.selectedProducts);

      final existingIndex =
          updatedProducts.indexWhere((p) => p['id'] == event.id);
      if (existingIndex == -1) {
        updatedProducts.add({
          'id': event.id,
          'name': event.name,
          'image': event.image,
          'quantity': event.quantity,
          'unit': event.unit,
          'price': event.price,
          'unitList': [],
          'unitListDetail': [],
          'stok': event.stok,
        });

        emit(currentState.copyWith(selectedProducts: updatedProducts));
        add(FetchSatuanByProductId(event.id));
      } else {
        updatedProducts[existingIndex]['quantity'] += event.quantity;
        emit(currentState.copyWith(selectedProducts: updatedProducts));
      }
    }
  }

  void _onRemoveProduct(RemoveProduct event, Emitter<TransJualState> emit) {
    if (state is TransJualLoaded) {
      final currentState = state as TransJualLoaded;
      final updatedProducts =
          List<Map<String, dynamic>>.from(currentState.selectedProducts)
            ..removeWhere((p) => p['id'] == event.id);

      emit(currentState.copyWith(selectedProducts: updatedProducts));
    }
  }

  void _onUpdateProductQuantity(
      UpdateProductQuantity event, Emitter<TransJualState> emit) {
    if (state is TransJualLoaded) {
      final currentState = state as TransJualLoaded;
      final updatedProducts = currentState.selectedProducts.map((p) {
        if (p['id'] == event.id) return {...p, 'quantity': event.quantity};
        return p;
      }).toList();

      emit(currentState.copyWith(selectedProducts: updatedProducts));
    }
  }

  void _onUpdateProductPrice(
      UpdateProductPrice event, Emitter<TransJualState> emit) {
    if (state is TransJualLoaded) {
      final currentState = state as TransJualLoaded;
      final updatedProducts = currentState.selectedProducts.map((p) {
        if (p['id'] == event.id) return {...p, 'price': event.price};
        return p;
      }).toList();

      emit(currentState.copyWith(selectedProducts: updatedProducts));
    }
  }

  void _onSelectPaymentMethod(
      SelectPaymentMethod event, Emitter<TransJualState> emit) {
    if (state is TransJualLoaded) {
      final currentState = state as TransJualLoaded;
      emit(currentState.copyWith(paymentMethod: event.method));
    }
  }

  void _onFetchSatuanByProductId(
      FetchSatuanByProductId event, Emitter<TransJualState> emit) async {
    if (state is TransJualLoaded) {
      final currentState = state as TransJualLoaded;
      try {
        final satuanList =
            await ProductController.getSatuanByProductId(event.productId);

        final updatedProducts = currentState.selectedProducts.map((p) {
          if (p['id'] == event.productId) {
            return {
              ...p,
              'unitList': satuanList.map((s) => s.satuan).toList(),
              'unitListDetail': satuanList
                  .map((s) => {
                        'satuan': s.satuan,
                        'harga': s.harga,
                        'stock': s.jumlah, // Tambahkan stock
                      })
                  .toList(),
              'unit': satuanList.first.satuan,
              'price': satuanList.first.harga,
              'stok': satuanList.first.jumlah, // Tambahkan stok langsung
            };
          }
          return p;
        }).toList();

        emit(currentState.copyWith(selectedProducts: updatedProducts));
      } catch (e) {
        print("Gagal mengambil satuan: $e");
      }
    }
  }

  void _onUpdateProductUnit(
      UpdateProductUnit event, Emitter<TransJualState> emit) {
    if (state is TransJualLoaded) {
      final currentState = state as TransJualLoaded;

      final updatedProducts = currentState.selectedProducts.map((p) {
        if (p['id'] == event.productId) {
          final List unitListDetail = p['unitListDetail'] ?? [];

          final satuanDetail = unitListDetail.firstWhere(
            (s) => s['satuan'] == event.unit,
            orElse: () => {'harga': 0, 'stock': 0},
          );

          return {
            ...p,
            'unit': event.unit,
            'price': satuanDetail['harga'] ?? 0,
            'stok': satuanDetail['stock'] ?? 0, // Tambahkan ini
          };
        }
        return p;
      }).toList();

      emit(currentState.copyWith(selectedProducts: updatedProducts));
    }
  }

  void _onSearchProductByNameJual(
      SearchProductByNameJual event, Emitter<TransJualState> emit) {
    if (state is TransJualLoaded) {
      final currentState = state as TransJualLoaded;

      final filtered = currentState.allProducts.where((product) {
        final name = (product['name'] ?? '').toLowerCase();
        return name.contains(event.query.toLowerCase());
      }).toList();

      emit(currentState.copyWith(products: filtered));
    }
  }

  void _onFetchAllUsers(
      FetchAllUsers event, Emitter<TransJualState> emit) async {
    if (state is TransJualLoaded) {
      final currentState = state as TransJualLoaded;

      try {
        final userController = UserController();
        final users = await userController.fetchUsers();
        final userList = users
            .map((user) => {
                  "id": user.idUser,
                  "name": user.name,
                })
            .toList();

        emit(currentState.copyWith(userList: userList));
      } catch (e) {
        emit(TransJualError("Gagal mengambil user: $e"));
      }
    }
  }

  void _onFetchLatestInvoice(
      FetchLatestInvoice event, Emitter<TransJualState> emit) async {
    if (state is TransJualLoaded) {
      final currentState = state as TransJualLoaded;

      try {
        final invoice = await TransaksiJualController.getLatestInvoiceNumber();

        emit(currentState.copyWith(invoiceNumber: invoice));
      } catch (e) {
        emit(TransJualError("Gagal mengambil nomor invoice: $e"));
      }
    }
  }

  void _onInitialize(
      InitializeTransJual event, Emitter<TransJualState> emit) async {
    emit(TransJualLoading());
    try {
      // Ambil semua produk
      final products = await ProductController.getAllProducts();
      final productList = products
          .map((p) => {
                'id': p.idProduct,
                'name': p.namaProduct,
                'image': p.gambarProduct,
              })
          .toList();

      // Ambil user list
      final users = await UserController().fetchUsers();
      final userList = users
          .map((u) => {
                'id': u.idUser,
                'name': u.name,
              })
          .toList();

      // Ambil invoice terbaru
      final invoice = await TransaksiJualController.getLatestInvoiceNumber();

      // Emit state lengkap
      emit(TransJualLoaded(
        products: productList,
        allProducts: productList,
        userList: userList,
        invoiceNumber: invoice,
      ));
    } catch (e) {
      emit(TransJualError("Gagal inisialisasi transaksi: $e"));
    }
  }

  void _onSelectUser(SelectUser event, Emitter<TransJualState> emit) {
    if (state is TransJualLoaded) {
      final currentState = state as TransJualLoaded;
      emit(currentState.copyWith(selectedUserId: event.userId));
    }
  }

  void _onSelectUserPenjual(
      SelectUserPenjual event, Emitter<TransJualState> emit) {
    if (state is TransJualLoaded) {
      final current = state as TransJualLoaded;
      emit(current.copyWith(selectedUserPenjualId: event.userId));
    }
  }

  void _onUpdateNamaPembeli(
      UpdateNamaPembeli event, Emitter<TransJualState> emit) {
    if (state is TransJualLoaded) {
      final current = state as TransJualLoaded;
      emit(current.copyWith(namaPembeli: event.name));
    }
  }

  void _onResetSelectedProducts(
      ResetSelectedProducts event, Emitter<TransJualState> emit) {
    if (state is TransJualLoaded) {
      final currentState = state as TransJualLoaded;
      emit(currentState.copyWith(selectedProducts: []));
    }
  }

  void _onTogglePrintPreview(
      TogglePrintPreview event, Emitter<TransJualState> emit) {
    if (state is TransJualLoaded) {
      final currentState = state as TransJualLoaded;
      emit(currentState.copyWith(
        isPrintPreview: !currentState.isPrintPreview,
      ));
    }
  }

  void _onCetakNotaDanPrint(CetakNota event, Emitter<TransJualState> emit) {
    if (state is TransJualLoaded) {
      final currentState = state as TransJualLoaded;

      // Validasi: jika tidak ada produk yang dipilih, abaikan
      if (currentState.selectedProducts.isEmpty) {
        return;
      }

      // Jika sedang di mode preview, maka ini adalah aksi print
      if (currentState.isPrintPreview) {
        // TODO: Tambahkan logika panggil ke printer thermal nanti
        print("Mencetak nota ke printer thermal...");

        // Setelah print selesai, keluar dari print preview
        emit(currentState.copyWith(isPrintPreview: false));
      } else {
        // Masuk ke mode print preview
        emit(currentState.copyWith(isPrintPreview: true));
      }
    }
  }
}
