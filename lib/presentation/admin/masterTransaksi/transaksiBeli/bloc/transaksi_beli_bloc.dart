import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/model/transaksiBeli/dtrans_beli_model.dart';
import 'package:frontend/model/transaksiBeli/htrans_beli_model.dart';
import '../../../../../controller/admin/product_controller.dart';
import '../../../../../controller/admin/trans_beli_controller.dart';
import '../../../../../controller/supplier/supplier_controller.dart';
import 'transaksi_beli_event.dart';
import 'transaksi_beli_state.dart';

class TransBeliBloc extends Bloc<TransBeliEvent, TransBeliState> {
  TransBeliBloc() : super(TransBeliLoading()) {
    on<FetchSuppliers>(_onFetchSuppliers);
    on<FetchProducts>(_onFetchProducts);
    on<SelectSupplier>(_onSelectSupplier);
    on<AddProduct>(_onAddProduct);
    on<RemoveProduct>(_onRemoveProduct);
    on<UpdateProductQuantity>(_onUpdateProductQuantity);
    on<UpdateProductPrice>(_onUpdateProductPrice);
    on<SelectPaymentMethod>(_onSelectPaymentMethod);
    on<SubmitTransaction>(_onSubmitTransaction);
    on<FetchSatuanByProductId>(_onFetchSatuanByProductId);
    on<UpdateProductUnit>(_onUpdateProductUnit);
    on<SearchProductByName>(_onSearchProductByName);
    on<UpdateProductDiscount>(_onUpdateProductDiscount);
    on<UpdateInvoiceNumber>(_onUpdateInvoiceNumber);
    on<UpdatePajak>(_onUpdatePajak);
  }

