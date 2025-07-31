import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/controller/admin/product_controller.dart';
import 'package:frontend/controller/admin/trans_jual_controller.dart';
import 'package:frontend/controller/user/user_controller.dart';
import 'package:frontend/model/transaksiJual/dtrans_jual_model.dart';
import 'package:frontend/model/transaksiJual/htrans_jual_model.dart';
import 'package:intl/intl.dart';
import '../../../../model/product/edit_productView_model.dart';
import 'edit_transaksi_jual_event.dart';
import 'edit_transaksi_jual_state.dart';

class TransJualEditBloc extends Bloc<TransJualEditEvent, TransJualEditState> {
  TransJualEditBloc() : super(TransJualEditLoading()) {
    on<LoadTransactionForEdit>(_onLoadTransactionForEdit);
    on<AddProductEdit>(_onAddProductEdit);
    on<RemoveProductEdit>(_onRemoveProductEdit);
    on<UpdateProductQuantityEdit>(_onUpdateProductQuantityEdit);
    on<UpdateProductPriceEdit>(_onUpdateProductPriceEdit);
    on<UpdateProductUnitEdit>(_onUpdateProductUnitEdit);
    on<FetchSatuanByProductIdEdit>(_onFetchSatuanByProductIdEdit);
    on<SelectUserEdit>(_onSelectUserEdit);
    on<SelectUserPenjualEdit>(_onSelectUserPenjualEdit);
    on<UpdateNamaPembeliEdit>(_onUpdateNamaPembeliEdit);
    on<SelectPaymentMethodEdit>(_onSelectPaymentMethodEdit);
    on<FetchAllUsersEdit>(_onFetchAllUsersEdit);
    on<SearchProductByNameEdit>(_onSearchProductByNameEdit);
    on<SubmitEditTransaction>(_onSubmitEditTransaction);
  }

  /// Load transaksi untuk prefill halaman edit
  Future<void> _onLoadTransactionForEdit(
      LoadTransactionForEdit event, Emitter<TransJualEditState> emit) async {
    emit(TransJualEditLoading());
    try {
      // Ambil transaksi detail
      final transaksi =
          await TransaksiJualController.getTransactionById(event.transactionId);

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

      // Mapping selectedProducts dari DTransJual
      final selectedProducts = await Future.wait(
        transaksi.detail.map((d) async {
          // Fetch produk berdasarkan idProduk
          final product = await ProductController.getProductById(d.idProduk);

          // Fetch stok (satuan + jumlah) produk
          final stokList =
              await ProductController.getSatuanByProductId(d.idProduk);

// Ambil stok default sesuai satuan di transaksi
          final stokDetail = stokList.isNotEmpty
              ? stokList.firstWhere(
                  (s) => s.satuan == d.satuan,
                  orElse: () => Stok(
                    satuan: d.satuan,
                    harga: d.hargaSatuan,
                    jumlah: 0,
                    stok:
                        '', // tambahkan param stok kosong karena konstruktor minta
                  ),
                )
              : Stok(
                  satuan: d.satuan,
                  harga: d.hargaSatuan,
                  jumlah: 0,
                  stok: '',
                );

          return {
            'id': d.idProduk,
            'name': product.namaProduct,
            'image': product.gambarProduct ?? '',
            'quantity': d.jumlahBarang,
            'unit': d.satuan,
            'price': d.hargaSatuan,
            'stok': stokDetail.jumlah, // stok real dari tabel stok
            'unitList': stokList.map((s) => s.satuan).toList(),
            'unitListDetail': stokList
                .map((s) => {
                      'satuan': s.satuan,
                      'harga': s.harga,
                      'stock': s.jumlah,
                    })
                .toList(),
          };
        }).toList(),
      );

      emit(TransJualEditLoaded(
        idHTransJual: transaksi.idHTransJual,
        products: productList,
        allProducts: productList,
        selectedProducts: selectedProducts,
        paymentMethod: transaksi.metodePembayaran,
        selectedUserId: transaksi.idUser,
        selectedUserPenjualId: transaksi.idUserPenjual,
        userList: userList,
        invoiceNumber: transaksi.nomorInvoice,
        namaPembeli: transaksi.namaPembeli,
        tanggal: transaksi.tanggal,
      ));
    } catch (e) {
      emit(TransJualEditError("Gagal load transaksi: $e"));
    }
  }

