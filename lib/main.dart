import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'controller/admin/laporan_controller.dart';
import 'controller/user/user_controller.dart';
import 'controller/admin/product_controller.dart';
import 'presentation/admin/laporan/laporanPembelian/bloc/laporan_pembelian_bloc.dart';
import 'presentation/admin/laporan/laporanPembelian/bloc/laporan_pembelian_event.dart';
import 'presentation/admin/laporan/laporanPembelian/ui/laporan_pembelian_screen.dart';
import 'presentation/admin/masterPesanan/orderLazada/bloc/order_lazada_bloc.dart';
import 'presentation/admin/masterPesanan/orderShopee/bloc/order_shopee_bloc.dart';
import 'presentation/admin/masterPesanan/orderShopee/bloc/order_shopee_event.dart';
import 'presentation/admin/masterPesanan/orderShopee/ui/order_shopee_screen.dart';
import 'presentation/admin/masterPesanan/orderLazada/bloc/order_lazada_event.dart';
import 'presentation/admin/masterPesanan/orderLazada/ui/order_lazada_screen.dart';
import 'presentation/admin/masterTransaksi/transaksiJualPending/bloc/transaksi_jual_pending_bloc.dart';
import 'presentation/admin/masterTransaksi/transaksiJualPending/bloc/transaksi_jual_pending_event.dart';
import 'presentation/admin/masterTransaksi/transaksiJualPending/ui/transaksi_jual_pending_screen.dart';
import 'presentation/pegawaiGudang/detailPesanan/bloc/detail_pesanan_bloc.dart';
import 'presentation/pegawaiGudang/detailPesanan/bloc/detail_pesanan_event.dart';
import 'presentation/pegawaiGudang/detailPesanan/ui/detail_pesanan_screen.dart';
import 'presentation/pegawaiGudang/listBarangPesanan/ui/list_barang_pesanan_screen.dart';
import 'presentation/admin/masterTransaksi/editTransaksiJual/bloc/edit_transaksi_jual_bloc.dart';
import 'presentation/admin/masterTransaksi/editTransaksiJual/bloc/edit_transaksi_jual_event.dart';
import 'presentation/admin/masterTransaksi/editTransaksiJual/ui/edit_transaksi_jual_screen.dart';
import 'presentation/admin/masterBarang/addKategori/bloc/add_kategori_event.dart';
import 'presentation/admin/masterBarang/editProduct/bloc/edit_product_bloc.dart';
import 'presentation/admin/masterBarang/editProduct/bloc/edit_product_event.dart';
import 'presentation/admin/masterBarang/editProduct/ui/edit_product_screen.dart';
import 'presentation/admin/masterTransaksi/transaksiBeli/ui/transaksi_beli_screen.dart';
import 'presentation/admin/masterSupplier/ui/add_supplier_screen.dart';
import 'presentation/admin/masterTransaksi/transaksiBeli/bloc/transaksi_beli_bloc.dart';
import 'presentation/admin/masterTransaksi/transaksiBeli/bloc/transaksi_beli_event.dart';
import 'presentation/admin/masterTransaksi/transaksiJual/bloc/transaksi_jual_bloc.dart';
import 'presentation/admin/masterTransaksi/transaksiJual/bloc/transaksi_jual_event.dart';
import 'presentation/admin/masterTransaksi/transaksiJual/ui/transaksi_jual_screen.dart';
import 'presentation/login/login_screen.dart';
import 'presentation/admin/dashboard/ui/dashboard_screen.dart';
import 'presentation/admin/masterUser/listUser/ui/master_user_screen.dart';
import 'presentation/admin/masterUser/listUser/bloc/master_user_bloc.dart';
import 'presentation/admin/masterUser/addUser/bloc/add_user_bloc.dart';
import 'presentation/admin/masterBarang/addProduct/bloc/add_product_bloc.dart';
import 'presentation/admin/masterBarang/listProduct/bloc/list_product_bloc.dart';
import 'presentation/admin/masterBarang/listProduct/bloc/list_product_event.dart'
    as listProductEvent;
import 'presentation/admin/masterBarang/listProduct/ui/list_product_screen.dart';
import 'presentation/admin/masterBarang/addProduct/ui/add_product_screen.dart';
import 'presentation/admin/masterBarang/addKategori/ui/add_kategori_screen.dart';
import 'presentation/login/choose_role_screen.dart';

