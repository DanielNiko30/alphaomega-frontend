import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../../../utils/laporan_penjualan_pdf.dart';
import '../../../../../widget/sidebar.dart';
import '../bloc/laporan_penjualan_bloc.dart';
import '../bloc/laporan_penjualan_event.dart';
import '../bloc/laporan_penjualan_state.dart';

class LaporanPenjualanScreen extends StatefulWidget {
  const LaporanPenjualanScreen({super.key});

  @override
  State<LaporanPenjualanScreen> createState() => _LaporanPenjualanScreenState();
}

class _LaporanPenjualanScreenState extends State<LaporanPenjualanScreen> {
  String _mode = 'harian';
  DateTime? _startDate;
  DateTime? _endDate;
  DateFormat? _format;

  @override
  void initState() {
    super.initState();
    _initDateFormat();
  }

  Future<void> _initDateFormat() async {
    try {
      await initializeDateFormatting('id_ID', null);
      _format = DateFormat('dd MMM yyyy', 'id_ID');
    } catch (e) {
      _format = DateFormat('dd MMM yyyy', 'en_US');
    }
    if (mounted) setState(() {});
  }

  Future<void> _pickDate(bool isStart) async {
    final initial =
        isStart ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = picked;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _loadReport() {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal awal dulu')),
      );
      return;
    }

