import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../../controller/admin/shopee_controller.dart';
import '../../../../../model/orderOnline/shopee_order_model.dart';
import 'order_shopee_event.dart';
import 'order_shopee_state.dart';

class ShopeeOrdersBloc extends Bloc<ShopeeOrdersEvent, ShopeeOrdersState> {
  final ShopeeController _controller = ShopeeController();
  String currentStatus = "READY_TO_SHIP"; // default toggle

  ShopeeOrdersBloc() : super(ShopeeOrdersInitial()) {
    on<FetchShopeeOrders>(_onFetchOrders);
    on<ChangeShopeeOrderStatus>(_onChangeStatus);
    on<PrintShopeeResi>(_onPrintResi);
  }

  Future<void> _onChangeStatus(
      ChangeShopeeOrderStatus event, Emitter<ShopeeOrdersState> emit) async {
    print("=== ChangeShopeeOrderStatus event received ===");
    print("Old status: $currentStatus");
    print("New status: ${event.status}");

    currentStatus = event.status;

    print("Current status after change: $currentStatus");

    add(FetchShopeeOrders(isRefresh: true)); // reload sesuai toggle
  }

  Future<void> _onFetchOrders(
      FetchShopeeOrders event, Emitter<ShopeeOrdersState> emit) async {
    print("=== FetchShopeeOrders event ===");
    print("CurrentStatus: $currentStatus");
    emit(ShopeeOrdersLoading());
    try {
      List<ShopeeOrder> orders = [];

      if (currentStatus == "READY_TO_SHIP") {
        print("Fetching READY_TO_SHIP orders...");
        orders = await _controller.fetchShopeeOrders();
      } else if (currentStatus == "PROCESSED") {
        print("Fetching PROCESSED orders...");
        orders = await _controller.getShippedOrders();
      }

      print("Fetched ${orders.length} orders");
      emit(ShopeeOrdersLoaded(
        orders: orders,
        hasMore: orders.length >= 10,
        isRefreshing: event.isRefresh,
      ));
    } catch (e) {
      print("Error fetching orders: $e");
      emit(ShopeeOrdersError(e.toString()));
    }
  }

  /// 🧾 Cetak resi Shopee dan buka file PDF-nya
  Future<void> _onPrintResi(
      PrintShopeeResi event, Emitter<ShopeeOrdersState> emit) async {
    final orderSn = event.orderSn;
    emit(ShopeeOrdersPrintingResi(orderSn));

    try {
      print("📦 Request print resi Shopee untuk order_sn: $orderSn");

      final url = Uri.parse('${ShopeeController.baseUrl}/print-resi');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"order_sn": orderSn}),
      );

      if (response.statusCode == 200 &&
          response.headers['content-type'] == 'application/pdf') {
        print("✅ Resi PDF diterima dari server");

        final Uint8List bytes = response.bodyBytes;
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/resi_$orderSn.pdf');
        await file.writeAsBytes(bytes);

        print("📄 File resi disimpan di: ${file.path}");
        await OpenFilex.open(file.path);

        emit(ShopeeOrdersResiPrinted(file.path));
      } else {
        print("❌ Gagal menerima PDF: ${response.body}");
        emit(ShopeeOrdersError(
            "Gagal print resi (${response.statusCode}) - ${response.body}"));
      }
    } catch (e) {
      print("❌ Error printShopeeResi: $e");
      emit(ShopeeOrdersError("Error print resi: $e"));
    }
  }
}
