import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/order.dart';
import '../../providers/orders_provider.dart';
import '../../widgets/common/custom_widgets.dart' as custom_widgets;

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      appBar: custom_widgets.CustomAppBar(title: 'Riwayat Pesanan'),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return custom_widgets.EmptyStateWidget(
              icon: '📋',
              title: 'Belum ada pesanan',
              message: 'Mulai belanja untuk melihat pesanan Anda di sini',
              actionLabel: 'Mulai Belanja',
              onAction: () => Navigator.pushNamed(context, '/products'),
            );
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return OrderCard(order: order);
            },
          );
        },
        loading: () => const custom_widgets.LoadingWidget(message: 'Memuat pesanan...'),
        error: (error, st) => custom_widgets.ErrorWidget(message: error.toString()),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/order-detail',
        arguments: order.id,
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: AppNumbers.paddingMedium,
          vertical: 8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppNumbers.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pesanan #${order.id.substring(0, 8).toUpperCase()}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.createdAt.toString().split(' ')[0],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  _StatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              // Items summary
              Text(
                '${order.items.length} item',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Rp ${order.total.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;

  const _StatusBadge({required this.status});

  Color _getStatusColor() {
    switch (status) {
      case OrderStatus.pending:
        return AppTheme.warningColor;
      case OrderStatus.confirmed:
      case OrderStatus.processing:
        return AppTheme.infoColor;
      case OrderStatus.shipped:
        return AppTheme.primaryColor;
      case OrderStatus.delivered:
        return AppTheme.successColor;
      case OrderStatus.cancelled:
      case OrderStatus.refunded:
        return AppTheme.errorColor;
    }
  }

  String _getStatusLabel() {
    switch (status) {
      case OrderStatus.pending:
        return 'Menunggu';
      case OrderStatus.confirmed:
        return 'Dikonfirmasi';
      case OrderStatus.processing:
        return 'Diproses';
      case OrderStatus.shipped:
        return 'Dikirim';
      case OrderStatus.delivered:
        return 'Diterima';
      case OrderStatus.cancelled:
        return 'Dibatalkan';
      case OrderStatus.refunded:
        return 'Dikembalikan';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _getStatusLabel(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: _getStatusColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
