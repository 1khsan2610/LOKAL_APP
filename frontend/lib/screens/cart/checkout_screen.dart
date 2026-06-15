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
            Padding(
              padding: const EdgeInsets.all(AppNumbers.paddingMedium),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StepBadge(
                    title: 'Review',
                    isActive: _currentStep >= 0,
                    isCompleted: _currentStep > 0,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Divider(color: AppTheme.dividerColor, thickness: 1),
                  ),
                  const SizedBox(width: 4),
                  _StepBadge(
                    title: 'Pembayaran',
                    isActive: _currentStep >= 1,
                    isCompleted: _currentStep > 1,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Divider(color: AppTheme.dividerColor, thickness: 1),
                  ),
                  const SizedBox(width: 4),
                  _StepBadge(
                    title: 'Konfirmasi',
                    isActive: _currentStep >= 2,
                    isCompleted: _currentStep > 2,
                  ),
                ],
              ),
            ),
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
                onPressed: _isLoading
                    ? null
                    : () {
                        if (_currentStep == 1 && _selectedPaymentMethod == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pilih metode pembayaran terlebih dahulu'),
                            ),
                          );
                          return;
                        }
                        if (_currentStep < 2) {
                          setState(() => _currentStep++);
                        } else {
                          _handlePlaceOrder(ref, context, cartState);
                        }
                      },
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(_currentStep < 2 ? 'Lanjutkan' : 'Bayar Sekarang'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context, CartState cartState) {
    switch (_currentStep) {
      case 1:
        return _buildPaymentSelection(context, cartState);
      case 2:
        return _buildConfirmation(context, cartState);
      default:
        return _buildReview(context, cartState);
    }
  }

  Widget _buildReview(BuildContext context, CartState cartState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review Pesanan',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: AppNumbers.paddingMedium),
        ...cartState.items.map((item) {
          return Card(
            margin: const EdgeInsets.only(bottom: AppNumbers.paddingSmall),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppNumbers.borderRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppNumbers.paddingMedium),
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.dividerColor,
                      borderRadius: BorderRadius.circular(AppNumbers.smallBorderRadius),
                    ),
                    child: const Icon(Icons.image, size: 32, color: AppTheme.textHint),
                  ),
                  const SizedBox(width: AppNumbers.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Qty ${item.quantity}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Rp ${item.subtotal.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: AppNumbers.paddingMedium),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppNumbers.borderRadius),
          ),
          elevation: AppNumbers.elevationSmall,
          child: Padding(
            padding: const EdgeInsets.all(AppNumbers.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Info Lokal Coin',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppNumbers.paddingSmall),
                Text(
                  'Gunakan Lokal Coin di langkah pembayaran untuk mendapatkan diskon hingga 20%',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSelection(BuildContext context, CartState cartState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Metode Pembayaran',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: AppNumbers.paddingMedium),
        Wrap(
          runSpacing: AppNumbers.paddingSmall,
          spacing: AppNumbers.paddingSmall,
          children: [
            _PaymentMethodOption(
              title: 'GoPay',
              icon: '📱',
              isSelected: _selectedPaymentMethod == PaymentMethod.gopay,
              onSelect: () => setState(() => _selectedPaymentMethod = PaymentMethod.gopay),
            ),
            _PaymentMethodOption(
              title: 'OVO',
              icon: '🟠',
              isSelected: _selectedPaymentMethod == PaymentMethod.ovo,
              onSelect: () => setState(() => _selectedPaymentMethod = PaymentMethod.ovo),
            ),
            _PaymentMethodOption(
              title: 'DANA',
              icon: '💜',
              isSelected: _selectedPaymentMethod == PaymentMethod.dana,
              onSelect: () => setState(() => _selectedPaymentMethod = PaymentMethod.dana),
            ),
            _PaymentMethodOption(
              title: 'Transfer Bank',
              icon: '🏦',
              isSelected: _selectedPaymentMethod == PaymentMethod.bank_transfer,
              onSelect: () => setState(() => _selectedPaymentMethod = PaymentMethod.bank_transfer),
            ),
            _PaymentMethodOption(
              title: 'QRIS',
              icon: '📲',
              isSelected: _selectedPaymentMethod == PaymentMethod.qris,
              onSelect: () => setState(() => _selectedPaymentMethod = PaymentMethod.qris),
            ),
          ],
        ),
        const SizedBox(height: AppNumbers.paddingLarge),
        Text(
          'Gunakan Lokal Coin (Maks 20%)',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: AppNumbers.paddingSmall),
        Slider(
          value: _coinDiscount,
          min: 0,
          max: 0.2,
          divisions: 20,
          label: '${(_coinDiscount * 100).toStringAsFixed(0)}%',
          onChanged: (value) {
            setState(() => _coinDiscount = value);
            ref.read(cartProvider.notifier).setCoinDiscount(value);
          },
        ),
        const SizedBox(height: AppNumbers.paddingSmall),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Diskon yang Dipakai',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '${(_coinDiscount * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppNumbers.paddingLarge),
        if (_selectedPaymentMethod == null)
          Text(
            'Pilih metode pembayaran untuk melanjutkan ke langkah berikutnya.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
      ],
    );
  }

  Widget _buildConfirmation(BuildContext context, CartState cartState) {
    final selectedMethodLabel = _selectedPaymentMethod != null
        ? _formatPaymentMethod(_selectedPaymentMethod!)
        : 'Belum dipilih';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Konfirmasi Pesanan',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: AppNumbers.paddingMedium),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppNumbers.borderRadius),
          ),
          elevation: AppNumbers.elevationSmall,
          child: Padding(
            padding: const EdgeInsets.all(AppNumbers.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Metode Pembayaran',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppNumbers.paddingSmall),
                Text(selectedMethodLabel,
                    style: Theme.of(context).textTheme.bodyMedium),
                const Divider(height: AppNumbers.paddingLarge),
                _SummaryRow(label: 'Subtotal', amount: cartState.subtotal),
                _SummaryRow(label: 'Pajak 10%', amount: cartState.tax),
                _SummaryRow(label: 'Ongkir', amount: cartState.shippingCost),
                if (cartState.coinDiscount > 0)
                  _SummaryRow(
                    label: 'Diskon Lokal Coin',
                    amount: -cartState.discountAmount,
                    color: AppTheme.successColor,
                  ),
                const Divider(height: AppNumbers.paddingLarge),
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
                      'Rp ${cartState.total.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppNumbers.paddingSmall),
                Text(
                  'Setelah bayar di halaman berikutnya, Anda akan menerima notifikasi jika pembayaran berhasil atau gagal.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatPaymentMethod(PaymentMethod method) {
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

  Future<void> _handlePlaceOrder(
    WidgetRef ref,
    BuildContext context,
    CartState cartState,
  ) async {
    if (_selectedPaymentMethod == null) return;
    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final order = await ref.read(ordersProvider.notifier).createOrder(
            items: cartState.items
                .map(
                  (item) => OrderItem(
                    productId: item.product.id,
                    productName: item.product.name,
                    price: item.product.price,
                    quantity: item.quantity,
                    productImage: item.product.images.isNotEmpty ? item.product.images.first : null,
                  ),
                )
                .toList(),
            subtotal: cartState.subtotal,
            tax: cartState.tax,
            shippingCost: cartState.shippingCost,
            coinUsed: cartState.discountAmount,
            paymentMethod: _selectedPaymentMethod!,
          );

      ref.read(cartProvider.notifier).clearCart();

      if (!mounted) return;
      navigator.pushNamed(
        '/order-confirmation',
        arguments: order,
      );
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Gagal membuat pesanan: ${error.toString()}'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _StepBadge extends StatelessWidget {
  final String title;
  final bool isActive;
  final bool isCompleted;

  const _StepBadge({
    required this.title,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCompleted
        ? AppTheme.primaryColor
        : isActive
            ? AppTheme.primaryColor
            : AppTheme.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: isCompleted
            ? AppTheme.primaryColor.withAlpha((255 * 0.12).round())
            : isActive
                ? AppTheme.primaryColor.withAlpha((255 * 0.08).round())
                : AppTheme.dividerColor,
        borderRadius: BorderRadius.circular(AppNumbers.smallBorderRadius),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppNumbers.paddingSmall,
        vertical: AppNumbers.paddingXSmall,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
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
              ? AppTheme.primaryColor.withAlpha((255 * 0.05).round())
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