    context.read<LaporanPenjualanBloc>().add(
          GetLaporanPenjualanRangeEvent(
            startDate: _startDate!,
            endDate: _mode == 'per_nota' ? _endDate : null,
            mode: _mode,
          ),
        );
  }

  Future<void> _savePdf(Map<String, dynamic> data) async {
    await generateLaporanJualPdf(
      context: context,
      reportTitle: 'Laporan Penjualan',
      data: data, // langsung map, bukan list
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 700;

    if (_format == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                  "Laporan Penjualan",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildFilterCard(),
                const SizedBox(height: 16),
                Expanded(
                  child:
                      BlocBuilder<LaporanPenjualanBloc, LaporanPenjualanState>(
                    builder: (context, state) {
                      if (state is LaporanPenjualanLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is LaporanPenjualanError) {
                        return Center(
                            child: Text("❌ ${state.message}",
                                style: const TextStyle(color: Colors.red)));
                      } else if (state is LaporanPenjualanLoaded) {
                        final dataMap = Map<String, dynamic>.from(state.data);

                        if (dataMap.isEmpty) {
                          return const Center(child: Text('📭 Tidak ada data'));
                        }

                        debugPrint("DEBUG >> STATE.DATA KEYS: ${dataMap.keys}");

                        return Column(
                          children: [
                            Expanded(child: _buildReportList(dataMap)),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: () => _savePdf(dataMap),
                                icon: const Icon(Icons.picture_as_pdf),
                                label: const Text('Simpan PDF'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      return const Center(
                        child: Text(
                          '📅 Pilih tanggal untuk menampilkan laporan',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (isDesktop)
            const Positioned(left: 0, top: 0, bottom: 0, child: Sidebar()),
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
                labelText: 'Mode Laporan',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'harian', child: Text('Harian')),
                DropdownMenuItem(value: 'per_nota', child: Text('Per Nota')),
              ],
              onChanged: (val) => setState(() => _mode = val!),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _pickDate(true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Awal',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(_startDate == null
                          ? 'Pilih tanggal'
                          : _format!.format(_startDate!)),
                    ),
                  ),
                ),
                if (_mode == 'per_nota') const SizedBox(width: 10),
                if (_mode == 'per_nota')
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDate(false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Akhir',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_endDate == null
                            ? 'Pilih tanggal'
                            : _format!.format(_endDate!)),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loadReport,
                icon: const Icon(Icons.search),
                label: const Text('Tampilkan Laporan'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportList(Map<String, dynamic> data) {
    final currency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final channels = ['offline', 'shopee', 'lazada'];

    num grandPenjualan = 0;
    num grandHpp = 0;
    num grandUntung = 0;

    debugPrint("DEBUG >> BUILDING REPORT LIST UNTUK CHANNELS: $channels");

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        ...channels.map((channelName) {
          final rawChannel = data[channelName] ?? {};
          final channel = Map<String, dynamic>.from(rawChannel);
          final total = Map<String, dynamic>.from(channel['total'] ?? {});
          final laporan = List<Map<String, dynamic>>.from(
            (channel['laporan'] ?? []).map((e) => Map<String, dynamic>.from(e)),
          );

          final totalPenjualan = (total['penjualan'] ?? 0) as num;
          final totalHpp = (total['hpp'] ?? 0) as num;
          final totalUntung = (total['untung'] ?? 0) as num;

          grandPenjualan += totalPenjualan;
          grandHpp += totalHpp;
          grandUntung += totalUntung;

          debugPrint(
              "DEBUG >> CHANNEL: $channelName, LAPORAN COUNT: ${laporan.length}");

          return Card(
            color: Colors.deepPurple[50],
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(channelName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const Divider(),
                  if (laporan.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Tidak ada transaksi',
                          style: TextStyle(color: Colors.grey)),
                    )
                  else
                    ...laporan.map((nota) {
                      final tanggal = nota['tanggal'] ?? '-';
                      final metode = nota['metode_pembayaran'] ?? '-';
                      final details = List<Map<String, dynamic>>.from(
                        (nota['detail'] ?? [])
                            .map((d) => Map<String, dynamic>.from(d)),
                      );
                      final totalNota =
                          Map<String, dynamic>.from(nota['total_nota'] ?? {});

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 3),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("No Nota: ${nota['id_htrans_jual']}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text("Tanggal: $tanggal"),
                              Text("Metode: $metode"),
                              const SizedBox(height: 8),
                              Table(
                                border:
                                    TableBorder.all(color: Colors.grey[300]!),
                                columnWidths: const {
                                  0: FlexColumnWidth(3),
                                  1: FlexColumnWidth(1),
                                  2: FlexColumnWidth(2),
                                  3: FlexColumnWidth(2),
                                  4: FlexColumnWidth(2),
                                  5: FlexColumnWidth(2),
                                },
                                children: [
                                  const TableRow(
                                    decoration:
                                        BoxDecoration(color: Color(0xFFEDE7F6)),
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.all(4),
                                          child: Text('Barang',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      Padding(
                                          padding: EdgeInsets.all(4),
                                          child: Text('Qty',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      Padding(
                                          padding: EdgeInsets.all(4),
                                          child: Text('Harga Jual',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      Padding(
                                          padding: EdgeInsets.all(4),
                                          child: Text('Harga Beli',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      Padding(
                                          padding: EdgeInsets.all(4),
                                          child: Text('Subtotal',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      Padding(
                                          padding: EdgeInsets.all(4),
                                          child: Text('Untung',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                    ],
                                  ),
                                  ...details.map((item) {
                                    final nama = item['nama_product'] ?? '-';
                                    final jumlah = item['jumlah'] ?? '0';
                                    final hargaJual =
                                        (item['harga_jual'] ?? 0) as num;
                                    final hargaBeli =
                                        (item['harga_beli'] ?? 0) as num;
                                    final subtotal =
                                        (item['subtotal'] ?? 0) as num;
                                    final untung = (item['untung'] ?? 0) as num;

                                    return TableRow(
                                      children: [
                                        Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Text(nama)),
                                        Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Text(jumlah.toString())),
                                        Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Text(
                                                currency.format(hargaJual))),
                                        Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Text(
                                                currency.format(hargaBeli))),
                                        Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Text(
                                                currency.format(subtotal))),
                                        Padding(
                                            padding: const EdgeInsets.all(4),
                                            child:
                                                Text(currency.format(untung))),
                                      ],
                                    );
                                  }).toList(),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                        "Total Penjualan: ${currency.format(totalNota['total_penjualan'] ?? 0)}"),
                                    Text(
                                        "HPP: ${currency.format(totalNota['total_hpp'] ?? 0)}"),
                                    Text(
                                        "Untung: ${currency.format(totalNota['total_untung'] ?? 0)}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green)),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  const Divider(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                            "Total Channel: ${currency.format(totalPenjualan)}"),
                        Text("Total HPP: ${currency.format(totalHpp)}"),
                        Text("Total Untung: ${currency.format(totalUntung)}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 16),
        Card(
          color: Colors.deepPurple.shade100,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text("GRAND TOTAL SEMUA CHANNEL",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Divider(),
                Text("Total Penjualan: ${currency.format(grandPenjualan)}"),
                Text("Total HPP: ${currency.format(grandHpp)}"),
                Text("Total Untung: ${currency.format(grandUntung)}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