  void _onSubmitTransaction(
      SubmitTransaction event, Emitter<TransBeliState> emit) async {
    if (state is TransBeliLoaded) {
      final currentState = state as TransBeliLoaded;

      // ✅ Validasi form SEBELUM emit loading
      final Map<String, String> errors = {};

      if (currentState.nomorInvoice == null) {
        errors['invoice'] = 'Nomor invoice wajib diisi';
      }

      if (currentState.paymentMethod == null) {
        errors['paymentMethod'] = 'Metode pembayaran wajib dipilih';
      }

      if (currentState.selectedSupplier == null) {
        errors['supplier'] = 'Supplier wajib dipilih';
      }

      if (currentState.selectedProducts.isEmpty) {
        errors['products'] = 'Minimal 1 produk harus dipilih';
      }

      if (currentState.selectedProducts.isEmpty) {
        errors['product'] = 'Minimal 1 produk harus dipilih';
      } else {
        for (var product in currentState.selectedProducts) {
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

      // ❗ Jangan submit kalau ada error
      if (errors.isNotEmpty) {
        emit(currentState.copyWith(formErrors: errors));
        return;
      }

      // ✅ Setelah lolos validasi → boleh emit loading
      emit(TransBeliLoading());

      try {
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

        final int subTotal = detailTransaksi.fold(
          0,
          (sum, item) => sum + item.subtotal,
        );

        final newTransaction = HTransBeli(
          idSupplier: currentState.selectedSupplier ?? "",
          tanggal: DateTime.now().toIso8601String(),
          totalHarga: subTotal,
          metodePembayaran: currentState.paymentMethod ?? "Cash",
          nomorInvoice: currentState.nomorInvoice ??
              "INV-${DateTime.now().millisecondsSinceEpoch}",
          ppn: currentState.pajak,
          detail: detailTransaksi,
        );

        final response =
            await TransaksiBeliController.createTransaction(newTransaction);

        if (response.statusCode != 201) {
          emit(TransBeliError(
              "Gagal mengirim transaksi: ${response.statusMessage}"));
        } else {
          emit(TransBeliInitial());
        }
      } catch (e) {
        emit(TransBeliError("Error submitting transaction: $e"));
      }
    }
  }

  void _onSearchProductByName(
      SearchProductByName event, Emitter<TransBeliState> emit) async {
    if (state is TransBeliLoaded) {
      final currentState = state as TransBeliLoaded;
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
      FetchSuppliers event, Emitter<TransBeliState> emit) async {
    try {
      final suppliers = await SupplierController.getAllSuppliers();
      final supplierList = suppliers
          .map((s) => {
                'id': s.idSupplier,
                'name': s.namaSupplier,
              })
          .toList();

      if (state is TransBeliLoaded) {
        final currentState = state as TransBeliLoaded;
        emit(currentState.copyWith(suppliers: supplierList));
      } else {
        emit(TransBeliLoaded(suppliers: supplierList));
      }
    } catch (e) {
      emit(TransBeliError("Error fetching suppliers: $e"));
    }
  }

  void _onFetchProducts(
      FetchProducts event, Emitter<TransBeliState> emit) async {
    try {
      final products = await ProductController.getAllProducts();
      final productList = products
          .map((p) => {
                'id': p.idProduct?.toString() ?? '',
                'name': p.namaProduct?.toString() ?? '',
                'image': p.gambarProduct?.toString() ?? '',
              })
          .toList();

      if (state is TransBeliLoaded) {
        final currentState = state as TransBeliLoaded;
        emit(currentState.copyWith(
          products: productList,
          allProducts: productList,
        ));
      } else {
        emit(TransBeliLoaded(
          products: productList,
          allProducts: productList,
        ));
      }
    } catch (e) {
      emit(TransBeliError("Error fetching products: $e"));
    }
  }

  void _onSelectSupplier(SelectSupplier event, Emitter<TransBeliState> emit) {
    if (state is TransBeliLoaded) {
      final currentState = state as TransBeliLoaded;
      emit(currentState.copyWith(selectedSupplier: event.supplierId));
    }
  }

  void _onAddProduct(AddProduct event, Emitter<TransBeliState> emit) async {
    if (state is TransBeliLoaded) {
      final currentState = state as TransBeliLoaded;
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

  void _onRemoveProduct(RemoveProduct event, Emitter<TransBeliState> emit) {
    if (state is TransBeliLoaded) {
      final currentState = state as TransBeliLoaded;
      final updatedProducts =
          List<Map<String, dynamic>>.from(currentState.selectedProducts)
            ..removeWhere((p) => p['id'] == event.id);

      emit(currentState.copyWith(selectedProducts: updatedProducts));
    }
  }

  void _onUpdateProductQuantity(
      UpdateProductQuantity event, Emitter<TransBeliState> emit) {
    if (state is TransBeliLoaded) {
      final currentState = state as TransBeliLoaded;
      final updatedProducts = currentState.selectedProducts.map((p) {
        if (p['id'] == event.id) return {...p, 'quantity': event.quantity};
        return p;
      }).toList();

      emit(currentState.copyWith(selectedProducts: updatedProducts));
    }
  }

  void _onUpdateProductPrice(
      UpdateProductPrice event, Emitter<TransBeliState> emit) {
    if (state is TransBeliLoaded) {
      final currentState = state as TransBeliLoaded;
      final updatedProducts = currentState.selectedProducts.map((p) {
        if (p['id'] == event.id) return {...p, 'price': event.price};
        return p;
      }).toList();

      emit(currentState.copyWith(selectedProducts: updatedProducts));
    }
  }

  void _onSelectPaymentMethod(
      SelectPaymentMethod event, Emitter<TransBeliState> emit) {
    if (state is TransBeliLoaded) {
      final currentState = state as TransBeliLoaded;
      emit(currentState.copyWith(paymentMethod: event.method));
    }
  }

  void _onFetchSatuanByProductId(
      FetchSatuanByProductId event, Emitter<TransBeliState> emit) async {
    if (state is TransBeliLoaded) {
      final currentState = state as TransBeliLoaded;
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
      UpdateProductUnit event, Emitter<TransBeliState> emit) {
    if (state is TransBeliLoaded) {
      final currentState = state as TransBeliLoaded;

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
      UpdateProductDiscount event, Emitter<TransBeliState> emit) {
    if (state is TransBeliLoaded) {
      final currentState = state as TransBeliLoaded;

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
      UpdateInvoiceNumber event, Emitter<TransBeliState> emit) {
    if (state is TransBeliLoaded) {
      final currentState = state as TransBeliLoaded;
      emit(currentState.copyWith(nomorInvoice: event.nomorInvoice));
    }
  }

  void _onUpdatePajak(UpdatePajak event, Emitter<TransBeliState> emit) {
    if (state is TransBeliLoaded) {
      final currentState = state as TransBeliLoaded;
      emit(currentState.copyWith(pajak: event.pajak));
    }
  }

  void _onValidateTransactionForm(
    ValidateTransactionForm event,
    Emitter<TransBeliState> emit,
  ) {
    if (state is TransBeliLoaded) {
      final current = state as TransBeliLoaded;
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