/// ✅ Tambahkan navigatorKey global untuk popup notifikasi
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // ✅ Inisialisasi OneSignal
  OneSignal.initialize('257845e8-86e4-466e-b8cb-df95a1005a5f');

  // ✅ Minta izin tampilkan notifikasi
  OneSignal.Notifications.requestPermission(true);

  // ✅ Listener: kalau notifikasi diterima saat app terbuka (foreground)
  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    event.preventDefault(); // kita handle tampilannya sendiri

    final notif = event.notification;
    debugPrint("📢 Notif diterima: ${notif.title}");

    showSimpleNotification(
      Container(
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.85), // 💙 biru transparan
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(6),
              child:
                  const Icon(Icons.notifications_active, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.title ?? 'Notifikasi Baru',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    notif.body ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      background: Colors
          .transparent, // supaya background transparan (biar container tampil)
      autoDismiss: true,
      duration: const Duration(seconds: 5),
      slideDismissDirection: DismissDirection.up,
    );
  });

  // ✅ Listener: kalau user klik notifikasi
  OneSignal.Notifications.addClickListener((event) {
    debugPrint('🔔 Notifikasi diklik: ${event.notification.title}');
  });

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => MasterUserBloc(UserController())),
        BlocProvider(create: (context) => AddUserBloc(UserController())),
        BlocProvider(create: (context) => AddProductBloc(ProductController())),
        BlocProvider(
          create: (context) => TransBeliBloc()
            ..add(FetchSuppliers())
            ..add(FetchProducts()),
        ),
        BlocProvider(
          create: (context) =>
              TransJualPendingBloc()..add(FetchTransJualPendingEvent()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      // ✅ Tambahkan overlay di sini
      child: MaterialApp(
        title: 'Flutter Demo',
        navigatorKey: navigatorKey,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/chooseRole': (context) => const ChooseRoleScreen(),
          '/listPesanan': (context) => const ListBarangPesananScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/masterUser': (context) => const MasterUserScreen(),
          '/masterBarang': (context) => BlocProvider(
                create: (context) =>
                    ListProductBloc()..add(listProductEvent.FetchProducts()),
                child: const ListProductScreen(),
              ),
          '/masterSupplier': (context) => const AddSupplierScreen(),
          '/addProduct': (context) => const AddProductScreen(),
          '/kategoriProduk': (context) => const AddKategoriScreen(),
          '/transaksiPembelian': (context) => BlocProvider(
                create: (context) => TransBeliBloc()
                  ..add(FetchSuppliers())
                  ..add(FetchProducts()),
                child: TransBeliScreen(),
              ),
          '/transaksiPenjualan': (context) => BlocProvider(
                create: (context) => TransJualBloc()..add(FetchProductsJual()),
                child: TransJualScreen(),
              ),
          '/transaksiPenjualanPending': (context) =>
              const TransJualPendingScreen(),
          '/editProduct': (context) {
            final idProduct =
                ModalRoute.of(context)?.settings.arguments as String?;

            if (idProduct == null || idProduct.isEmpty) {
              return Scaffold(
                appBar: AppBar(title: const Text("Edit Produk")),
                body: const Center(
                    child: Text("Error: ID Produk tidak ditemukan")),
              );
            }

            return BlocProvider(
              create: (context) {
                final productRepository = ProductController();
                final bloc =
                    EditProductBloc(productRepository: productRepository);
                Future.microtask(() => bloc.add(LoadProduct(idProduct)));
                return bloc;
              },
              child: EditProductScreen(productId: idProduct),
            );
          },
          '/editTransaksiJual': (context) {
            final idTransaksi =
                ModalRoute.of(context)?.settings.arguments as String?;

            if (idTransaksi == null || idTransaksi.isEmpty) {
              return Scaffold(
                appBar: AppBar(title: const Text("Edit Transaksi Penjualan")),
                body: const Center(
                    child: Text("Error: ID Transaksi tidak ditemukan")),
              );
            }

            return BlocProvider(
              create: (context) =>
                  TransJualEditBloc()..add(LoadTransactionForEdit(idTransaksi)),
              child: TransJualEditScreen(transactionId: idTransaksi),
            );
          },
          '/detailPesanan': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map?;
            final idPesanan = args?['idPesanan'] as String?;
            final namaPembeli = args?['namaPembeli'] as String?;

            if (idPesanan == null) {
              return Scaffold(
                appBar: AppBar(title: const Text("Detail Pesanan")),
                body: const Center(
                    child: Text("Error: ID Pesanan tidak ditemukan")),
              );
            }

            return BlocProvider(
              create: (context) =>
                  DetailPesananBloc()..add(LoadDetailPesanan(idPesanan)),
              child: DetailPesananScreen(
                idPesanan: idPesanan,
                namaPembeli: namaPembeli ?? "",
              ),
            );
          },
          '/shopeeOrders': (context) => BlocProvider(
                create: (context) =>
                    ShopeeOrdersBloc()..add(FetchShopeeOrders()),
                child: const ShopeeOrdersScreen(),
              ),
          '/lazadaOrders': (context) => BlocProvider(
                create: (context) =>
                    LazadaOrdersBloc()..add(FetchLazadaOrders()),
                child: const LazadaOrdersScreen(),
              ),
          '/laporanPembelian': (context) => BlocProvider(
                create: (_) => LaporanPembelianBloc(LaporanController()),
                child: const LaporanPembelianScreen(),
              ),
        },
        home: const LoginScreen(),
      ),
    );
  }
}
