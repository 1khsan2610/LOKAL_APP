import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_card.dart';

/// Halaman Analitik Penjualan dengan filter periode, grafik, pie chart & insight
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
  List<Map<String, dynamic>> _topProducts = [];
  List<Map<String, dynamic>> _categoryDistribution = [];
  String _selectedPeriod = '7';

  final _periods = [
    {'label': '7 Hari', 'value': '7'},
    {'label': '30 Hari', 'value': '30'},
    {'label': 'Tahun Ini', 'value': 'year'},
    {'label': 'Custom', 'value': 'custom'},
  ];

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

  Future<void> _loadAnalytics({String period = '7'}) async {
    setState(() => _isLoading = true);
    try {
      final responses = await Future.wait([
        _api.getUmkmAnalytics(),
        _api.dio.get('/umkm/analytics/sales', queryParameters: {'period': period}),
        _api.dio.get('/umkm/analytics/top-products', queryParameters: {'period': period}),
        _api.dio.get('/umkm/analytics/category-distribution', queryParameters: {'period': period}),
      ]);

      final summary = responses[0].data['data'] as Map<String, dynamic>?;
      final sales = (responses[1].data['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final topProducts = (responses[2].data['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final categories = (responses[3].data['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];

      sales.sort((a, b) {
        final aDate = DateTime.tryParse(a['date']?.toString() ?? '') ?? DateTime.now();
        final bDate = DateTime.tryParse(b['date']?.toString() ?? '') ?? DateTime.now();
        return aDate.compareTo(bDate);
      });

      setState(() {
        _summary = summary;
        _salesData = sales;
        _topProducts = topProducts;
        _categoryDistribution = categories;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    final totalSalesValue = _parseNum(_summary?['total_sales']);
    final totalOrdersValue = _parseNum(_summary?['order_count']);
    final averageOrderValue = totalOrdersValue > 0 ? totalSalesValue / totalOrdersValue : 0;
    final totalProductsSold = _parseNum(_summary?['products_sold'] ?? _summary?['total_products_sold'] ?? 0);
    final amountFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return RefreshIndicator(
      onRefresh: () => _loadAnalytics(period: _selectedPeriod),
      color: AppTheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Filter Periode ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.surface2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: _periods.map((p) {
                  final isActive = _selectedPeriod == p['value'];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedPeriod = p['value'] as String);
                        _loadAnalytics(period: _selectedPeriod);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: isActive
                              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 1))]
                              : null,
                        ),
                        child: Text(
                          p['label'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                            color: isActive ? AppTheme.primary : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // ── KPI Summary Cards ───────────────────────────────────
            const Text('Ringkasan Penjualan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.6,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _KpiCard(
                  icon: Icons.payments_outlined,
                  label: 'Total Pendapatan',
                  value: amountFormat.format(totalSalesValue),
                  change: _weeklyChangeString('revenue'),
                  isUp: true,
                  bgColor: const Color(0xFFE6F4EA),
                  iconColor: const Color(0xFF15803D),
                ),
                _KpiCard(
                  icon: Icons.receipt_long_outlined,
                  label: 'Total Pesanan',
                  value: totalOrdersValue.toInt().toString(),
                  change: _weeklyChangeString('orders'),
                  isUp: true,
                  bgColor: const Color(0xFFDBEAFE),
                  iconColor: const Color(0xFF1E40AF),
                ),
                _KpiCard(
                  icon: Icons.trending_up_rounded,
                  label: 'Rata-rata Transaksi',
                  value: amountFormat.format(averageOrderValue),
                  change: 'Per order',
                  isUp: true,
                  bgColor: const Color(0xFFF3E8FF),
                  iconColor: const Color(0xFF8E24AA),
                ),
                _KpiCard(
                  icon: Icons.inventory_2_outlined,
                  label: 'Produk Terjual',
                  value: totalProductsSold.toInt().toString(),
                  change: '${_topProducts.length} produk',
                  isUp: true,
                  bgColor: const Color(0xFFFFF8E1),
                  iconColor: const Color(0xFFB45309),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Chart Section ───────────────────────────────────────
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tren Pendapatan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: const [
                      _ChartLegend(color: AppTheme.primary, label: 'Pendapatan'),
                      _ChartLegend(color: AppTheme.accentDark, label: 'Trend'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 300,
                    child: _salesData.isEmpty
                        ? Center(child: Text('Belum ada data penjualan', style: TextStyle(color: AppTheme.textHint)))
                        : _buildChart(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Top Products ────────────────────────────────────────
            const Text('Produk Terlaris', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (_topProducts.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: 48, color: AppTheme.textHint),
                    SizedBox(height: 12),
                    Text('Belum Ada Data', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                  ],
                ),
              )
            else
              ..._topProducts.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.surface2,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.shopping_bag_outlined, size: 20, color: AppTheme.textHint),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p['name'] ?? p['product_name'] ?? 'Produk',
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            Text('${_parseNum(p['sold_count'] ?? p['quantity'] ?? 0).toInt()} terjual',
                              style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
                          ],
                        ),
                      ),
                      Text(
                        amountFormat.format(_parseNum(p['total_revenue'] ?? p['revenue'] ?? 0)),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.primary),
                      ),
                    ],
                  ),
                ),
              )),
            const SizedBox(height: 20),

            // ── Category Distribution (Pie Chart) ──────────────────
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Distribusi Kategori', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  if (_categoryDistribution.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text('Belum ada data kategori', style: TextStyle(color: AppTheme.textHint)),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 180,
                            child: PieChart(
                              PieChartData(
                                sections: _categoryDistribution.asMap().entries.map((entry) {
                                  final item = entry.value;
                                  final value = _parseNum(item['percentage'] ?? item['count'] ?? 0).toDouble();
                                  final colors = [
                                    const Color(0xFF1966D2),
                                    const Color(0xFF8E24AA),
                                    const Color(0xFFE53935),
                                    const Color(0xFFF59E0B),
                                    const Color(0xFF22C55E),
                                    const Color(0xFF06B6D4),
                                  ];
                                  return PieChartSectionData(
                                    value: value > 0 ? value : 1,
                                    color: colors[entry.key % colors.length],
                                    radius: 40,
                                    title: '${value.toStringAsFixed(0)}%',
                                    titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                                  );
                                }).toList(),
                                sectionsSpace: 2,
                                centerSpaceRadius: 30,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: _categoryDistribution.asMap().entries.map((entry) {
                            final item = entry.value;
                            final colors = [
                              const Color(0xFF1966D2),
                              const Color(0xFF8E24AA),
                              const Color(0xFFE53935),
                              const Color(0xFFF59E0B),
                              const Color(0xFF22C55E),
                              const Color(0xFF06B6D4),
                            ];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(width: 10, height: 10,
                                    decoration: BoxDecoration(
                                      color: colors[entry.key % colors.length],
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(item['name'] ?? item['category'] ?? 'Lainnya',
                                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Business Insights ───────────────────────────────────
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.auto_awesome, size: 18, color: Color(0xFF8E24AA)),
                      ),
                      const SizedBox(width: 10),
                      const Text('Wawasan Bisnis', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _insightItem(
                    Icons.trending_up,
                    'Strategi Promosi',
                    'Berdasarkan data penjualan, produk dengan harga Rp25.000 - Rp50.000 memiliki konversi tertinggi. Pertimbangkan untuk membuat bundle produk.',
                    const Color(0xFF1E40AF),
                  ),
                  const SizedBox(height: 10),
                  _insightItem(
                    Icons.people_outline,
                    'Peningkatan Pelanggan',
                    totalOrdersValue > 10
                        ? 'Anda memiliki ${totalOrdersValue.toInt()} pesanan. Terus tingkatkan kualitas layanan untuk mendapatkan lebih banyak pelanggan tetap.'
                        : 'Aktifkan fitur promo dan bagikan link toko ke media sosial untuk meningkatkan penjualan.',
                    const Color(0xFF15803D),
                  ),
                  const SizedBox(height: 10),
                  _insightItem(
                    Icons.inventory_2_outlined,
                    'Manajemen Stok',
                    _topProducts.isNotEmpty
                        ? '${_topProducts.length} produk terlaris Anda. Pastikan stok cukup untuk memenuhi permintaan.'
                        : 'Tambahkan produk baru untuk mulai berjualan dan menarik pelanggan.',
                    const Color(0xFFB45309),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _insightItem(IconData icon, String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _weeklyChangeString(String key) {
    try {
      final change = _parseNum(_summary?['${key}_change'] ?? _summary?['change_$key'] ?? 0);
      if (change >= 0) return '+$change%';
      return '$change%';
    } catch (_) {
      return '0%';
    }
  }

  Widget _buildChart() {
    final chartData = _salesData.take(7).toList();
    if (chartData.isEmpty) {
      return Center(child: Text('Tidak ada data', style: TextStyle(color: AppTheme.textHint)));
    }

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
                    return Text(
                      NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp').format(value),
                      style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                    );
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

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String change;
  final bool isUp;
  final Color bgColor;
  final Color iconColor;

  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.change,
    required this.isUp,
    required this.bgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: iconColor),
          ),
            const Spacer(),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: iconColor)),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: 12, color: isUp ? AppTheme.success : AppTheme.danger),
              const SizedBox(width: 2),
              Text(change, style: TextStyle(fontSize: 10, color: isUp ? AppTheme.success : AppTheme.danger, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textHint, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}