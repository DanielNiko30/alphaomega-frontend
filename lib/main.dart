import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:frontend/presentation/admin/laporan/laporanPenjualan/bloc/laporan_penjualan_bloc.dart';
import 'package:frontend/presentation/admin/laporan/laporanPenjualan/ui/laporan_penjualan_screen.dart';
import 'package:frontend/presentation/admin/laporan/laporanStok/bloc/laporan_stok_bloc.dart';
import 'package:frontend/presentation/admin/laporan/laporanStok/ui/laporan_stok_screen.dart';
import 'package:frontend/presentation/admin/masterTransaksi/historiTransaksiBeli/ui/histori_trans_beli_screen.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'controller/admin/laporan_controller.dart';
import 'controller/user/user_controller.dart';
import 'controller/admin/product_controller.dart';
import 'presentation/admin/laporan/laporanPembelian/bloc/laporan_pembelian_bloc.dart';
import 'presentation/admin/laporan/laporanPembelian/bloc/laporan_pembelian_event.dart';
import 'presentation/admin/laporan/laporanPembelian/ui/laporan_pembelian_screen.dart';
import 'presentation/admin/masterPesanan/detailOrderLazada/bloc/detail_order_lazada_bloc.dart';
import 'presentation/admin/masterPesanan/detailOrderLazada/bloc/detail_order_lazada_event.dart';
import 'presentation/admin/masterPesanan/detailOrderLazada/ui/detail_order_lazada_screen.dart'
    show LazadaOrderDetailPage;
import 'presentation/admin/masterPesanan/detailOrderShopee/bloc/detail_order_shopee_bloc.dart';
import 'presentation/admin/masterPesanan/detailOrderShopee/bloc/detail_order_shopee_event.dart';
import 'presentation/admin/masterPesanan/detailOrderShopee/ui/detail_order_shopee_screen.dart';
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
final AudioPlayer audioPlayer = AudioPlayer();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  final audioPlayer = AudioPlayer();

// Inisialisasi OneSignal
  OneSignal.initialize('257845e8-86e4-466e-b8cb-df95a1005a5f');

// Foreground notifications
// ✅ App sedang terbuka → tampil + bunyi
  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    final notification = event.notification;

    showSimpleNotification(
      Text(notification.title ?? "Notifikasi Baru"),
      subtitle: Text(notification.body ?? ""),
      background: Colors.blueAccent,
    );

    // mainkan suara custom
    audioPlayer.play(AssetSource('sounds/cashier.mp3'));

    // tampilkan system notification juga
    event.notification.display();
  });

// ✅ Klik notifikasi (background / terminated)
  OneSignal.Notifications.addClickListener((event) {
    final data = event.notification.additionalData;

    navigatorKey.currentState?.pushNamed(
      '/detailPesanan',
      arguments: {
        'idPesanan': data?['idPesanan'],
        'namaPembeli': data?['namaPembeli'],
      },
    );
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
      child: MaterialApp(
        title: 'AlphaOmega',
        navigatorKey: navigatorKey,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/chooseRole': (context) => const ChooseRoleScreen(),
          "/listPesanan": (context) => BlocProvider(
                create: (_) => TransJualPendingBloc(),
                child: const ListBarangPesananScreen(),
              ),
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
            final routeArgs = ModalRoute.of(context)?.settings.arguments;

            String? idPesanan;
            String? namaPembeli;

            if (routeArgs != null && routeArgs is Map<String, dynamic>) {
              idPesanan = routeArgs['idPesanan'] as String?;
              namaPembeli = routeArgs['namaPembeli'] as String?;
            }

            if (idPesanan == null || idPesanan.isEmpty) {
              return Scaffold(
                appBar: AppBar(title: const Text("Detail Pesanan")),
                body: const Center(
                  child: Text("Error: ID Pesanan tidak ditemukan"),
                ),
              );
            }

            return BlocProvider(
              create: (context) => DetailPesananBloc(idPesanan: idPesanan!)
                ..add(LoadDetailPesanan(idPesanan!)),
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
          '/shopeeOrderDetail': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map?;
            final orderSn = args?['orderSn'] as String?;

            if (orderSn == null || orderSn.isEmpty) {
              return Scaffold(
                appBar: AppBar(title: const Text("Shopee Order Detail")),
                body: const Center(
                    child: Text("Error: Order SN tidak ditemukan")),
              );
            }

            return BlocProvider(
              create: (context) =>
                  ShopeeOrderDetailBloc()..add(FetchShopeeOrderDetail(orderSn)),
              child: ShopeeOrderDetailPage(orderSn: orderSn),
            );
          },
          '/lazadaOrders': (context) => BlocProvider(
                create: (context) =>
                    LazadaOrdersBloc()..add(FetchLazadaOrders()),
                child: const LazadaOrdersScreen(),
              ),

          // ✅ Route baru: Lazada Order Detail
          '/lazadaOrderDetail': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map?;
            final orderId = args?['orderId'] as String?;

            if (orderId == null || orderId.isEmpty) {
              return Scaffold(
                appBar: AppBar(title: const Text("Lazada Order Detail")),
                body: const Center(
                    child: Text("Error: Order ID tidak ditemukan")),
              );
            }

            return BlocProvider(
              create: (context) =>
                  LazadaOrderDetailBloc()..add(FetchLazadaOrderDetail(orderId)),
              child: LazadaOrderDetailPage(orderId: orderId),
            );
          },

          '/laporanPembelian': (context) => BlocProvider(
                create: (_) => LaporanPembelianBloc(LaporanController()),
                child: const LaporanPembelianScreen(),
              ),
          '/historiPembelian': (context) => const LaporanBeliScreen(),
          '/laporanPenjualan': (context) => BlocProvider(
                create: (_) => LaporanPenjualanBloc(LaporanController()),
                child: const LaporanPenjualanScreen(),
              ),
          '/laporanStok': (context) => BlocProvider(
                create: (_) => LaporanStokBloc(LaporanController()),
                child: const LaporanStokScreen(),
              ),
        },
        home: const LoginScreen(),
      ),
    );
  }
}
