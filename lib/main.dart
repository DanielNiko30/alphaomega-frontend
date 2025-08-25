import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/presentation/admin/editTransaksiJual/bloc/edit_transaksi_jual_bloc.dart';
import 'package:frontend/presentation/admin/editTransaksiJual/bloc/edit_transaksi_jual_event.dart';
import 'package:frontend/presentation/admin/editTransaksiJual/ui/edit_transaksi_jual_screen.dart';
import 'package:frontend/presentation/admin/masterBarang/addKategori/bloc/add_kategori_event.dart';
import 'package:frontend/presentation/admin/masterBarang/editProduct/bloc/edit_product_bloc.dart';
import 'package:frontend/presentation/admin/masterBarang/editProduct/bloc/edit_product_event.dart';
import 'package:frontend/presentation/admin/masterBarang/editProduct/ui/edit_product_screen.dart';
import 'package:frontend/presentation/admin/transaksiBeli/ui/transaksi_beli_screen.dart';
import 'package:frontend/presentation/admin/masterSupplier/ui/add_supplier_screen.dart';
import 'package:frontend/presentation/admin/transaksiBeli/bloc/transaksi_beli_bloc.dart';
import 'package:frontend/presentation/admin/transaksiBeli/bloc/transaksi_beli_event.dart';
import 'package:frontend/presentation/admin/transaksiJual/bloc/transaksi_jual_bloc.dart';
import 'package:frontend/presentation/admin/transaksiJual/bloc/transaksi_jual_event.dart';
import 'package:frontend/presentation/admin/transaksiJual/ui/transaksi_jual_screen.dart';
import 'package:frontend/presentation/login/login_screen.dart';
import 'package:frontend/presentation/admin/dashboard/ui/dashboard_screen.dart';
import 'package:frontend/presentation/admin/masterUser/listUser/ui/master_user_screen.dart';
import 'package:frontend/presentation/admin/masterUser/listUser/bloc/master_user_bloc.dart';
import 'package:frontend/presentation/admin/masterUser/addUser/bloc/add_user_bloc.dart';
import 'package:frontend/presentation/admin/masterBarang/addProduct/bloc/add_product_bloc.dart';
import 'package:frontend/presentation/admin/masterBarang/listProduct/bloc/list_product_bloc.dart';
import 'package:frontend/presentation/admin/masterBarang/listProduct/bloc/list_product_event.dart'
    as listProductEvent;
import 'package:frontend/presentation/admin/masterBarang/listProduct/ui/list_product_screen.dart';
import 'package:frontend/presentation/admin/masterBarang/addProduct/ui/add_product_screen.dart';
import 'package:frontend/presentation/admin/masterBarang/addKategori/ui/add_kategori_screen.dart';

import 'controller/user/user_controller.dart';
import 'controller/admin/product_controller.dart';
import 'presentation/admin/transaksiJualPending/bloc/transaksi_jual_pending_bloc.dart';
import 'presentation/admin/transaksiJualPending/bloc/transaksi_jual_pending_event.dart';
import 'presentation/admin/transaksiJualPending/ui/transaksi_jual_pending_screen.dart';
import 'presentation/login/choose_role_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
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
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/chooseRole': (context) => const ChooseRoleScreen(),
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
              body:
                  const Center(child: Text("Error: ID Produk tidak ditemukan")),
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
      },
      home: const LoginScreen(),
    );
  }
}
