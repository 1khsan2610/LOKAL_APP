import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/order.dart';
import '../../providers/orders_provider.dart';
import '../../widgets/common/custom_widgets.dart' as custom_widgets;

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      appBar: const custom_widgets.CustomAppBar(
        title: 'Detail Pesanan',
        showBackButton: true,
      ),
      body: orderAsync.when(
        data: (order) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER PESANAN
                Container(
                  padding: const EdgeInsets.all(
                    AppNumbers.paddingMedium,
                  ),
                  color: AppTheme.primaryColor.withOpacity(0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nomor Pesanan',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color:
                                          AppTheme.textSecondary,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '#${order.id.substring(0, 8).toUpperCase()}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                          _StatusBadge(
                            status: order.status,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        order.createdAt
                            .toString()
                            .split(' ')[0],
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall,
                      ),
                    ],
                  ),
                ),

                // ITEM PESANAN
                Padding(
                  padding: const EdgeInsets.all(
                    AppNumbers.paddingMedium,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Item Pesanan',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium,
                      ),
                      const SizedBox(height: 12),

                      Card(
                        child: Column(
                          children: List.generate(
                            order.items.length,
                            (index) {
                              final item =
                                  order.items[index];

                              return Column(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.all(
                                      AppNumbers
                                          .paddingMedium,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration:
                                              BoxDecoration(
                                            color: AppTheme
                                                .dividerColor,
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                                        8),
                                          ),
                                          child: const Icon(
                                            Icons.image,
                                          ),
                                        ),

                                        const SizedBox(
                                            width: 12),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            children: [
                                              Text(
                                                item.name,
                                                style: Theme.of(
                                                        context)
                                                    .textTheme
                                                    .bodyMedium,
                                              ),

                                              const SizedBox(
                                                  height:
                                                      4),

                                              Text(
                                                'Qty: ${item.quantity}',
                                                style: Theme.of(
                                                        context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),

                                        Text(
                                          'Rp ${item.subtotal.toStringAsFixed(0)}',
                                          style:
                                              Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    fontWeight:
                                                        FontWeight
                                                            .w600,
                                                  ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  if (index <
                                      order.items.length -
                                          1)
                                    const Divider(
                                      height: 0,
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ALAMAT
                Padding(
                  padding: const EdgeInsets.all(
                    AppNumbers.paddingMedium,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alamat Pengiriman',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium,
                      ),
                      const SizedBox(height: 12),

                      Card(
                        child: Padding(
                          padding:
                              const EdgeInsets.all(
                            AppNumbers
                                .paddingMedium,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color:
                                    AppTheme.primaryColor,
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Text(
                                  order.shippingAddress ??
                                      'Tidak tersedia',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // METODE PEMBAYARAN
                Padding(
                  padding: const EdgeInsets.all(
                    AppNumbers.paddingMedium,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Metode Pembayaran',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium,
                      ),
                      const SizedBox(height: 12),

                      Card(
                        child: Padding(
                          padding:
                              const EdgeInsets.all(
                            AppNumbers
                                .paddingMedium,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.payment,
                                color:
                                    AppTheme.primaryColor,
                              ),

                              const SizedBox(width: 12),

                              Text(
                                _getPaymentMethodLabel(
                                  order.paymentMethod,
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // RINGKASAN
                Padding(
                  padding: const EdgeInsets.all(
                    AppNumbers.paddingMedium,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ringkasan Pesanan',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium,
                      ),
                      const SizedBox(height: 12),

                      Card(
                        child: Padding(
                          padding:
                              const EdgeInsets.all(
                            AppNumbers
                                .paddingMedium,
                          ),
                          child: Column(
                            children: [
                              _SummaryRow(
                                label: 'Subtotal',
                                amount:
                                    order.subtotal,
                              ),

                              _SummaryRow(
                                label: 'Pajak',
                                amount: order.tax,
                              ),

                              _SummaryRow(
                                label: 'Ongkir',
                                amount: order
                                    .shippingCost,
                              ),

                              const Divider(
                                height: 24,
                              ),

                              _SummaryRow(
                                label: 'Total',
                                amount: order.total,
                                isTotal: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height:
                      AppNumbers.paddingLarge,
                ),
              ],
            ),
          );
        },

        loading: () => const custom_widgets.LoadingWidget(
          message: 'Memuat detail pesanan...',
        ),

        error: (error, stackTrace) => custom_widgets.ErrorWidget(
          message: error.toString(),
        ),
      ),
    );
  }

  String _getPaymentMethodLabel(
    PaymentMethod? method,
  ) {
    if (method == null) {
      return 'Tidak tersedia';
    }

    switch (method) {
      case PaymentMethod.gopay:
        return 'GoPay';

      case PaymentMethod.ovo:
        return 'OVO';

      case PaymentMethod.dana:
        return 'DANA';

      case PaymentMethod.bank_transfer:
        return 'Transfer Bank';

      case PaymentMethod.qris:
        return 'QRIS';
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;

  const _StatusBadge({
    required this.status,
  });

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
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color:
            _getStatusColor().withOpacity(0.1),
        borderRadius:
            BorderRadius.circular(4),
      ),
      child: Text(
        _getStatusLabel(),
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(
              color: _getStatusColor(),
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.amount,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      fontWeight:
                          FontWeight.w600,
                    )
                : Theme.of(context)
                    .textTheme
                    .bodySmall,
          ),

          Text(
            'Rp ${amount.toStringAsFixed(0)}',
            style: isTotal
                ? Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      color:
                          AppTheme.primaryColor,
                      fontWeight:
                          FontWeight.w700,
                    )
                : Theme.of(context)
                    .textTheme
                    .bodySmall,
          ),
        ],
      ),
    );
  }
}