import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/order.dart';
import '../../providers/orders_provider.dart';
import '../../widgets/common/custom_widgets.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  String _selectedFilter = 'semua';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ordersProvider.notifier).fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Pesanan Saya',
        showBackButton: false,
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.all(AppNumbers.paddingMedium),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Semua',
                    value: 'semua',
                    selected: _selectedFilter == 'semua',
                    onSelected: () => setState(() => _selectedFilter = 'semua'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Pending',
                    value: 'pending',
                    selected: _selectedFilter == 'pending',
                    onSelected: () => setState(() => _selectedFilter = 'pending'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Diproses',
                    value: 'processing',
                    selected: _selectedFilter == 'processing',
                    onSelected: () => setState(() => _selectedFilter = 'processing'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Dikirim',
                    value: 'shipped',
                    selected: _selectedFilter == 'shipped',
                    onSelected: () => setState(() => _selectedFilter = 'shipped'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Selesai',
                    value: 'delivered',
                    selected: _selectedFilter == 'delivered',
                    onSelected: () => setState(() => _selectedFilter = 'delivered'),
                  ),
                ],
              ),
            ),
          ),
          // Orders list
          Expanded(
            child: ordersAsync.when(
              data: (orders) {
                if (orders.isEmpty) {
                  return EmptyStateWidget(
                    icon: '📦',
                    title: 'Belum ada pesanan',
                    message: 'Mulai berbelanja sekarang untuk membuat pesanan pertama Anda',
                    actionLabel: 'Mulai Belanja',
                    onAction: () => Navigator.pushNamed(context, '/products'),
                  );
                }

                final filteredOrders = _filterOrders(orders, _selectedFilter);

                if (filteredOrders.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada pesanan dengan status $_selectedFilter',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppNumbers.paddingMedium),
                  itemCount: filteredOrders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _OrderCard(
                        order: filteredOrders[index],
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/order-detail',
                          arguments: filteredOrders[index],
                        ),
                      ),
                );
              },
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Gagal memuat pesanan',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Order> _filterOrders(List<Order> orders, String filter) {
    if (filter == 'semua') return orders;
    return orders
        .where((order) => order.status.toString().split('.').last == filter)
        .toList();
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor : Colors.transparent,
          border: Border.all(
            color: selected ? AppTheme.primaryColor : AppTheme.dividerColor,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: selected ? Colors.white : AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);
    final statusLabel = _getStatusLabel(order.status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppNumbers.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with order ID and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pesanan #${order.id.substring(0, 8).toUpperCase()}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(order.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha((255 * 0.2).round()),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              // Items preview
              Text(
                '${order.items.length} item',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              ...order.items.take(2).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• ${item.productName} x${item.quantity}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )),
              if (order.items.length > 2)
                Text(
                  '• +${order.items.length - 2} item lainnya',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              // Footer with price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Rp ${(order.totalPrice / 1000).toStringAsFixed(1)}k',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
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

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.processing:
        return Colors.purple;
      case OrderStatus.shipped:
        return Colors.cyan;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.refunded:
        return Colors.grey;
    }
  }

  String _getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Dikonfirmasi';
      case OrderStatus.processing:
        return 'Diproses';
      case OrderStatus.shipped:
        return 'Dikirim';
      case OrderStatus.delivered:
        return 'Terima';
      case OrderStatus.cancelled:
        return 'Dibatalkan';
      case OrderStatus.refunded:
        return 'Refund';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Hari ini';
    } else if (diff.inDays == 1) {
      return 'Kemarin';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari yang lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class OrderStatusScreen extends ConsumerWidget {
  const OrderStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final order = args is Order ? args : null;

    if (order == null) {
      return Scaffold(
        appBar: CustomAppBar(title: 'Status Pesanan'),
        body: const Center(child: Text('Pesanan tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Status Pesanan',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppNumbers.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppNumbers.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nomor Pesanan',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '#${order.id.substring(0, 8).toUpperCase()}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status Pesanan',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withAlpha((255 * 0.2).round()),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _getStatusLabel(order.status),
                                style:
                                    Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Total Pembayaran',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rp ${(order.totalPrice / 1000).toStringAsFixed(1)}k',
                              style: Theme.of(context)
                                  .textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Order Timeline
            Text(
              'Riwayat Pesanan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _OrderTimeline(order: order),
            const SizedBox(height: 24),
            // Items Summary
            Text(
              'Ringkasan Pesanan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppNumbers.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme.bodyMedium,
                                ),
                                Text(
                                  'x${item.quantity}',
                                  style: Theme.of(context)
                                      .textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Rp ${(item.subtotal / 1000).toStringAsFixed(1)}k',
                            style: Theme.of(context)
                                .textTheme.bodyMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/orders',
                  (route) => route.isFirst,
                ),
                child: const Text('Kembali ke Pesanan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Dikonfirmasi';
      case OrderStatus.processing:
        return 'Diproses';
      case OrderStatus.shipped:
        return 'Dikirim';
      case OrderStatus.delivered:
        return 'Terterima';
      case OrderStatus.cancelled:
        return 'Dibatalkan';
      case OrderStatus.refunded:
        return 'Refund';
    }
  }
}

class _OrderTimeline extends StatelessWidget {
  final Order order;

  const _OrderTimeline({required this.order});

  @override
  Widget build(BuildContext context) {
    final statuses = [
      OrderStatus.pending,
      OrderStatus.processing,
      OrderStatus.shipped,
      OrderStatus.delivered,
    ];

    final currentStatusIndex =
        statuses.indexWhere((s) => s == order.status);

    return Column(
      children: List.generate(
        statuses.length,
        (index) {
          final isCompleted = index <= currentStatusIndex;
          final isCurrent = index == currentStatusIndex;
          final status = statuses[index];

          return Column(
            children: [
              Row(
                children: [
                  // Timeline dot
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? AppTheme.primaryColor
                          : AppTheme.dividerColor,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      )
                          : Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isCompleted
                              ? Colors.white
                              : AppTheme.textHint,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Status label
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getStatusLabel(status),
                          style: Theme.of(context)
                              .textTheme.titleSmall
                              ?.copyWith(
                            fontWeight: isCurrent
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isCurrent
                                ? AppTheme.primaryColor
                                : null,
                          ),
                        ),
                        if (isCurrent) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Sekarang',
                            style: Theme.of(context)
                                .textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (index < statuses.length - 1)
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Container(
                    width: 2,
                    height: 30,
                    color: isCompleted
                        ? AppTheme.primaryColor
                        : AppTheme.dividerColor,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pesanan Dibuat';
      case OrderStatus.confirmed:
        return 'Dikonfirmasi';
      case OrderStatus.processing:
        return 'Dipersiapkan';
      case OrderStatus.shipped:
        return 'Dalam Perjalanan';
      case OrderStatus.delivered:
        return 'Terima';
      case OrderStatus.cancelled:
        return 'Dibatalkan';
      case OrderStatus.refunded:
        return 'Refund';
    }
  }
}
