import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../widget/sidebar.dart';
import '../bloc/laporan_pembelian_bloc.dart';
import '../bloc/laporan_pembelian_event.dart';
import '../bloc/laporan_pembelian_state.dart';
import '../../../../../model/laporan/laporan_model.dart';
import '../../../../../utils/generate_report_pdf.dart'; // file generate PDF updated

class LaporanPembelianScreen extends StatefulWidget {
  const LaporanPembelianScreen({super.key});

  @override
  State<LaporanPembelianScreen> createState() => _LaporanPembelianScreenState();
}

class _LaporanPembelianScreenState extends State<LaporanPembelianScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _mode = 'periode';
  final _dateFormat = DateFormat('dd MMM yyyy');
  final _currencyFormat = NumberFormat('#,###', 'id_ID');

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final initialDate =
        isStart ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: isStart ? 'Pilih Tanggal Awal' : 'Pilih Tanggal Akhir',
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _loadReport() {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal awal dan akhir dulu bro')),
      );
      return;
    }

    context.read<LaporanPembelianBloc>().add(
          LoadLaporanPembelian(
            startDate: _startDate!,
            endDate: _endDate!,
            mode: _mode,
          ),
        );
  }

  Future<void> _saveAsPdf(List<dynamic> data, String mode) async {
    String title = 'Laporan Pembelian';
    String type = mode == 'produk'
        ? 'per_produk'
        : mode == 'periode'
            ? 'per_periode'
            : 'detail';

    await generateReportPdf(
      context: context,
      reportTitle: title,
      reportType: type,
      data: data,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: isDesktop ? 100 : 0,
              top: 48,
              right: 24,
              bottom: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Laporan Pembelian",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                _buildFilterCard(),
                const SizedBox(height: 20),
                Expanded(
                  child:
                      BlocBuilder<LaporanPembelianBloc, LaporanPembelianState>(
                    builder: (context, state) {
                      if (state is LaporanPembelianLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is LaporanPembelianError) {
                        return Center(
                          child: Text(
                            '❌ ${state.message}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      } else if (state is LaporanPembelianLoaded) {
                        return Column(
                          children: [
                            Expanded(child: _buildReportList(state)),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.picture_as_pdf),
                                label: const Text('Simpan sebagai PDF'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () =>
                                    _saveAsPdf(state.data, state.mode),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return const Center(
                          child: Text(
                            '📅 Pilih tanggal awal & akhir untuk melihat laporan',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          if (isDesktop)
            const Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Sidebar(),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _mode,
              decoration: const InputDecoration(
                labelText: 'Jenis Laporan',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'periode', child: Text('Per Periode')),
                DropdownMenuItem(value: 'produk', child: Text('Per Produk')),
                DropdownMenuItem(
                    value: 'detail', child: Text('Detail Transaksi')),
              ],
              onChanged: (val) => setState(() => _mode = val!),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _pickDate(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Awal',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _startDate != null
                            ? _dateFormat.format(_startDate!)
                            : 'Pilih tanggal',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => _pickDate(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Akhir',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _endDate != null
                            ? _dateFormat.format(_endDate!)
                            : 'Pilih tanggal',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.search),
                label: const Text('Tampilkan Laporan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _loadReport,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportList(LaporanPembelianLoaded state) {
    final mode = state.mode;

    if (state.data.isEmpty) {
      return const Center(
        child: Text(
          '📭 Tidak ada data untuk periode ini',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    if (mode == 'detail') {
      final data = state.data.cast<LaporanDetail>();
      return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final transaksi = data[index];
          return Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ExpansionTile(
              leading: const Icon(Icons.receipt_long, color: Colors.deepPurple),
              title: Text('Invoice: ${transaksi.noTransaksi}'),
              subtitle: Text('Tanggal: ${transaksi.tanggal}'),
              trailing: Text(
                'Rp ${_currencyFormat.format(transaksi.totalHarga)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                const Divider(),
                ...transaksi.detail.map((d) {
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.shopping_bag_outlined,
                        color: Colors.grey),
                    title: Text(d.namaProduk),
                    subtitle: Text('${d.jumlah} pcs'),
                    trailing: Text(
                      'Rp ${_currencyFormat.format(d.subtotal)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      );
    }

    if (mode == 'produk') {
      final data = state.data.cast<LaporanProduk>();
      return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final produk = data[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading:
                  const Icon(Icons.shopping_cart, color: Colors.deepPurple),
              title: Text(produk.namaProduk),
              subtitle: Text('Jumlah: ${produk.totalJumlah}'),
              trailing: Text(
                'Rp ${_currencyFormat.format(produk.totalNominal)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      );
    }

    final data = state.data.cast<LaporanTransaksi>();
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final row = data[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: const Icon(Icons.calendar_today, color: Colors.deepPurple),
            title: Text(row.periode),
            subtitle: Text('Jumlah Transaksi: ${row.jumlahTransaksi}'),
            trailing: Text(
              'Rp ${_currencyFormat.format(row.total)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}
