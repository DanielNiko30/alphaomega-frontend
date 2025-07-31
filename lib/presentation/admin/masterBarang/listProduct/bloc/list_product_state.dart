import 'package:equatable/equatable.dart';
import '../../../../../model/product/product_model.dart';

abstract class ListProductState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// State saat data produk sedang dimuat
class ProductLoading extends ListProductState {}

/// State ketika data produk berhasil dimuat
class ProductLoaded extends ListProductState {
  final List<Product> products;

  ProductLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

/// State jika terjadi error saat mengambil data produk
class ProductError extends ListProductState {
  final String message;

  ProductError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State saat proses konversi stok sedang berlangsung
class KonversiStokLoading extends ListProductState {}

/// State ketika konversi stok berhasil dilakukan
class KonversiStokSuccess extends ListProductState {
  final String message;

  KonversiStokSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// State jika proses konversi stok gagal
class KonversiStokFailed extends ListProductState {
  final String message;

  KonversiStokFailed(this.message);

  @override
  List<Object?> get props => [message];
}
