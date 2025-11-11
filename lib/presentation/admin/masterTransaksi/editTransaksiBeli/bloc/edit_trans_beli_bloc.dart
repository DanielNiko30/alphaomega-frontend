import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/model/transaksiBeli/dtrans_beli_model.dart';
import 'package:frontend/model/transaksiBeli/htrans_beli_model.dart';
import '../../../../../controller/admin/product_controller.dart';
import '../../../../../controller/admin/trans_beli_controller.dart';
import '../../../../../controller/supplier/supplier_controller.dart';
import '../../../../../model/product/edit_productView_model.dart';
import 'edit_trans_beli_event.dart';
import 'edit_trans_beli_state.dart';

class EditTransBeliBloc extends Bloc<EditTransBeliEvent, EditTransBeliState> {
  EditTransBeliBloc() : super(TransBeliLoading()) {
    on<FetchSuppliers>(_onFetchSuppliers);
    on<FetchProducts>(_onFetchProducts);
    on<SelectSupplier>(_onSelectSupplier);
    on<AddProduct>(_onAddProduct);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<RemoveProduct>(_onRemoveProduct);
    on<UpdateProductQuantity>(_onUpdateProductQuantity);
    on<UpdateProductPrice>(_onUpdateProductPrice);
    on<SelectPaymentMethod>(_onSelectPaymentMethod);
    on<FetchSatuanByProductId>(_onFetchSatuanByProductId);
    on<UpdateProductUnit>(_onUpdateProductUnit);
    on<SearchProductByName>(_onSearchProductByName);
    on<UpdateProductDiscount>(_onUpdateProductDiscount);
    on<UpdateInvoiceNumber>(_onUpdateInvoiceNumber);
    on<UpdatePajak>(_onUpdatePajak);
    on<FetchTransactionById>(_onFetchTransactionById);
  }

