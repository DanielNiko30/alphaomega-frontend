import 'package:equatable/equatable.dart';
import '../../../../../model/product/product_model.dart';
import '../../../../../model/product/product_with_stok_model.dart';

/// ===== Base State =====
abstract class ListProductState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// State awal sebelum ada aksi apapun
class ProductInitial extends ListProductState {}

/// State saat data produk sedang dimuat
class ProductLoading extends ListProductState {}

/// State ketika data produk berhasil dimuat (tanpa stok)
class ProductLoaded extends ListProductState {
  final List<Product> products;

  ProductLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

/// State ketika data produk dengan stok berhasil dimuat
class ProductWithStokLoaded extends ListProductState {
  final List<ProductWithStok> products;

  ProductWithStokLoaded(this.products);

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

/// ====== KONVERSI STOK ======
class KonversiStokLoading extends ListProductState {}

class KonversiStokSuccess extends ListProductState {
  final String message;

  KonversiStokSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class KonversiStokFailed extends ListProductState {
  final String message;

  KonversiStokFailed(this.message);

  @override
  List<Object?> get props => [message];
}

/// ====== UPDATE PRODUK ======
class UpdateProductLoading extends ListProductState {}

class UpdateProductSuccess extends ListProductState {
  final String message;

  UpdateProductSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class UpdateProductFailed extends ListProductState {
  final String message;

  UpdateProductFailed(this.message);

  @override
  List<Object?> get props => [message];
}
