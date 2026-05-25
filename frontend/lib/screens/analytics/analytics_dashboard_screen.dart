import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/umkm_provider.dart';
import '../../widgets/common/custom_widgets.dart' as custom_widgets;

class AnalyticsDashboardScreen extends ConsumerWidget {
  final String umkmId;

  const AnalyticsDashboardScreen({
    Key? key,
    required this.umkmId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(umkmAnalyticsProvider(umkmId));

    return Scaffold(
      appBar: custom_widgets.CustomAppBar(
        title: 'Dashboard Analitik',
        showBackButton: true,
      ),
      body: analyticsAsync.when(
        data: (analytics) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
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
                        growth: '+5%',
                        icon: '📦',
                      ),
                      _MetricCard(
                        title: 'Pelanggan',
                        value: '${analytics.totalCustomers}',
                        growth: '+12%',
                        icon: '👥',
                      ),
                      _MetricCard(
                        title: 'Rating',
                        value: '${analytics.averageRating.toStringAsFixed(1)}',
                        growth: 'bintang',
                        icon: '⭐',
                      ),
                    ],
                  ),
                ),

                // Product Terlaris
                Padding(
                  padding: const EdgeInsets.all(AppNumbers.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Produk Terlaris',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppNumbers.paddingMedium),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.shopping_bag),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      analytics.topProductName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rp ${analytics.topProductRevenue.toStringAsFixed(0)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppTheme.primaryColor,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.trending_up,
                                  color: AppTheme.successColor),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Chart placeholder
                Padding(
                  padding: const EdgeInsets.all(AppNumbers.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Grafik Penjualan',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: AppTheme.dividerColor,
                            borderRadius:
                                BorderRadius.circular(AppNumbers.borderRadius),
                          ),
                          child: Center(
                            child: Text(
                              'Chart akan ditampilkan di sini\n(fl_chart)',
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
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
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
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