  Future<void> _onUpdateTransaction(
      UpdateTransaction event, Emitter<EditTransBeliState> emit) async {
    if (state is EditTransBeliLoaded) {
      final currentState = state as EditTransBeliLoaded;

      // ✅ Validasi form SEBELUM submit
      final Map<String, String> errors = {};

      if (currentState.nomorInvoice == null ||
          currentState.nomorInvoice!.isEmpty) {
        errors['invoice'] = 'Nomor invoice wajib diisi';
      }

      if (currentState.paymentMethod == null ||
          currentState.paymentMethod!.isEmpty) {
        errors['paymentMethod'] = 'Metode pembayaran wajib dipilih';
      }

      if (currentState.selectedSupplier == null ||
          currentState.selectedSupplier!.isEmpty) {
        errors['supplier'] = 'Supplier wajib dipilih';
      }

      if (currentState.selectedProducts.isEmpty) {
        errors['products'] = 'Minimal 1 produk harus dipilih';
      }

      if (errors.isNotEmpty) {
        emit(currentState.copyWith(formErrors: errors));
        return;
      }

      emit(TransBeliLoading());

      try {
        // 🔹 Mapping data detail
        final List<DTransBeli> detailTransaksi =
            currentState.selectedProducts.map((product) {
          final int price = product['price']?.toInt() ?? 0;
          final int qty = product['quantity'] ?? 1;
          final int discount = product['discount'] ?? 0;

          final int subtotal = ((price * qty) * (1 - discount / 100)).toInt();

          return DTransBeli(
            idProduk: product['id'],
            jumlahBarang: qty,
            satuan: product['unit'],
            subtotal: subtotal,
            diskonBarang: discount,
            hargaSatuan: price,
          );
        }).toList();

        // 🔹 Hitung total
        final int totalHarga = detailTransaksi.fold(
          0,
          (sum, item) => sum + item.subtotal,
        );

        // 🔹 Buat object transaksi baru
        final updatedTransaction = HTransBeli(
          idHTransBeli: currentState.idHtransBeli, // wajib diisi
          idSupplier: currentState.selectedSupplier ?? '',
          tanggal: DateTime.now().toIso8601String(),
          totalHarga: totalHarga,
          metodePembayaran: currentState.paymentMethod ?? 'Cash',
          nomorInvoice: currentState.nomorInvoice ?? '',
          ppn: currentState.pajak,
          detail: detailTransaksi,
        );

        // 🔹 Panggil API update
        final response = await TransaksiBeliController.updateTransaction(
          id: event.id,
          transaction: updatedTransaction,
        );

        if (response.statusCode == 200) {
          // ✅ Emit success
          emit(UpdateTransactionSuccess());

          // 🔹 Navigasi ke halaman historiPembelian
          // Gunakan navigator key atau context
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(event.context)
                .pushReplacementNamed('/historiPembelian');
          });
        } else {
          emit(TransBeliError(
              "Gagal update transaksi: ${response.statusMessage}"));
        }
      } catch (e, stack) {
        print("❌ Error saat update transaksi: $e");
        print(stack);
        emit(TransBeliError("Error update transaksi: $e"));
      }
    }
  }

  Future<void> _onFetchTransactionById(
      FetchTransactionById event, Emitter<EditTransBeliState> emit) async {
    //emit(EditTransBeliLoading());
    try {
      // 🔹 1. Ambil transaksi lengkap dari API
      final transaksi =
          await TransaksiBeliController.getTransactionById(event.transactionId);

      // 🔹 2. Ambil semua produk
      final products = await ProductController.getAllProducts();
      final productList = products
          .map((p) => {
                'id': p.idProduct,
                'name': p.namaProduct,
                'image': p.gambarProduct,
              })
          .toList();

      // 🔹 3. Ambil semua supplier
      final suppliers = await SupplierController.getAllSuppliers();
      final supplierList = suppliers
          .map((s) => {
                'id': s.idSupplier,
                'name': s.namaSupplier,
              })
          .toList();

      // 🔹 4. Mapping detail transaksi ke format selectedProducts
      final selectedProducts = await Future.wait(
        transaksi.detail.map((d) async {
          final product = await ProductController.getProductById(d.idProduk);

          final satuanList =
              await ProductController.getSatuanByProductId(d.idProduk);

          final satuanDetail = satuanList.isNotEmpty
              ? satuanList.firstWhere(
                  (s) => s.satuan == (d.satuan ?? ''),
                  orElse: () => Stok(
                    satuan: d.satuan ?? '',
                    harga: d.hargaSatuan ?? 0,
                    jumlah: 0,
                    stok: '',
                  ),
                )
              : Stok(
                  satuan: d.satuan ?? '',
                  harga: d.hargaSatuan ?? 0,
                  jumlah: 0,
                  stok: '',
                );

          return {
            'id': d.idProduk ?? '',
            'name': product.namaProduct ?? '',
            'image': product.gambarProduct ?? '',
            'quantity': d.jumlahBarang ?? 1,
            'unit': d.satuan ?? satuanDetail.satuan,
            'price': d.hargaSatuan?.toDouble() ?? 0.0,
            'discount': (d.diskonBarang ?? 0).toDouble(),
            'unitList': satuanList.map((s) => s.satuan ?? '').toList(),
            'unitListDetail': satuanList
                .map((s) => {
                      'satuan': s.satuan ?? '',
                      'harga': s.harga ?? 0,
                      'stock': s.jumlah ?? 0,
                    })
                .toList(),
          };
        }).toList(),
      );

      // 🔹 5. Emit state Loaded
      emit(EditTransBeliLoaded(
        idHtransBeli: transaksi.idHTransBeli ?? '',
        suppliers: supplierList,
        selectedSupplier: transaksi.idSupplier ?? '',
        paymentMethod: transaksi.metodePembayaran ?? 'Cash',
        nomorInvoice: transaksi.nomorInvoice ?? '',
        pajak: transaksi.ppn,
        selectedProducts: selectedProducts,
        allProducts: productList,
        products: productList,
      ));
    } catch (e, stack) {
      print("❌ Error FetchTransactionById: $e");
      print(stack);
      //emit(EditTransBeliError("Gagal load transaksi: $e"));
    }
  }

  void _onSearchProductByName(
      SearchProductByName event, Emitter<EditTransBeliState> emit) async {
    if (state is EditTransBeliLoaded) {
      final currentState = state as EditTransBeliLoaded;
      final query = event.query.trim().toLowerCase();

      try {
        List<Map<String, dynamic>> filteredProducts;
        if (query.isEmpty) {
          filteredProducts = currentState.allProducts;
        } else {
          filteredProducts = currentState.allProducts.where((p) {
            final name = (p['name'] ?? '').toString().toLowerCase();
            return name.contains(query);
          }).toList();
        }

        emit(currentState.copyWith(
          products: filteredProducts,
          searchQuery: event.query,
        ));
      } catch (e) {
        emit(TransBeliError("Gagal mencari produk: $e"));
      }
    }
  }

  void _onFetchSuppliers(
      FetchSuppliers event, Emitter<EditTransBeliState> emit) async {
    try {
      final suppliers = await SupplierController.getAllSuppliers();
      final supplierList = suppliers
          .map((s) => {
                'id': s.idSupplier,
                'name': s.namaSupplier,
              })
          .toList();

      if (state is EditTransBeliLoaded) {
        final currentState = state as EditTransBeliLoaded;
        emit(currentState.copyWith(suppliers: supplierList));
      } else {
        emit(EditTransBeliLoaded(suppliers: supplierList));
      }
    } catch (e) {
      emit(TransBeliError("Error fetching suppliers: $e"));
    }
  }

  void _onFetchProducts(
      FetchProducts event, Emitter<EditTransBeliState> emit) async {
    try {
      final products = await ProductController.getAllProducts();
      final productList = products
          .map((p) => {
                'id': p.idProduct?.toString() ?? '',
                'name': p.namaProduct?.toString() ?? '',
                'image': p.gambarProduct?.toString() ?? '',
              })
          .toList();

      if (state is EditTransBeliLoaded) {
        final currentState = state as EditTransBeliLoaded;
        emit(currentState.copyWith(
          products: productList,
          allProducts: productList,
        ));
      } else {
        emit(EditTransBeliLoaded(
          products: productList,
          allProducts: productList,
        ));
      }
    } catch (e) {
      emit(TransBeliError("Error fetching products: $e"));
    }
  }

  void _onSelectSupplier(
      SelectSupplier event, Emitter<EditTransBeliState> emit) {
    if (state is EditTransBeliLoaded) {
      final currentState = state as EditTransBeliLoaded;
      emit(currentState.copyWith(selectedSupplier: event.supplierId));
    }
  }

  void _onAddProduct(AddProduct event, Emitter<EditTransBeliState> emit) async {
    if (state is EditTransBeliLoaded) {
      final currentState = state as EditTransBeliLoaded;
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
          'price': 0.0,
          'unitList': [],
          'unitListDetail': [],
        });

        emit(currentState.copyWith(selectedProducts: updatedProducts));
        add(FetchSatuanByProductId(event.id));
      } else {
        updatedProducts[existingIndex]['quantity'] += event.quantity;
        emit(currentState.copyWith(selectedProducts: updatedProducts));
      }
    }
  }

  void _onRemoveProduct(RemoveProduct event, Emitter<EditTransBeliState> emit) {
    if (state is EditTransBeliLoaded) {
      final currentState = state as EditTransBeliLoaded;
      final updatedProducts =
          List<Map<String, dynamic>>.from(currentState.selectedProducts)
            ..removeWhere((p) => p['id'] == event.id);

      emit(currentState.copyWith(selectedProducts: updatedProducts));
    }
  }

  void _onUpdateProductQuantity(
      UpdateProductQuantity event, Emitter<EditTransBeliState> emit) {
    if (state is EditTransBeliLoaded) {
      final currentState = state as EditTransBeliLoaded;
      final updatedProducts = currentState.selectedProducts.map((p) {
        if (p['id'] == event.id) return {...p, 'quantity': event.quantity};
        return p;
      }).toList();

      emit(currentState.copyWith(selectedProducts: updatedProducts));
    }
  }

  void _onUpdateProductPrice(
      UpdateProductPrice event, Emitter<EditTransBeliState> emit) {
    if (state is EditTransBeliLoaded) {
      final currentState = state as EditTransBeliLoaded;
      final updatedProducts = currentState.selectedProducts.map((p) {
        if (p['id'] == event.id) return {...p, 'price': event.price};
        return p;
      }).toList();

      emit(currentState.copyWith(selectedProducts: updatedProducts));
    }
  }

  void _onSelectPaymentMethod(
      SelectPaymentMethod event, Emitter<EditTransBeliState> emit) {
    if (state is EditTransBeliLoaded) {
      final currentState = state as EditTransBeliLoaded;
      emit(currentState.copyWith(paymentMethod: event.method));
    }
  }

  void _onFetchSatuanByProductId(
      FetchSatuanByProductId event, Emitter<EditTransBeliState> emit) async {
    if (state is EditTransBeliLoaded) {
      final currentState = state as EditTransBeliLoaded;
      try {
        final satuanList =
            await ProductController.getSatuanByProductId(event.productId);

        final updatedProducts = currentState.selectedProducts.map((p) {
          if (p['id'] == event.productId) {
            return {
              ...p,
              'unitList': satuanList.map((s) => s.satuan).toList(),
              'unitListDetail': satuanList
                  .map((s) =>
                      {'satuan': s.satuan, 'harga': s.harga, 'stock': s.jumlah})
                  .toList(),
              'unit': satuanList.first.satuan,
              'price': 0.0,
              'stock': satuanList.first.jumlah,
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
      UpdateProductUnit event, Emitter<EditTransBeliState> emit) {
    if (state is EditTransBeliLoaded) {
      final currentState = state as EditTransBeliLoaded;

      final updatedProducts = currentState.selectedProducts.map((p) {
        if (p['id'] == event.productId) {
          final List unitListDetail = p['unitListDetail'] ?? [];

          final satuanDetail = unitListDetail.firstWhere(
            (s) => s['satuan'] == event.unit,
            orElse: () => {'harga': 0, 'stock': 0},
          );

          return {...p, 'unit': event.unit, 'stock': satuanDetail['stock']};
        }
        return p;
      }).toList();

      emit(currentState.copyWith(selectedProducts: updatedProducts));
    }
  }

  void _onUpdateProductDiscount(
      UpdateProductDiscount event, Emitter<EditTransBeliState> emit) {
    if (state is EditTransBeliLoaded) {
      final currentState = state as EditTransBeliLoaded;

      final updatedProducts = currentState.selectedProducts.map((p) {
        if (p['id'] == event.id) {
          return {...p, 'discount': event.discount};
        }
        return p;
      }).toList();

      emit(currentState.copyWith(selectedProducts: updatedProducts));
    }
  }

  void _onUpdateInvoiceNumber(
      UpdateInvoiceNumber event, Emitter<EditTransBeliState> emit) {
    if (state is EditTransBeliLoaded) {
      final currentState = state as EditTransBeliLoaded;
      emit(currentState.copyWith(nomorInvoice: event.nomorInvoice));
    }
  }

  void _onUpdatePajak(UpdatePajak event, Emitter<EditTransBeliState> emit) {
    if (state is EditTransBeliLoaded) {
      final currentState = state as EditTransBeliLoaded;
      emit(currentState.copyWith(pajak: event.pajak));
    }
  }

  void _onValidateTransactionForm(
    ValidateTransactionForm event,
    Emitter<EditTransBeliState> emit,
  ) {
    if (state is EditTransBeliLoaded) {
      final current = state as EditTransBeliLoaded;
      final errors = <String, String>{};

      if (current.selectedSupplier == null ||
          current.selectedSupplier!.isEmpty) {
        errors['supplier'] = 'Supplier wajib dipilih';
      }

      if (current.nomorInvoice == null ||
          current.nomorInvoice!.trim().isEmpty) {
        errors['invoice'] = 'Nomor invoice wajib diisi';
      }

      if (current.paymentMethod == null || current.paymentMethod!.isEmpty) {
        errors['payment'] = 'Metode pembayaran wajib dipilih';
      }

      if (current.selectedProducts.isEmpty) {
        errors['product'] = 'Minimal 1 produk harus dipilih';
      } else {
        for (var product in current.selectedProducts) {
          if (product['quantity'] == null || product['quantity'] <= 0) {
            errors['quantity_${product['id']}'] = 'Jumlah wajib diisi';
          }
          if (product['price'] == null || product['price'] <= 0) {
            errors['price_${product['id']}'] = 'Harga wajib diisi';
          }
          if (product['unit'] == null || product['unit'].toString().isEmpty) {
            errors['unit_${product['id']}'] = 'Satuan wajib dipilih';
          }
        }
      }

      emit(current.copyWith(formErrors: errors));
    }
  }
}
