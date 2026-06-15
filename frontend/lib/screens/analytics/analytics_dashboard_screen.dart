import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/umkm_provider.dart';
import '../../models/umkm.dart';
import '../../widgets/common/custom_widgets.dart' as custom_widgets;

enum AnalyticsPeriod { daily, weekly, monthly }

class AnalyticsDashboardScreen extends ConsumerStatefulWidget {
  final String umkmId;

  const AnalyticsDashboardScreen({
    Key? key,
    required this.umkmId,
  }) : super(key: key);

  @override
  ConsumerState<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends ConsumerState<AnalyticsDashboardScreen> {
  AnalyticsPeriod _selectedPeriod = AnalyticsPeriod.daily;

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(umkmAnalyticsProvider(widget.umkmId));

    return Scaffold(
      appBar: custom_widgets.CustomAppBar(
        title: 'Dashboard Analitik',
        showBackButton: true,
      ),
      body: analyticsAsync.when(
        data: (analytics) {
          final chartData = _selectedPeriod == AnalyticsPeriod.daily
              ? analytics.dailyRevenue
              : _selectedPeriod == AnalyticsPeriod.weekly
                  ? _groupByWeek(analytics.dailyRevenue)
                  : _groupByMonth(analytics.dailyRevenue);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppNumbers.paddingMedium),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ringkasan Penjualan', style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 4),
                          Text('Pantau performa toko UMKM Anda dalam satu tampilan.',
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryColor),
                            const SizedBox(width: 8),
                            Text('Periode ${_selectedPeriod.name}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.primaryColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppNumbers.paddingMedium),
                  child: Wrap(
                    spacing: 10,
                    children: AnalyticsPeriod.values.map((period) {
                      final text = period == AnalyticsPeriod.daily
                          ? 'Harian'
                          : period == AnalyticsPeriod.weekly
                              ? 'Mingguan'
                              : 'Bulanan';
                      return ChoiceChip(
                        label: Text(text),
                        selected: _selectedPeriod == period,
                        selectedColor: AppTheme.primaryColor,
                        backgroundColor: AppTheme.surfaceColor,
                        labelStyle: TextStyle(
                          color: _selectedPeriod == period ? Colors.white : AppTheme.textPrimary,
                        ),
                        onSelected: (_) => setState(() => _selectedPeriod = period),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppNumbers.paddingMedium),
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _MetricCard(
                        title: 'Total Pendapatan',
                        value: 'Rp ${analytics.totalRevenue.toStringAsFixed(0)}',
                        growth: '${analytics.revenueGrowth.toStringAsFixed(1)}%',
                        icon: '💰',
                      ),
                      _MetricCard(
                        title: 'Total Pesanan',
                        value: '${analytics.totalOrders}',
                        growth: '${analytics.totalCustomers} pelanggan',
                        icon: '📦',
                      ),
                      _MetricCard(
                        title: 'Pelanggan',
                        value: '${analytics.totalCustomers}',
                        growth: 'Aktif',
                        icon: '👥',
                      ),
                      _MetricCard(
                        title: 'Rating',
                        value: '${analytics.averageRating.toStringAsFixed(1)}',
                        growth: 'Rata-rata',
                        icon: '⭐',
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppNumbers.paddingMedium),
                  child: Text('Grafik Penjualan', style: Theme.of(context).textTheme.titleLarge),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppNumbers.paddingMedium),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 260,
                            child: chartData.isEmpty
                                ? Center(
                                    child: Text(
                                      'Data penjualan belum tersedia untuk periode ini.',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : LineChart(_buildRevenueLineChart(chartData)),
                          ),
                          const SizedBox(height: 16),
                          Text('Pendapatan ${_selectedPeriod == AnalyticsPeriod.daily ? 'harian' : _selectedPeriod == AnalyticsPeriod.weekly ? 'mingguan' : 'bulanan'}',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppNumbers.paddingMedium),
                  child: Text('Produk Terlaris', style: Theme.of(context).textTheme.titleLarge),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppNumbers.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppNumbers.paddingMedium),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.shopping_bag, color: AppTheme.primaryColor),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      analytics.topProductName,
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Pendapatan Rp ${analytics.topProductRevenue.toStringAsFixed(0)}',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.trending_up, color: AppTheme.successColor),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppNumbers.paddingMedium),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Top 3 Produk Terlaris', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 14),
                              SizedBox(
                                height: 240,
                                child: analytics.productSales.isEmpty
                                    ? Center(
                                        child: Text('Belum ada data produk terlaris.', style: Theme.of(context).textTheme.bodyMedium),
                                      )
                                    : BarChart(_buildProductSalesBarChart(analytics.productSales.take(3).toList())),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const custom_widgets.LoadingWidget(message: 'Memuat analitik...'),
        error: (error, st) => custom_widgets.ErrorWidget(message: error.toString()),
      ),
    );
  }

  LineChartData _buildRevenueLineChart(List<DailyRevenue> chartData) {
    final spots = chartData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.revenue);
    }).toList();
    final maxRevenue = chartData.map((item) => item.revenue).fold<double>(0, (prev, value) => value > prev ? value : prev);
    final interval = maxRevenue > 0 ? maxRevenue / 4 : 1.0;

