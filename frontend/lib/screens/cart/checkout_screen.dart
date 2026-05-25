import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/order.dart';
import '../../providers/orders_provider.dart';
import '../../widgets/common/custom_widgets.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _currentStep = 0;
  PaymentMethod? _selectedPaymentMethod;
  double _coinDiscount = 0;

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Checkout',
        showBackButton: true,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _currentStep < 2
            ? () => setState(() => _currentStep++)
            : null,
        onStepCancel:
            _currentStep > 0 ? () => setState(() => _currentStep--) : null,
        steps: [
          // Step 1: Review Items
          Step(
            title: const Text('Review Pesanan'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: cartState.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              'Qty: ${item.quantity}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Rp ${item.subtotal.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            isActive: _currentStep >= 0,
          ),

          // Step 2: Payment Method
          Step(
            title: const Text('Metode Pembayaran'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PaymentMethodOption(
                  title: 'GoPay',
                  icon: '📱',
                  isSelected: _selectedPaymentMethod == PaymentMethod.gopay,
                  onSelect: () => setState(
                    () => _selectedPaymentMethod = PaymentMethod.gopay,
                  ),
                ),
                const SizedBox(height: 8),
                _PaymentMethodOption(
                  title: 'OVO',
                  icon: '🟠',
                  isSelected: _selectedPaymentMethod == PaymentMethod.ovo,
                  onSelect: () =>
                      setState(() => _selectedPaymentMethod = PaymentMethod.ovo),
                ),
                const SizedBox(height: 8),
                _PaymentMethodOption(
                  title: 'DANA',
                  icon: '💜',
                  isSelected: _selectedPaymentMethod == PaymentMethod.dana,
                  onSelect: () =>
                      setState(() => _selectedPaymentMethod = PaymentMethod.dana),
                ),
                const SizedBox(height: 8),
                _PaymentMethodOption(
                  title: 'Transfer Bank',
                  icon: '🏦',
                  isSelected:
                      _selectedPaymentMethod == PaymentMethod.bank_transfer,
                  onSelect: () => setState(
                    () =>
                        _selectedPaymentMethod = PaymentMethod.bank_transfer,
                  ),
                ),
                const SizedBox(height: 8),
                _PaymentMethodOption(
                  title: 'QRIS',
                  icon: '📲',
                  isSelected: _selectedPaymentMethod == PaymentMethod.qris,
                  onSelect: () =>
                      setState(() => _selectedPaymentMethod = PaymentMethod.qris),
                ),
                const SizedBox(height: 16),
                // Coin discount slider
                Text(
                  'Gunakan Lokal Coin (Max 20%)',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Slider(
                  value: _coinDiscount,
                  min: 0,
                  max: 0.2,
                  divisions: 20,
                  label: '${(_coinDiscount * 100).toStringAsFixed(0)}%',
                  onChanged: (value) {
                    setState(() => _coinDiscount = value);
                    ref
                        .read(cartProvider.notifier)
                        .setCoinDiscount(_coinDiscount);
                  },
                ),
              ],
            ),
            isActive: _currentStep >= 1,
          ),

          // Step 3: Confirmation
          Step(
            title: const Text('Konfirmasi'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryRow(
                  label: 'Subtotal',
                  amount: cartState.subtotal,
                ),
                _SummaryRow(
                  label: 'Pajak (10%)',
                  amount: cartState.tax,
                ),
                _SummaryRow(
                  label: 'Ongkir',
                  amount: cartState.shippingCost,
                ),
                if (cartState.coinDiscount > 0)
                  _SummaryRow(
                    label: 'Diskon Lokal Coin',
                    amount: -cartState.discountAmount,
                    color: AppTheme.successColor,
                  ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Rp ${cartState.total.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
      bottomNavigationBar: _currentStep == 2
          ? Container(
            padding: const EdgeInsets.all(AppNumbers.paddingMedium),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedPaymentMethod != null
                    ? () => _handlePlaceOrder(ref, context)
                    : null,
                child: const Text('Lanjutkan ke Pembayaran'),
              ),
            ),
          )
          : null,
    );
  }

  void _handlePlaceOrder(WidgetRef ref, BuildContext context) {
    // Create order
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pesanan dibuat! Redirect ke Midtrans...')),
    );
    Navigator.pushNamed(context, '/order-confirmation');
  }
}

class _PaymentMethodOption extends StatelessWidget {
  final String title;
  final String icon;
  final bool isSelected;
  final VoidCallback onSelect;

  const _PaymentMethodOption({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        padding: const EdgeInsets.all(AppNumbers.paddingMedium),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppNumbers.smallBorderRadius),
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.05)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color? color;

  const _SummaryRow({
    required this.label,
    required this.amount,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(
            'Rp ${amount.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
