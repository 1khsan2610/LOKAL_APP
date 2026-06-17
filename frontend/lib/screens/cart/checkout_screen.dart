import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/order.dart';
import '../../providers/orders_provider.dart';
import '../../widgets/common/custom_widgets.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _currentStep = 0;
  PaymentMethod? _selectedPaymentMethod;
  double _coinDiscount = 0;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Checkout',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Stepper
            Padding(
              padding: const EdgeInsets.all(AppNumbers.paddingMedium),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StepBadge(
                    number: 1,
                    title: 'Review',
                    isActive: _currentStep >= 0,
                    isCompleted: _currentStep > 0,
                  ),
                  Container(
                    height: 2,
                    width: 50,
                    color: _currentStep > 0 
                        ? AppTheme.primaryColor 
                        : AppTheme.dividerColor,
                  ),
                  _StepBadge(
                    number: 2,
                    title: 'Pembayaran',
                    isActive: _currentStep >= 1,
                    isCompleted: _currentStep > 1,
                  ),
                  Container(
                    height: 2,
                    width: 50,
                    color: _currentStep > 1
                        ? AppTheme.primaryColor
                        : AppTheme.dividerColor,
                  ),
                  _StepBadge(
                    number: 3,
                    title: 'Konfirmasi',
                    isActive: _currentStep >= 2,
                    isCompleted: _currentStep > 2,
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppNumbers.paddingMedium,
                  vertical: AppNumbers.paddingSmall,
                ),
                child: _buildCurrentStep(context, cartState),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppNumbers.paddingMedium),
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading
                      ? null
                      : () => setState(() => _currentStep--),
                  child: const Text('Kembali'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: AppNumbers.paddingSmall),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleNextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        _currentStep == 2 ? 'Bayar Sekarang' : 'Lanjutkan',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context, CartState cartState) {
    switch (_currentStep) {
      case 0:
        return _buildOrderSummary(context, cartState);
      case 1:
        return _buildPaymentMethodSelection(context);
      case 2:
        return _buildPaymentConfirmation(context, cartState);
      default:
        return const SizedBox();
    }
  }

  Widget _buildOrderSummary(BuildContext context, CartState cartState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Items Review
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
                  'Ringkasan Pesanan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ...cartState.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              'x${item.quantity}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Rp ${(item.subtotal / 1000).toStringAsFixed(1)}k',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
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
        const SizedBox(height: 16),
        // Price Breakdown
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
                  'Rincian Harga',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _PriceRow(
                  label: 'Subtotal',
                  amount: cartState.subtotal,
                ),
                _PriceRow(
                  label: 'Pajak (10%)',
                  amount: cartState.tax,
                ),
                _PriceRow(
                  label: 'Ongkir',
                  amount: cartState.shippingCost,
                ),
                const Divider(height: 12),
                _PriceRow(
                  label: 'Total',
                  amount: cartState.total,
                  isTotal: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPaymentMethodSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Metode Pembayaran',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        // Payment method options
        _PaymentMethodCard(
          method: PaymentMethod.gopay,
          title: 'GoPay',
          icon: '🅿️',
          description: 'Pembayaran digital GoPay',
          selected: _selectedPaymentMethod == PaymentMethod.gopay,
          onSelect: () =>
              setState(() => _selectedPaymentMethod = PaymentMethod.gopay),
        ),
        const SizedBox(height: 12),
        _PaymentMethodCard(
          method: PaymentMethod.ovo,
          title: 'OVO',
          icon: '🔵',
          description: 'Pembayaran digital OVO',
          selected: _selectedPaymentMethod == PaymentMethod.ovo,
          onSelect: () =>
              setState(() => _selectedPaymentMethod = PaymentMethod.ovo),
        ),
        const SizedBox(height: 12),
        _PaymentMethodCard(
          method: PaymentMethod.dana,
          title: 'DANA',
          icon: '💳',
          description: 'Pembayaran digital DANA',
          selected: _selectedPaymentMethod == PaymentMethod.dana,
          onSelect: () =>
              setState(() => _selectedPaymentMethod = PaymentMethod.dana),
        ),
        const SizedBox(height: 12),
        _PaymentMethodCard(
          method: PaymentMethod.bank_transfer,
          title: 'Transfer Bank',
          icon: '🏦',
          description: 'Transfer bank virtual account',
          selected: _selectedPaymentMethod == PaymentMethod.bank_transfer,
          onSelect: () => setState(
              () => _selectedPaymentMethod = PaymentMethod.bank_transfer),
        ),
        const SizedBox(height: 12),
        _PaymentMethodCard(
          method: PaymentMethod.qris,
          title: 'QRIS',
          icon: '📱',
          description: 'Scan kode QR untuk pembayaran',
          selected: _selectedPaymentMethod == PaymentMethod.qris,
          onSelect: () =>
              setState(() => _selectedPaymentMethod = PaymentMethod.qris),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPaymentConfirmation(BuildContext context, CartState cartState) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppNumbers.paddingLarge),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withAlpha((255 * 0.1).round()),
            borderRadius: BorderRadius.circular(AppNumbers.borderRadius),
          ),
          child: const Icon(
            Icons.check_circle_outline,
            size: 80,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: AppNumbers.paddingLarge),
        Text(
          'Konfirmasi Pesanan',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppNumbers.paddingSmall),
        Text(
          'Mohon verifikasi detail pesanan Anda sebelum melanjutkan pembayaran',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppNumbers.paddingLarge),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppNumbers.borderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppNumbers.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Metode Pembayaran',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      _selectedPaymentMethod?.toString().split('.').last ?? '-',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Rp ${(cartState.total / 1000).toStringAsFixed(1)}k',
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
        const SizedBox(height: 24),
      ],
    );
  }

  void _handleNextStep() {
    if (_currentStep == 1 && _selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih metode pembayaran terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_currentStep == 2) {
      _processPayment();
      return;
    }

    setState(() => _currentStep++);
  }

  void _processPayment() async {
    setState(() => _isLoading = true);

    try {
      final cartState = ref.read(cartProvider);
      final order = await ref.read(ordersProvider.notifier).createOrder(
        items: cartState.items
            .map((item) => OrderItem(
          productId: item.product.id,
          productName: item.product.name,
          price: item.product.price,
          quantity: item.quantity,
        ))
            .toList(),
        subtotal: cartState.subtotal,
        tax: cartState.tax,
        shippingCost: cartState.shippingCost,
        coinUsed: cartState.coinDiscount,
        paymentMethod: _selectedPaymentMethod!,
      );

      ref.read(cartProvider.notifier).clearCart();

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/payment',
          (route) => route.isFirst,
          arguments: order,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _StepBadge extends StatelessWidget {
  final int number;
  final String title;
  final bool isActive;
  final bool isCompleted;

  const _StepBadge({
    required this.number,
    required this.title,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive || isCompleted
                ? AppTheme.primaryColor
                : AppTheme.dividerColor,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
              '$number',
              style: TextStyle(
                color: isActive ? Colors.white : AppTheme.textHint,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;
  final String title;
  final String icon;
  final String description;
  final bool selected;
  final VoidCallback onSelect;

  const _PaymentMethodCard({
    required this.method,
    required this.title,
    required this.icon,
    required this.description,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      child: Card(
        elevation: selected ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? AppTheme.primaryColor : AppTheme.dividerColor,
            width: selected ? 2 : 1,
          ),
        ),
        color: selected
            ? AppTheme.primaryColor.withAlpha((255 * 0.05).round())
            : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(AppNumbers.paddingMedium),
          child: Row(
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryColor,
                  size: 24,
                )
              else
                const Icon(
                  Icons.radio_button_unchecked,
                  color: AppTheme.dividerColor,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isTotal;

  const _PriceRow({
    required this.label,
    required this.amount,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight:
                  isTotal ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          Text(
            'Rp ${(amount / 1000).toStringAsFixed(1)}k',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
              color: isTotal ? AppTheme.primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }
}