    return LineChartData(
      minX: 0,
      maxX: spots.isNotEmpty ? spots.last.x : 1,
      minY: 0,
      maxY: maxRevenue * 1.2,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: interval,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) => FlLine(color: AppTheme.dividerColor, strokeWidth: 1),
        getDrawingVerticalLine: (value) => FlLine(color: AppTheme.dividerColor, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            reservedSize: 40,
            getTitlesWidget: (value, meta) => _buildBottomTitleWidget(value, meta, chartData),
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: interval,
            reservedSize: 50,
            getTitlesWidget: (value, meta) => SideTitleWidget(
              axisSide: meta.axisSide,
              child: Text('Rp ${value.toInt()}', style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
            ),
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppTheme.primaryColor,
          barWidth: 3,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor.withValues(alpha: 0.2), AppTheme.primaryColor.withValues(alpha: 0.02)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomTitleWidget(double value, TitleMeta meta, List<DailyRevenue> chartData) {
    final index = value.toInt();
    if (index < 0 || index >= chartData.length) {
      return const SizedBox.shrink();
    }
    final label = chartData[index].date;
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
      ),
    );
  }

  BarChartData _buildProductSalesBarChart(List<ProductSales> salesData) {
    final highestRevenue = salesData.map((item) => item.revenue).fold<double>(0, (prev, revenue) => revenue > prev ? revenue : prev);

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: highestRevenue * 1.3,
      barTouchData: BarTouchData(enabled: true),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 56,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= salesData.length) return const SizedBox.shrink();
              final title = salesData[index].productName;
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(title, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
              );
            },
          ),
        ),
      ),
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: salesData.asMap().entries.map((entry) {
        final index = entry.key;
        final business = entry.value;
        return BarChartGroupData(
          x: index,
          barsSpace: 8,
          barRods: [
            BarChartRodData(
              toY: business.revenue,
              color: AppTheme.accentColor,
              width: 22,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        );
      }).toList(),
    );
  }

  List<DailyRevenue> _groupByWeek(List<DailyRevenue> dailyRevenue) {
    final grouped = <String, double>{};
    for (final item in dailyRevenue) {
      final date = DateTime.tryParse(item.date);
      final label = date != null ? 'Minggu ${((date.day - 1) ~/ 7) + 1}' : item.date;
      grouped[label] = (grouped[label] ?? 0) + item.revenue;
    }
    return grouped.entries
        .map((entry) => DailyRevenue(date: entry.key, revenue: entry.value, orders: 0))
        .toList();
  }

  List<DailyRevenue> _groupByMonth(List<DailyRevenue> dailyRevenue) {
    final grouped = <String, double>{};
    for (final item in dailyRevenue) {
      final date = DateTime.tryParse(item.date);
      final label = date != null ? '${date.month}/${date.year.toString().substring(2)}' : item.date;
      grouped[label] = (grouped[label] ?? 0) + item.revenue;
    }
    return grouped.entries
        .map((entry) => DailyRevenue(date: entry.key, revenue: entry.value, orders: 0))
        .toList();
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String growth;
  final String icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.growth,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppNumbers.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                Text(
                  icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              growth,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.successColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
