import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/product_card.dart';
import '../../widgets/app_card.dart';
import '../../widgets/dashboard_components.dart';

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

  num _parseNum(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value.replaceAll(',', '')) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final revenue = _analytics?['total_sales'] != null
        ? NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_parseNum(_analytics!['total_sales']))
        : 'Rp 0';
    final orders = _analytics?['order_count']?.toString() ?? '0';
    final products = _activeProductCount.toString();
    final rating = _analytics?['avg_rating'] != null ? (_analytics!['avg_rating'] as num).toStringAsFixed(1) : '0.0';

    // Chart values are computed inline in the chart builder below

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
                // LayoutBuilder: kolom & aspect ratio grid statistik memakai
                // lebar konstrain aktual, bukan asumsi dari MediaQuery layar
                // penuh — konsisten dengan pendekatan di Beranda & Admin
                // Dashboard.
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final statColumns = width < 700 ? 2 : width < 1000 ? 3 : 4;
                    final statAspect = width < 400 ? 1.3 : width < 600 ? 1.6 : 1.9;

                    return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Stats cards — chip ikon pastel ala dashboard admin web
                  GridView.count(
                      crossAxisCount: statColumns,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: statAspect,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        StatCard(icon: Icons.payments_outlined, iconColor: const Color(0xFF15803D), iconBg: const Color(0xFFDCFCE7),
                          value: revenue, label: 'Pendapatan Bulan Ini', badge: '↑ 15%', badgeColor: AppTheme.success),
                        StatCard(icon: Icons.inventory_2_outlined, iconColor: const Color(0xFF1E40AF), iconBg: const Color(0xFFDBEAFE),
                          value: orders, label: 'Pesanan Masuk', badge: '8 baru', badgeColor: AppTheme.info),
                        StatCard(icon: Icons.shopping_bag_outlined, iconColor: const Color(0xFFB45309), iconBg: const Color(0xFFFEF3C7),
                          value: products, label: 'Produk Aktif', badge: 'Stabil', badgeColor: AppTheme.textHint),
                        StatCard(icon: Icons.star_outline, iconColor: const Color(0xFF6D28D9), iconBg: const Color(0xFFEDE9FE),
                          value: rating, label: 'Rating Toko', badge: '89 ulasan', badgeColor: AppTheme.success),
                      ],
                  ),
                  const SizedBox(height: 20),

                  // Quick actions
                  const Text('Kelola Toko', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: QuickActionTile(icon: Icons.inventory_2_outlined, label: 'Produk', onTap: () => context.push('/umkm/products'))),
                    const SizedBox(width: 10),
                    Expanded(child: QuickActionTile(icon: Icons.list_alt_outlined, label: 'Pesanan', onTap: () => context.push('/umkm/orders'))),
                    const SizedBox(width: 10),
                    Expanded(child: QuickActionTile(icon: Icons.bar_chart_outlined, label: 'Analitik', onTap: () => context.push('/umkm/analytics'))),
                    const SizedBox(width: 10),
                    Expanded(child: QuickActionTile(icon: Icons.settings_outlined, label: 'Pengaturan', onTap: () => context.push('/umkm/store-settings'))),
                  ]),
                  const SizedBox(height: 20),

                  // Sales chart (LineChart via fl_chart)
                  AppCard(
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
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AppCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('#${o['order_number']}', maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                            Text(dateStr, style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
                          ])),
                          const SizedBox(width: 8),
                          // Flexible+FittedBox: total harga + status badge tetap
                          // dalam satu baris tapi menyusut proporsional saat
                          // harga panjang & layar sempit, bukan overflow.
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Text(currency.format(_parseNum(o['total'])), style: const TextStyle(fontSize: 13)),
                                const SizedBox(width: 8),
                                StatusBadge(status: o['status']?.toString() ?? ''),
                              ]),
                            ),
                          ),
                        ]),
                      ),
                    );
                  }),
                  SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 80),
                ]),
              );
                  },
                ),
              ),
            ),
    );
  }
}