  void _onAddProductEdit(
      AddProductEdit event, Emitter<TransJualEditState> emit) {
    if (state is TransJualEditLoaded) {
      final current = state as TransJualEditLoaded;
      final updatedProducts =
          List<Map<String, dynamic>>.from(current.selectedProducts);

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
          'stok': event.stok,
          'unitList': [],
          'unitListDetail': [],
        });
        emit(current.copyWith(selectedProducts: updatedProducts));
        add(FetchSatuanByProductIdEdit(event.id));
      } else {
        updatedProducts[existingIndex]['quantity'] += event.quantity;
        emit(current.copyWith(selectedProducts: updatedProducts));
      }
    }
  }

  void _onRemoveProductEdit(
      RemoveProductEdit event, Emitter<TransJualEditState> emit) {
    if (state is TransJualEditLoaded) {
      final current = state as TransJualEditLoaded;
      final updated = List<Map<String, dynamic>>.from(current.selectedProducts)
        ..removeWhere((p) => p['id'] == event.id);
      emit(current.copyWith(selectedProducts: updated));
    }
  }

  void _onUpdateProductQuantityEdit(
      UpdateProductQuantityEdit event, Emitter<TransJualEditState> emit) {
    if (state is TransJualEditLoaded) {
      final current = state as TransJualEditLoaded;
      final updatedProducts = current.selectedProducts.map((p) {
        if (p['id'] == event.id) return {...p, 'quantity': event.quantity};
        return p;
      }).toList();
      emit(current.copyWith(selectedProducts: updatedProducts));
    }
  }

  void _onUpdateProductPriceEdit(
      UpdateProductPriceEdit event, Emitter<TransJualEditState> emit) {
    if (state is TransJualEditLoaded) {
      final current = state as TransJualEditLoaded;
      final updatedProducts = current.selectedProducts.map((p) {
        if (p['id'] == event.id) return {...p, 'price': event.price};
        return p;
      }).toList();
      emit(current.copyWith(selectedProducts: updatedProducts));
    }
  }

  void _onUpdateProductUnitEdit(
      UpdateProductUnitEdit event, Emitter<TransJualEditState> emit) {
    if (state is TransJualEditLoaded) {
      final current = state as TransJualEditLoaded;
      final updatedProducts = current.selectedProducts.map((p) {
        if (p['id'] == event.productId) {
          final satuanDetail = (p['unitListDetail'] ?? []).firstWhere(
            (s) => s['satuan'] == event.unit,
            orElse: () => {'harga': 0, 'stock': 0},
          );

          return {
            ...p,
            'unit': event.unit,
            'price': satuanDetail['harga'] ?? 0,
            'stok': satuanDetail['stock'] ?? 0,
          };
        }
        return p;
      }).toList();

      emit(current.copyWith(selectedProducts: updatedProducts));
    }
  }

  Future<void> _onFetchSatuanByProductIdEdit(FetchSatuanByProductIdEdit event,
      Emitter<TransJualEditState> emit) async {
    if (state is TransJualEditLoaded) {
      final current = state as TransJualEditLoaded;
      try {
        final satuanList =
            await ProductController.getSatuanByProductId(event.productId);

        final updatedProducts = current.selectedProducts.map((p) {
          if (p['id'] == event.productId) {
            return {
              ...p,
              'unitList': satuanList.map((s) => s.satuan).toList(),
              'unitListDetail': satuanList
                  .map((s) => {
                        'satuan': s.satuan,
                        'harga': s.harga,
                        'stock': s.jumlah,
                      })
                  .toList(),
              'unit': satuanList.first.satuan,
              'price': satuanList.first.harga,
              'stok': satuanList.first.jumlah,
            };
          }
          return p;
        }).toList();

        emit(current.copyWith(selectedProducts: updatedProducts));
      } catch (e) {
        print("Error fetch satuan edit: $e");
      }
    }
  }

  void _onSelectUserEdit(
      SelectUserEdit event, Emitter<TransJualEditState> emit) {
    if (state is TransJualEditLoaded) {
      final current = state as TransJualEditLoaded;
      emit(current.copyWith(selectedUserId: event.userId));
    }
  }

  void _onSelectUserPenjualEdit(
      SelectUserPenjualEdit event, Emitter<TransJualEditState> emit) {
    if (state is TransJualEditLoaded) {
      final current = state as TransJualEditLoaded;
      emit(current.copyWith(selectedUserPenjualId: event.userId));
    }
  }

  void _onUpdateNamaPembeliEdit(
      UpdateNamaPembeliEdit event, Emitter<TransJualEditState> emit) {
    if (state is TransJualEditLoaded) {
      final current = state as TransJualEditLoaded;
      emit(current.copyWith(namaPembeli: event.name));
    }
  }

  void _onSelectPaymentMethodEdit(
      SelectPaymentMethodEdit event, Emitter<TransJualEditState> emit) {
    if (state is TransJualEditLoaded) {
      final current = state as TransJualEditLoaded;
      emit(current.copyWith(paymentMethod: event.method));
    }
  }

  Future<void> _onFetchAllUsersEdit(
      FetchAllUsersEdit event, Emitter<TransJualEditState> emit) async {
    if (state is TransJualEditLoaded) {
      final current = state as TransJualEditLoaded;
      try {
        final users = await UserController().fetchUsers();
        final userList = users
            .map((u) => {
                  'id': u.idUser,
                  'name': u.name,
                })
            .toList();

        emit(current.copyWith(userList: userList));
      } catch (e) {
        emit(TransJualEditError("Gagal fetch user: $e"));
      }
    }
  }

  void _onSearchProductByNameEdit(
      SearchProductByNameEdit event, Emitter<TransJualEditState> emit) {
    if (state is TransJualEditLoaded) {
      final current = state as TransJualEditLoaded;
      final filtered = current.allProducts.where((p) {
        final name = (p['name'] ?? '').toLowerCase();
        return name.contains(event.query.toLowerCase());
      }).toList();
      emit(current.copyWith(products: filtered));
    }
  }

  Future<void> _onSubmitEditTransaction(
    SubmitEditTransaction event,
    Emitter<TransJualEditState> emit,
  ) async {
    if (state is TransJualEditLoaded) {
      final current = state as TransJualEditLoaded;

      try {
        // Cek jika tidak ada produk yang dipilih
        if (current.selectedProducts.isEmpty) {
          emit(TransJualEditError("Tidak ada produk yang dipilih."));
          return;
        }

        // Set loading
        emit(current.copyWith(isSubmitting: true));

        // Hitung total harga
        final totalHarga = current.selectedProducts.fold<int>(
          0,
          (sum, item) =>
              sum +
              ((item['quantity'] as int) * (item['price'] as num).toInt()),
        );

        // Format tanggal ke yyyy-MM-dd
        String formatTanggal(DateTime tanggal) {
          return DateFormat('yyyy-MM-dd').format(tanggal);
        }

        // Buat detail transaksi
        final detailTransaksi = current.selectedProducts.map((item) {
          return DTransJual(
            idProduk: item['id'],
            jumlahBarang: item['quantity'],
            hargaSatuan: item['price'],
            subtotal: (item['quantity'] * item['price']).toInt(),
            satuan: item['unit'],
          );
        }).toList();

        // Buat objek transaksi
        final hTransJual = HTransJual(
          idUser: current.selectedUserId ?? '',
          idUserPenjual: current.selectedUserPenjualId ?? '',
          namaPembeli: current.namaPembeli ?? '',
          tanggal: formatTanggal(
            current.tanggal is DateTime
                ? current.tanggal as DateTime
                : DateTime.parse(current.tanggal.toString()),
          ),
          totalHarga: totalHarga,
          metodePembayaran: current.paymentMethod ?? "Cash",
          nomorInvoice: current.invoiceNumber ?? '',
          status: "Pending",
          detail: detailTransaksi,
        );

        // Kirim ke backend (PUT)
        final response = await TransaksiJualController.updateTransaction(
          current.idHTransJual!,
          hTransJual,
        );

        if (response.statusCode == 200) {
          // Emit success → UI navigate balik
          emit(TransJualEditSuccess());

          // Reset state biar clean kalau buka lagi
          emit(TransJualEditLoaded());
        } else {
          emit(TransJualEditError(
              "Gagal update transaksi: ${response.statusMessage}"));
        }
      } catch (e) {
        emit(TransJualEditError("Error submit edit transaksi: $e"));
      }
    }
  }
}
