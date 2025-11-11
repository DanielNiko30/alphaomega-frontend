import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../../../utils/laporan_stok_pdf.dart';
import '../../../../../widget/sidebar.dart';
import '../bloc/laporan_stok_bloc.dart';
import '../bloc/laporan_stok_event.dart';
import '../bloc/laporan_stok_state.dart';
import '../../../../../model/laporan/laporan_model.dart';

class LaporanStokScreen extends StatefulWidget {
  const LaporanStokScreen({super.key});

  @override
  State<LaporanStokScreen> createState() => _LaporanStokScreenState();
}

class _LaporanStokScreenState extends State<LaporanStokScreen> {
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

    if (_mode == 'harian') {
      context
          .read<LaporanStokBloc>()
          .add(GetLaporanStokHarianEvent(tanggal: _startDate!));
    } else {
      context.read<LaporanStokBloc>().add(
            GetLaporanStokRangeEvent(startDate: _startDate!, endDate: _endDate),
          );
    }
  }

  void _generatePdf(LaporanStokLoaded state) {
    final pdfData = state.data.map((stok) {
      return {
        'nama_product': stok.namaProduct,
        'stok_awal': stok.stokAwal,
        'total_masuk': stok.totalMasuk,
        'detail_masuk': stok.detailMasuk
            .map((d) => {
                  'tanggal': d.tanggal,
                  'jumlah': d.jumlah,
                  'invoice': d.invoice,
                })
            .toList(),
        'total_keluar': stok.totalKeluar,
        'detail_keluar': stok.detailKeluar
            .map((d) => {
                  'tanggal': d.tanggal,
                  'jumlah': d.jumlah,
                })
            .toList(),
        'stok_akhir': stok.stokAkhir,
      };
    }).toList();

    final periodeText = state.periode;
    generateLaporanStokPdf(
      context: context,
      reportTitle: "Laporan Stok",
      data: pdfData,
      periode: periodeText,
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
                  "Laporan Stok",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildFilterCard(),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<LaporanStokBloc, LaporanStokState>(
                    builder: (context, state) {
                      if (state is LaporanStokLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is LaporanStokError) {
                        return Center(
                            child: Text("❌ ${state.message}",
                                style: const TextStyle(color: Colors.red)));
                      } else if (state is LaporanStokLoaded) {
                        if (state.data.isEmpty) {
                          return const Center(child: Text('📭 Tidak ada data'));
                        }

                        return _buildReportList(state.data, state.periode);
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

          // Tombol PDF floating di kanan bawah layar
          BlocBuilder<LaporanStokBloc, LaporanStokState>(
            builder: (context, state) {
              if (state is LaporanStokLoaded && state.data.isNotEmpty) {
                return Positioned(
                  bottom: 16,
                  right: 16,
                  child: ElevatedButton.icon(
                    onPressed: () => _generatePdf(state),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Simpan PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
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
                labelText: 'Mode Laporan',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'harian', child: Text('Harian')),
                DropdownMenuItem(value: 'range', child: Text('Periode')),
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
                if (_mode == 'range') const SizedBox(width: 10),
                if (_mode == 'range')
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

  Widget _buildReportList(List<LaporanStok> data, String periode) {
    final dateFormat = _format ?? DateFormat('dd MMM yyyy');

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        Text(
          "Periode: $periode",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        ...data.map((stok) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stok.namaProduct,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Divider(thickness: 1),
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(2),
                    },
                    border: TableBorder.all(
                        color: Colors.grey.shade300, width: 0.5),
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Colors.grey.shade200),
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(6),
                            child: Text("Stok Awal",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(6),
                            child: Text("Total Masuk",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(6),
                            child: Text("Total Keluar",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(6),
                            child: Text("Stok Akhir",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      TableRow(children: [
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: Text(stok.stokAwal.toString()),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: Text(stok.totalMasuk.toString()),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: Text(stok.totalKeluar.toString()),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: Text(stok.stokAkhir.toString()),
                        ),
                      ])
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (stok.detailMasuk.isNotEmpty) ...[
                    const Text("Detail Masuk",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.green)),
                    const SizedBox(height: 4),
                    ...stok.detailMasuk.map(
                      (d) => Text(
                          "${d.tanggal} | Jumlah: ${d.jumlah} | Invoice: ${d.invoice}"),
                    ),
                  ],
                  if (stok.detailKeluar.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text("Detail Keluar",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.red)),
                    const SizedBox(height: 4),
                    ...stok.detailKeluar.map(
                      (d) => Text("${d.tanggal} | Jumlah: ${d.jumlah}"),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
