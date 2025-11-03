import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../../controller/admin/lazada_controller.dart';
import '../../../../../model/product/lazada_model.dart';
import 'order_lazada_event.dart';
import 'order_lazada_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LazadaOrdersBloc extends Bloc<LazadaOrdersEvent, LazadaOrdersState> {
  final LazadaController _controller = LazadaController();
  String currentStatus = "PENDING";

  LazadaOrdersBloc() : super(LazadaOrdersInitial()) {
    on<FetchLazadaOrders>(_onFetchOrders);
    on<ChangeLazadaOrderStatus>(_onChangeStatus);
    on<SetLazadaReadyToShip>(_onReadyToShip);
    on<PrintLazadaResi>(_onPrintResi);
  }

  Future<void> _onChangeStatus(
      ChangeLazadaOrderStatus event, Emitter<LazadaOrdersState> emit) async {
    currentStatus = event.status;
    add(FetchLazadaOrders(isRefresh: true));
  }

  Future<void> _onFetchOrders(
      FetchLazadaOrders event, Emitter<LazadaOrdersState> emit) async {
    emit(LazadaOrdersLoading());
    try {
      List<LazadaOrder> orders = [];

      if (currentStatus == "PENDING") {
        orders = await _controller.getPendingOrders();
      } else if (currentStatus == "READY_TO_SHIP") {
        orders = await _controller.getReadyToShipOrders();
      }

      emit(LazadaOrdersLoaded(
        orders: orders,
        hasMore: orders.length >= 10,
        isRefreshing: event.isRefresh,
      ));
    } catch (e) {
      emit(LazadaOrdersError(e.toString()));
    }
  }

  Future<void> _onReadyToShip(
      SetLazadaReadyToShip event, Emitter<LazadaOrdersState> emit) async {
    try {
      final res = await _controller.readyToShipLazada(event.orderId);

      if (res["success"] == true) {
        emit(LazadaOrdersSuccess(
            res["message"] ?? "Pesanan berhasil diatur ke Ready To Ship"));
        add(FetchLazadaOrders(isRefresh: true)); // 🔄 Refresh order list
      } else {
        emit(LazadaOrdersError(
            res["message"] ?? "Gagal mengatur Ready To Ship"));
      }
    } catch (e) {
      emit(LazadaOrdersError("Gagal request Ready To Ship: $e"));
    }
  }

  Future<void> _onPrintResi(
    PrintLazadaResi event,
    Emitter<LazadaOrdersState> emit,
  ) async {
    final currentState = state;
    if (currentState is! LazadaOrdersLoaded) return;

    try {
      final pdfBase64 = await _controller.printResiLazada(event.orderId);

      if (pdfBase64 == null || pdfBase64.isEmpty) {
        throw Exception("PDF kosong");
      }

      // 🔹 tetap emit state lama agar list orders tidak hilang
      emit(currentState);

      // 🔹 Trigger popup via listener
      // Gunakan addPostFrameCallback di UI untuk memunculkan popup
      eventCallback?.call(pdfBase64, event.orderId);
    } catch (e) {
      emit(LazadaOrdersError("Gagal ambil resi: $e"));
    }
  }

// 🔹 Tambahkan callback opsional agar UI bisa listen popup
  void Function(String pdfBase64, String orderId)? eventCallback;
}
