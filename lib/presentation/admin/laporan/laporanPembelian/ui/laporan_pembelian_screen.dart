import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../widget/sidebar.dart';
import '../bloc/laporan_pembelian_bloc.dart';
import '../bloc/laporan_pembelian_event.dart';
import '../bloc/laporan_pembelian_state.dart';
import '../../../../../utils/laporan_pembelian_pdf.dart';

class LaporanPembelianScreen extends StatefulWidget {
  const LaporanPembelianScreen({super.key});

  @override
  State<LaporanPembelianScreen> createState() => _LaporanPembelianScreenState();
}

class _LaporanPembelianScreenState extends State<LaporanPembelianScreen> {
  String _mode = 'per_nota'; // default mode
  DateTime? _startDate;
  DateTime? _endDate;

  final _dateFormat = DateFormat('dd MMM yyyy');

  Future<void> _pickDate(BuildContext context, bool isStart) async {
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
          if (_endDate != null && _endDate!.isBefore(_startDate!))
            _endDate = _startDate;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _loadReport() {
    if (_startDate == null || (_mode == 'per_nota' && _endDate == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih tanggal terlebih dahulu")),
      );
      return;
    }

    context.read<LaporanPembelianBloc>().add(
          LoadLaporanPembelian(
            mode: _mode,
            startDate: _startDate!,
            endDate: _endDate,
          ),
        );
  }

  Future<void> _savePdf(List<dynamic> data) async {
    await generateReportPdf(
      context: context,
      reportTitle: "Laporan Pembelian",
      reportType: _mode,
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
                left: isDesktop ? 100 : 0, top: 48, right: 24, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Laporan Pembelian",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                            child: Text("❌ ${state.message}",
                                style: const TextStyle(color: Colors.red)));
                      } else if (state is LaporanPembelianLoaded) {
                        if (state.data.isEmpty) {
                          return const Center(
                              child: Text('📭 Tidak ada data',
                                  style: TextStyle(color: Colors.grey)));
                        }
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
                                ),
                                onPressed: () => _savePdf(state.data),
                              ),
                            ),
                          ],
                        );
                      }
                      return const Center(
                          child: Text('📅 Pilih tanggal untuk melihat laporan',
                              style: TextStyle(color: Colors.grey)));
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
                  labelText: 'Mode Laporan', border: OutlineInputBorder()),
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
                    onTap: () => _pickDate(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                          labelText: 'Tanggal Awal',
                          border: OutlineInputBorder()),
                      child: Text(_startDate != null
                          ? _dateFormat.format(_startDate!)
                          : 'Pilih tanggal'),
                    ),
                  ),
                ),
                if (_mode == 'per_nota') const SizedBox(width: 10),
                if (_mode == 'per_nota')
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDate(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                            labelText: 'Tanggal Akhir',
                            border: OutlineInputBorder()),
                        child: Text(_endDate != null
                            ? _dateFormat.format(_endDate!)
                            : 'Pilih tanggal'),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.search,
                    color: Colors.white), // ikon juga putih
                label: const Text(
                  'Tampilkan Laporan',
                  style: TextStyle(color: Colors.white), // teks putih
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white, // default teks dan ikon putih
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
    final currencyFormat = NumberFormat('#,###', 'id_ID');

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: state.data.length,
      itemBuilder: (context, index) {
        final item = state.data[index];

        // ✅ Aman untuk berbagai kemungkinan nama field
        final nota = item['no_nota'] ??
            item['nota'] ??
            item['invoice'] ??
            item['kode_nota'] ??
            '-';

        final tanggal = item['waktu'] ?? '-';

        final pemasok = item['pemasok'] ?? item['supplier'] ?? '-';
        final barang = item['barang'] ?? item['nama_barang'] ?? '-';
        final satuan = item['satuan'] ?? item['unit'] ?? '';
        final jumlah = item['jumlah'] ?? item['qty'] ?? 0;
        final harga =
            (item['harga'] ?? item['harga_beli'] ?? item['harga_satuan'] ?? 0)
                .toDouble();
        final subtotal = (item['subtotal'] ?? 0).toDouble();

        return Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.deepPurple[50],
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🟣 Nama Barang
                Text(
                  barang,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 4),

                // 🏪 Pemasok
                Row(
                  children: [
                    const Icon(Icons.store, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text("Pemasok: $pemasok",
                          style: const TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),

                // 🧾 No Nota
                Row(
                  children: [
                    const Icon(Icons.receipt_long,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text("No Nota: $nota",
                          style: const TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),

                // 📅 Tanggal
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text("Tanggal: $tanggal",
                          style: const TextStyle(fontSize: 13)),
                    ),
                  ],
                ),

                const Divider(height: 10, color: Colors.deepPurpleAccent),

                // 📦 Jumlah & Harga
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Jumlah: $jumlah $satuan",
                      style: const TextStyle(fontSize: 13),
                    ),
                    Text(
                      "Harga: Rp ${currencyFormat.format(harga)}",
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // 💰 Subtotal
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Subtotal: Rp ${currencyFormat.format(subtotal)}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
