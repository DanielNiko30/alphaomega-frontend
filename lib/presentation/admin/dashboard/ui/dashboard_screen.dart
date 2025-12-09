import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../model/laporan/laporan_model.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../../../../../widget/sidebar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 760;

    return BlocProvider(
      create: (_) => DashboardBloc()
        ..add(const LoadDashboard(
            startDate: "2025-11-01", endDate: "2025-11-14")),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Row(
          children: [
            if (isDesktop) const Sidebar(),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (context, state) {
                    if (state is DashboardLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is DashboardError) {
                      return Center(child: Text("Error: ${state.message}"));
                    }

                    if (state is DashboardLoaded) {
                      return _buildDashboardContent(context, state, isDesktop);
                    }

                    return Container();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(
      BuildContext context, DashboardLoaded state, bool isDesktop) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Dashboard",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          // SUMMARY CARDS (Total Penjualan / Total Pembelian / Total Untung)
          GridView.count(
            crossAxisCount: isDesktop ? 4 : 2,
            shrinkWrap: true,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: isDesktop ? 2.4 : 1.9,
            children: [
              _summaryCard(
                title: "Offline",
                total: _sumPenjualan(state.penjualanOffline),
                icon: Icons.storefront_rounded,
                color: Colors.blue.shade50,
              ),
              _summaryCard(
                title: "Shopee",
                total: _sumPenjualan(state.penjualanShopee),
                icon: Icons.shopping_cart_rounded,
                color: Colors.orange.shade50,
              ),
              _summaryCard(
                title: "Lazada",
                total: _sumPenjualan(state.penjualanLazada),
                icon: Icons.shopping_bag_rounded,
                color: Colors.purple.shade50,
              ),
              _summaryCard(
                title: "Pembelian",
                total: _sumPembelian(state.pembelian),
                icon: Icons.receipt_long_rounded,
                color: Colors.green.shade50,
              ),
            ],
          ),

          const SizedBox(height: 28),

          // LINE CHART: Penjualan Per Hari
          _sectionTitle("Penjualan Per Hari"),
          const SizedBox(height: 10),
          _chartContainer(
            height: 240,
            child:
                _buildLineChartPenjualanPerHari(state.summaryPenjualanPerHari),
          ),

          const SizedBox(height: 24),

          // BAR CHART: Penjualan per platform (dengan tooltip)
          _sectionTitle("Penjualan per Platform"),
          const SizedBox(height: 10),
          _chartContainer(
            height: 260,
            child: _buildBarChartPenjualan(
              state.penjualanOffline,
              state.penjualanShopee,
              state.penjualanLazada,
            ),
          ),

          const SizedBox(height: 24),

          // PIE: Top 5 stok
          _sectionTitle("Top 5 Stok Produk"),
          const SizedBox(height: 10),
          _chartContainer(
            height: 320,
            child: _buildPieChartStok(state.stok),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      );

  Widget _chartContainer({required Widget child, double height = 280}) {
    return Container(
      padding: const EdgeInsets.all(12),
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _summaryCard({
    required String title,
    required int total,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.03),
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Rp ${_formatRupiah(total)}",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------------
  // helpers & format
  // ----------------------
  int toIntSafe(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  double toDoubleSafe(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  int _sumPenjualan(List<LaporanNota> list) =>
      list.fold(0, (s, e) => s + toIntSafe(e.totalPenjualan));

  int _sumPembelian(List<LaporanPembelian> list) =>
      list.fold(0, (s, e) => s + toIntSafe(e.subtotal));

  String _formatRupiah(dynamic value) {
    final v = toIntSafe(value);
    if (v == 0) return '0';
    final s = v.toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return s.replaceAllMapped(reg, (m) => '${m[1]}.');
  }

  // -----------------
  // LINE CHART (Penjualan per hari)
  // -----------------
  Widget _buildLineChartPenjualanPerHari(Map<String, int> mapData) {
    if (mapData.isEmpty) {
      return const Center(child: Text("Tidak ada data"));
    }

    final keys = mapData.keys.toList();
    final values = mapData.values.toList();

    final spots = <FlSpot>[];
    for (int i = 0; i < values.length; i++) {
      spots.add(FlSpot(i.toDouble(), values[i].toDouble()));
    }

    final maxY = (values.reduce((a, b) => a > b ? a : b)).toDouble() * 1.15;

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.grey.shade300,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, _) {
                return Text(_formatRupiah(value.toInt()),
                    style: const TextStyle(fontSize: 11));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= keys.length) return const SizedBox();
                // tampilkan mm-dd
                final label = keys[idx].substring(5);
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(label, style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue.shade400,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.shade200.withOpacity(0.25),
            ),
          )
        ],
      ),
    );
  }

  // -----------------
  // BAR CHART (penjualan per platform)
  // -----------------
  Widget _buildBarChartPenjualan(List<LaporanNota> offline,
      List<LaporanNota> shopee, List<LaporanNota> lazada) {
    final data = [
      _ChartData("Offline", _sumPenjualan(offline)),
      _ChartData("Shopee", _sumPenjualan(shopee)),
      _ChartData("Lazada", _sumPenjualan(lazada)),
    ];

    final maxVal =
        (data.map((e) => e.total).reduce((a, b) => a > b ? a : b)).toDouble();
    final maxY = (maxVal == 0) ? 100.0 : maxVal * 1.2;

    final colors = [
      Colors.blue.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
    ];

    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        barGroups: data.asMap().entries.map((entry) {
          final i = entry.key;
          final e = entry.value;
          return BarChartGroupData(x: i, barRods: [
            BarChartRodData(
              toY: e.total.toDouble(),
              color: colors[i],
              width: 28,
              borderRadius: BorderRadius.circular(6),
            )
          ]);
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= data.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    data[idx].platform,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              interval: maxY / 4,
              getTitlesWidget: (value, _) {
                return Text(_formatRupiah(value.toInt()),
                    style: const TextStyle(fontSize: 11));
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: Colors.grey.shade300, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final name = data[group.x.toInt()].platform;
              final val = _formatRupiah(rod.toY.toInt());
              return BarTooltipItem(
                "$name\nRp $val",
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }

  // -----------------
  // PIE CHART (stok)
  // -----------------
  Widget _buildPieChartStok(List<LaporanStok> stok) {
    final top = stok.toList()
      ..sort((a, b) => b.stokAkhir.compareTo(a.stokAkhir));
    final top5 = top.take(5).toList();

    if (top5.isEmpty) {
      return const Center(child: Text("Tidak ada data stok"));
    }

    final colors = [
      Colors.red.shade300,
      Colors.green.shade300,
      Colors.blue.shade300,
      Colors.orange.shade300,
      Colors.purple.shade300
    ];

    final totalStok = top5.fold<int>(0, (s, e) => s + (e.stokAkhir));

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: top5.asMap().entries.map((entry) {
                final i = entry.key;
                final p = entry.value;
                final value = p.stokAkhir.toDouble();
                final percent =
                    totalStok == 0 ? 0.0 : (value / totalStok * 100);
                return PieChartSectionData(
                  color: colors[i % colors.length],
                  value: value,
                  title: "${percent.toStringAsFixed(0)}%",
                  radius: 60,
                  titleStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                );
              }).toList(),
              centerSpaceRadius: 30,
              sectionsSpace: 4,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: top5.asMap().entries.map((entry) {
            final i = entry.key;
            final p = entry.value;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: colors[i % colors.length],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  p.namaProduct,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            );
          }).toList(),
        )
      ],
    );
  }
}

class _ChartData {
  final String platform;
  final int total;
  _ChartData(this.platform, this.total);
}
