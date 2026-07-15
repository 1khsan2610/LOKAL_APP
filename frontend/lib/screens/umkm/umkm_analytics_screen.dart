import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/product_card.dart';

class UmkmAnalyticsScreen extends StatefulWidget {
  const UmkmAnalyticsScreen({super.key});

  @override
  State<UmkmAnalyticsScreen> createState() => _UmkmAnalyticsScreenState();
}

class _UmkmAnalyticsScreenState extends State<UmkmAnalyticsScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  Map<String, dynamic>? _summary;
  List<Map<String, dynamic>> _salesData = [];

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  num _parseNum(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value.replaceAll(',', '')) ?? 0;
    return 0;
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    try {
      final responses = await Future.wait([
        _api.getUmkmAnalytics(),
        _api.dio.get('/umkm/analytics/sales'),
      ]);
      final summary = responses[0].data['data'] as Map<String, dynamic>?;
      final sales = (responses[1].data['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      sales.sort((a, b) {
        final aDate = DateTime.tryParse(a['date']?.toString() ?? '') ?? DateTime.now();
        final bDate = DateTime.tryParse(b['date']?.toString() ?? '') ?? DateTime.now();
        return aDate.compareTo(bDate);
      });
      setState(() {
        _summary = summary;
        _salesData = sales;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSalesValue = _parseNum(_summary?['total_sales']);
    final totalOrdersValue = _parseNum(_summary?['order_count']);
    final averageOrderValue = totalOrdersValue > 0 ? totalSalesValue / totalOrdersValue : 0;
    final amountFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analitik Penjualan'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
            tooltip: 'Segarkan',
          ),
        ],
      ),
      backgroundColor: AppTheme.bg,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadAnalytics,
                color: AppTheme.primary,
                // LayoutBuilder: jumlah kolom & aspect ratio kartu ringkasan
                // memakai lebar konstrain aktual, konsisten dengan pendekatan
                // di Dashboard Toko — supaya tampil proporsional di HP, tablet,
                // maupun Flutter web tanpa teks/angka terpotong.
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final statColumns = width < 500 ? 2 : 4;
                    final statAspect = width < 400 ? 1.7 : width < 700 ? 2.1 : 2.4;
                    return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ringkasan Penjualan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: statColumns,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: statAspect,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: [
                          _MiniStatCard(
                            icon: '💰',
                            label: 'Total Pendapatan',
                            value: amountFormat.format(totalSalesValue),
                            accent: AppTheme.primary,
                          ),
                          _MiniStatCard(
                            icon: '📦',
                            label: 'Total Pesanan',
                            value: totalOrdersValue.toInt().toString(),
                            accent: AppTheme.accentDark,
                          ),
                          _MiniStatCard(
                            icon: '📈',
                            label: 'Rata-rata Order',
                            value: amountFormat.format(averageOrderValue),
                            accent: AppTheme.accent,
                          ),
                          _MiniStatCard(
                            icon: '🗓️',
                            label: 'Periode Data',
                            value: _salesData.isNotEmpty
                                ? '${_formatDate(_salesData.first['date'])} - ${_formatDate(_salesData.last['date'])}'
                                : '-',
                            accent: AppTheme.primaryLight,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tinjauan Penjualan Harian', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 10),
                            // Wrap: legenda tetap rapi menyusun ulang baris
                            // baru kalau lebar sempit, bukan overflow.
                            Wrap(
                              spacing: 12,
                              runSpacing: 6,
                              children: const [
                                _ChartLegend(color: AppTheme.primary, label: 'Pendapatan'),
                                _ChartLegend(color: AppTheme.accentDark, label: 'Trend penjualan'),
                              ],
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              height: 300,
                              child: _buildChart(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Detail Penjualan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      // Kalau belum ada data sama sekali, tampilkan EmptyState
                      // konsisten (bukan header kosong tanpa penjelasan).
                      if (_salesData.isEmpty)
                        const EmptyState(
                          emoji: '📊',
                          title: 'Belum Ada Data Penjualan',
                          subtitle: 'Data penjualan harian akan muncul di sini setelah ada transaksi',
                        )
                      else
                        ..._salesData.map((item) {
                        final date = _formatDate(item['date']);
                        final total = amountFormat.format(_parseNum(item['total']));
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AppCard(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Row(
                              children: [
                                Expanded(child: Text(date, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                                const SizedBox(width: 8),
                                Text(total, style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildChart() {
    if (_salesData.isEmpty) {
      return Center(child: Text('Tidak ada data penjualan', style: TextStyle(color: AppTheme.textHint)));
    }

    final chartData = _salesData.take(7).toList();
    final labels = chartData.map((item) => DateFormat('dd MMM').format(DateTime.parse(item['date'].toString()))).toList();
    final spots = <FlSpot>[];
    final barGroups = <BarChartGroupData>[];
    num maxValue = 1;
    for (var i = 0; i < chartData.length; i++) {
      final total = _parseNum(chartData[i]['total']).toDouble();
      spots.add(FlSpot(i.toDouble(), total));
      barGroups.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: total,
            width: 16,
            borderRadius: BorderRadius.circular(8),
            color: AppTheme.primary.withValues(alpha: 0.65),
          ),
        ],
      ));
      if (total > maxValue) maxValue = total;
    }

    final maxY = (maxValue * 1.25).clamp(1.0, double.infinity);

    return Stack(
      children: [
        BarChart(
          BarChartData(
            maxY: maxY,
            minY: 0,
            alignment: BarChartAlignment.spaceBetween,
            barGroups: barGroups,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) => FlLine(color: AppTheme.surface2, strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 40,
                  getTitlesWidget: (value, titleMeta) {
                    final index = value.toInt();
                    if (index < 0 || index >= labels.length) return const SizedBox();
                    return Text(labels[index], style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary));
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: maxY / 4,
                  reservedSize: 42,
                  getTitlesWidget: (value, titleMeta) {
                    return Text(NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp').format(value), style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary));
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(enabled: false),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (spots.length - 1).toDouble(),
              minY: 0,
              maxY: maxY,
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (spot) => Colors.white.withValues(alpha: 0.95),
                  getTooltipItems: (touchedSpots) => touchedSpots.map((ts) {
                    return LineTooltipItem(
                      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(ts.y),
                      const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                    );
                  }).toList(),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: AppTheme.accentDark,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(show: true, color: AppTheme.accent.withValues(alpha: 0.16)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic rawDate) {
    try {
      return DateFormat('dd MMM').format(DateTime.parse(rawDate.toString()));
    } catch (_) {
      return rawDate?.toString() ?? '-';
    }
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _ChartLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color accent;

  const _MiniStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      // FittedBox membungkus SELURUH isi kartu (ikon + nilai + label), bukan
      // cuma baris nilai. Sebelumnya hanya baris nilai yang elastis, sehingga
      // di HP sempit total tinggi ikon+spasi+label yang tetap (non-elastis)
      // masih bisa sedikit melebihi tinggi sel grid (overflow beberapa
      // pixel walau tipis). Dengan satu FittedBox di luar, seluruh konten
      // ikut menyusut proporsional sebagai upaya terakhir — dijamin tidak
      // overflow di lebar/tinggi berapa pun.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 10),
            Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: accent)),
            Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}
