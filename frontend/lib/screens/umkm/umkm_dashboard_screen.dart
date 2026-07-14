import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/product_card.dart';

class UmkmDashboardScreen extends StatefulWidget {
  const UmkmDashboardScreen({super.key});
  @override
  State<UmkmDashboardScreen> createState() => _UmkmDashboardScreenState();
}

class _UmkmDashboardScreenState extends State<UmkmDashboardScreen> {
  Map<String, dynamic>? _analytics;
  List<Map<String, dynamic>>? _salesChart;
  List<Map<String, dynamic>>? _recentOrders;
  int _activeProductCount = 0;
  bool _isLoading = true;
  final _api = ApiService();

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final results = await Future.wait([
        _api.getUmkmAnalytics(),
        _api.dio.get('/umkm/analytics/sales'),
        _api.getMyProducts(perPage: 5),
        _api.getUmkmOrders(),
      ]);
      final analyticsResp = results[0];
      final salesResp = results[1];
      final productsResp = results[2];
      final ordersResp = results[3];

      setState(() {
        _analytics = analyticsResp.data['data'];
        _salesChart = (salesResp.data['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        _activeProductCount = (productsResp.data['data']['data'] as List?)?.length ?? 0;
        _recentOrders = ((ordersResp.data['data']['data'] as List?) ?? []).take(5).toList().cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (_) {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final revenue = _analytics?['total_sales'] != null
        ? NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_parseNum(_analytics!['total_sales']))
        : 'Rp 0';
    final orders = _analytics?['order_count']?.toString() ?? '0';
    final products = _activeProductCount.toString();
    final rating = _analytics?['avg_rating'] != null ? (_analytics!['avg_rating'] as num).toStringAsFixed(1) : '0.0';

    // Build chart bars from real data
    final chartMax = _salesChart!.isEmpty
        ? 1
        : _salesChart!
            .map((e) => _parseNum(e['total']))
            .fold<num>(0, (a, b) => a > b ? a : b);
    final dayLabels = ['S', 'M', 'S', 'K', 'J', 'S', 'M'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Toko'),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => context.push('/umkm/products/form'),
            tooltip: 'Tambah Produk',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadDashboard,
                color: AppTheme.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Stats cards (responsive aspect ratio to avoid overflow on short screens)
                  Builder(builder: (ctx) {
                    final width = MediaQuery.of(ctx).size.width;
                    final childAspect = width < 400 ? 3.0 : width < 600 ? 2.4 : 1.8;
                    return GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: childAspect,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        _StatCard(icon: '💰', label: 'Pendapatan Bulan Ini', value: revenue, trend: '↑ 15%', isUp: true),
                        _StatCard(icon: '📦', label: 'Pesanan Masuk', value: orders, trend: '8 baru', isUp: true),
                        _StatCard(icon: '🛍️', label: 'Produk Aktif', value: products, trend: 'Stabil', isUp: null),
                        _StatCard(icon: '⭐', label: 'Rating Toko', value: rating, trend: '89 ulasan', isUp: true),
                      ],
                    );
                  }),
                  const SizedBox(height: 20),

                  // Quick actions
                  const Text('Kelola Toko', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _ActionCard(icon: '📦', label: 'Produk', onTap: () => context.push('/umkm/products'))),
                    const SizedBox(width: 10),
                    Expanded(child: _ActionCard(icon: '📋', label: 'Pesanan', onTap: () => context.push('/umkm/orders'))),
                    const SizedBox(width: 10),
                    Expanded(child: _ActionCard(icon: '📊', label: 'Analitik', onTap: () => context.push('/umkm/analytics'))),
                    const SizedBox(width: 10),
                    Expanded(child: _ActionCard(icon: '⚙️', label: 'Pengaturan', onTap: () => context.push('/umkm/store-settings'))),
                  ]),
                  const SizedBox(height: 20),

                  // Sales chart (LineChart via fl_chart)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('📊 Penjualan 7 Hari', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 14),
                      // Use AspectRatio to keep height proportional to width and avoid overflow
                      AspectRatio(
                        aspectRatio: 2.5,
                        child: Builder(builder: (ctx) {
                          final dataList = (_salesChart ?? []).take(7).toList();
                          if (dataList.isEmpty) {
                            return Center(child: Text('Tidak ada data', style: TextStyle(color: AppTheme.textHint)));
                          }

                          final spots = <FlSpot>[];
                          final barGroups = <BarChartGroupData>[];
                          num maxVal = 1;
                          for (var i = 0; i < dataList.length; i++) {
                            final val = _parseNum(dataList[i]['total']).toDouble();
                            spots.add(FlSpot(i.toDouble(), val));
                            barGroups.add(BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: val,
                                  width: 16,
                                  borderRadius: BorderRadius.circular(8),
                                  color: AppTheme.primary.withValues(alpha: 0.65),
                                ),
                              ],
                            ));
                            if (val > maxVal) maxVal = val;
                          }

                          final maxY = (maxVal.toDouble() * 1.25).clamp(1.0, double.infinity);
                          final showDots = spots.length == 1;

                          return Stack(children: [
                            BarChart(
                              BarChartData(
                                maxY: maxY,
                                minY: 0,
                                alignment: BarChartAlignment.spaceBetween,
                                barGroups: barGroups,
                                gridData: FlGridData(show: false),
                                titlesData: FlTitlesData(show: false),
                                borderData: FlBorderData(show: false),
                                barTouchData: BarTouchData(enabled: false),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: LineChart(
                                LineChartData(
                                  gridData: FlGridData(show: false),
                                  titlesData: FlTitlesData(show: false),
                                  borderData: FlBorderData(show: false),
                                  lineTouchData: LineTouchData(
                                    enabled: true,
                                    touchTooltipData: LineTouchTooltipData(
                                      getTooltipColor: (spot) => Colors.white.withValues(alpha: 0.9),
                                      getTooltipItems: (touchedSpots) {
                                        return touchedSpots.map((ts) {
                                          return LineTooltipItem(
                                            NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp').format(ts.y),
                                            const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                                          );
                                        }).toList();
                                      },
                                    ),
                                  ),
                                  minX: 0,
                                  maxX: (spots.length - 1).toDouble(),
                                  minY: 0,
                                  maxY: maxY,
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: spots,
                                      isCurved: true,
                                      color: AppTheme.accentDark,
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      dotData: FlDotData(show: !showDots),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: AppTheme.accent.withValues(alpha: 0.16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ]);
                        }),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  // Recent orders
                  const Text('📋 Pesanan Terbaru', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  ...(_recentOrders ?? []).map((o) {
                    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
                    final dateStr = o['created_at']?.toString().substring(0, 10) ?? '-';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('#${o['order_number']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                          Text(dateStr, style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
                        ])),
                        Text(currency.format(_parseNum(o['total'])), style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 8),
                        StatusBadge(status: o['status']?.toString() ?? ''),
                      ]),
                    );
                  }),
                  SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 80),
                ]),
              ),
            ),
          ),
        );
  }
}

class _StatCard extends StatelessWidget {
  final String icon, label, value, trend;
  final bool? isUp;
  const _StatCard({required this.icon, required this.label, required this.value, required this.trend, required this.isUp});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Text(icon, style: const TextStyle(fontSize: 24)),
      const SizedBox(height: 6),
      Flexible(
        fit: FlexFit.loose,
        child: FittedBox(alignment: Alignment.centerLeft, fit: BoxFit.scaleDown,
          child: Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        ),
      ),
      const SizedBox(height: 6),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textHint), maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(trend, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isUp == null ? AppTheme.textHint : isUp! ? AppTheme.success : AppTheme.danger)),
      ]),
    ]),
  );
}

class _ActionCard extends StatelessWidget {
  final String icon, label;
  final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
      ]),
    ),
  );
}

