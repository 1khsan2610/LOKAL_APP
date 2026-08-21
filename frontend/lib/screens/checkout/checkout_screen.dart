// ═══════════════════════════════════════════════════════════════════
//  CheckoutScreen  —  lib/screens/checkout/checkout_screen.dart
//  UX/UI Refactor: Better sections, scroll fix (bottom padding 120),
//  responsive layout, proper sticky footer.
// ═══════════════════════════════════════════════════════════════════
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../../models/product_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/image_helper.dart';
import '../../widgets/app_card.dart';
import '../../widgets/product_card.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _api = ApiService();
  final currency =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  List<AddressModel> _addresses = [];
  AddressModel? _selectedAddress;
  String _selectedShipping = 'jne_reg';
  String _selectedPayment = 'bca';
  bool _useCoin = false;
  bool _isPlacing = false;
  bool _isLoading = true;

  final _shippingOptions = [
    {'id': 'jne_reg', 'name': 'JNE Reguler', 'est': '2-3 hari', 'price': 10000},
    {'id': 'jne_yes', 'name': 'JNE YES (1 Hari)', 'est': '1 hari', 'price': 20000},
    {'id': 'jt', 'name': 'J&T Express', 'est': '2-3 hari', 'price': 9000},
    {'id': 'sicepat', 'name': 'SiCepat', 'est': '2-3 hari', 'price': 9500},
  ];

  final _paymentMethods = [
    {'id': 'bca', 'label': 'BCA Transfer', 'icon': '🏦'},
    {'id': 'mandiri', 'label': 'Mandiri', 'icon': '🟡'},
    {'id': 'gopay', 'label': 'GoPay', 'icon': '💚'},
    {'id': 'ovo', 'label': 'OVO', 'icon': '🟣'},
    {'id': 'dana', 'label': 'DANA', 'icon': '🔵'},
    {'id': 'qris', 'label': 'QRIS', 'icon': '📷'},
  ];

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    try {
      final resp = await _api.getAddresses();
      setState(() {
        _addresses = (resp.data['data'] as List)
            .map((e) => AddressModel.fromJson(e))
            .toList();
        _selectedAddress = _addresses.firstWhere((a) => a.isDefault,
            orElse: () => _addresses.first);
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  int get _shippingFee =>
      (_shippingOptions.firstWhere((s) => s['id'] == _selectedShipping)['price'] as int);

  int get _coinDiscount {
    if (!_useCoin) return 0;
    final wallet = context.read<AuthProvider>().user?.wallet;
    final balance = (wallet?.coinBalance ?? 0) * 10;
    final cart = context.read<CartProvider>();
    final maxDisc = (cart.subtotal * 0.2).floor();
    return balance < maxDisc ? balance : maxDisc;
  }

  int get _total {
    final cart = context.read<CartProvider>();
    return cart.subtotal + _shippingFee - _coinDiscount;
  }

  Future<void> _placeOrder() async {
    if (_selectedAddress == null) {
      AppSnackBar.show(context, '⚠️ Pilih alamat pengiriman terlebih dahulu', isError: true);
      return;
    }
    setState(() => _isPlacing = true);

    final cart = context.read<CartProvider>();
    int? orderId;
    try {
      final orderResp = await _api.createOrder({
        'address_id': _selectedAddress!.id,
        'shipping_method': _selectedShipping,
        'use_coin': _useCoin,
        'items': cart.items
            .map((i) => {
                  'product_id': i.productId,
                  'quantity': i.quantity,
                  if (i.variantId != null) 'variant_id': i.variantId,
                })
            .toList(),
      });

      orderId = orderResp.data['data']['id'] as int?;
      final order = OrderModel.fromJson(orderResp.data['data']);

      final payResp = await _api.createPayment(order.id, paymentMethod: _selectedPayment);
      final snapToken = payResp.data['data']['snap_token'] as String? ?? '';
      final snapUrl = payResp.data['data']['snap_url'] as String? ?? '';

      if (!mounted) return;
      context.push('/payment?snap_token=$snapToken&snap_url=${Uri.encodeComponent(snapUrl)}&order_id=${order.id}&total=$_total');
    } on DioException catch (e) {
      if (orderId != null) {
        try { await _api.cancelOrder(orderId); } catch (_) {}
      }
      if (!mounted) return;
      var message = 'Gagal membuat pesanan. Coba lagi.';
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        if (data['errors'] != null) {
          final errors = data['errors'];
          if (errors is Map) {
            final messages = errors.values
                .expand((value) => value is List ? value : [value])
                .map((value) => value.toString())
                .toList();
            if (messages.isNotEmpty) message = messages.join(' ');
          } else if (errors is List) {
            message = errors.join(' ');
          } else if (errors is String) {
            message = errors;
          }
        } else if (data['message'] is String) {
          message = data['message'] as String;
        } else if (data['error_messages'] != null) {
          final errors = data['error_messages'];
          if (errors is List) {
            message = errors.join(' ');
          } else if (errors is String) {
            message = errors;
          }
        }
      }
      AppSnackBar.show(context, message, isError: true);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(context, 'Gagal membuat pesanan. Coba lagi.', isError: true);
    } finally {
      if (mounted) setState(() => _isPlacing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final wallet = context.watch<AuthProvider>().user?.wallet;
    final bottomSafe = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Checkout')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    // ⚠️ FIX SCROLL BUG: Add large bottom padding so content
                    // is not hidden behind the sticky "Bayar Sekarang" button
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 140),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Alamat Pengiriman ──
                        _Section(
                          title: '📍 Alamat Pengiriman',
                          child: _addresses.isEmpty
                              ? _emptyAddress()
                              : Column(children: [
                                  ..._addresses.map((a) => _AddressOption(
                                        address: a,
                                        selected: _selectedAddress?.id == a.id,
                                        onTap: () => setState(() => _selectedAddress = a),
                                      )),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton.icon(
                                      onPressed: () => context.push('/profile/addresses/form')
                                          .then((_) => _loadAddresses()),
                                      icon: const Icon(Icons.add, size: 16),
                                      label: const Text('+ Tambah Alamat Baru'),
                                    ),
                                  ),
                                ]),
                        ),

                        // ── Ringkasan Pesanan ──
                        _Section(
                          title: '📋 Ringkasan Pesanan',
                          child: Column(children: [
                            ...cart.items.map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: SizedBox(
                                        width: 50, height: 50,
                                        child: item.product.primaryImage != null
                                            ? Image.network(resolveImageUrl(item.product.primaryImage), fit: BoxFit.cover)
                                            : Container(color: AppTheme.surface2, child: const Icon(Icons.image_outlined)),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item.product.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                          Text('${item.quantity}x · ${item.product.umkm?.name ?? ""}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    PriceText(item.subtotal, fontSize: 13),
                                  ]),
                                )),
                          ]),
                        ),

                        // ── Metode Pengiriman ──
                        _Section(
                          title: '🚚 Metode Pengiriman',
                          child: Column(
                            children: _shippingOptions
                                .map((s) => _ShippingOption(
                                      data: s,
                                      selected: _selectedShipping == s['id'],
                                      onTap: () => setState(() => _selectedShipping = s['id'] as String),
                                    ))
                                .toList(),
                          ),
                        ),

                        // ── Metode Pembayaran ──
                        _Section(
                          title: '💳 Metode Pembayaran',
                          child: Column(children: [
                            LayoutBuilder(builder: (context, c) {
                              return GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                childAspectRatio: c.maxWidth / 2 / 44,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                children: _paymentMethods
                                    .map((m) => _PaymentOption(
                                          data: m,
                                          selected: _selectedPayment == m['id'],
                                          onTap: () => setState(() => _selectedPayment = m['id'] as String),
                                        ))
                                    .toList(),
                              );
                            }),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.surface2,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(children: [
                                Icon(Icons.lock_outlined, size: 14, color: AppTheme.textHint),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Pembayaran aman diproses oleh Midtrans',
                                    style: TextStyle(fontSize: 11, color: AppTheme.textHint),
                                  ),
                                ),
                              ]),
                            ),
                          ]),
                        ),

                        // ── Lokal Coin ──
                        _Section(
                          title: '🪙 Lokal Coin',
                          child: Row(children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Saldo: ${wallet?.coinBalance ?? 0} Coin',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis),
                                  Text('≈ ${currency.format((wallet?.coinBalance ?? 0) * 10)} diskon',
                                      style: const TextStyle(fontSize: 11, color: AppTheme.textHint),
                                      overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            Switch(
                              value: _useCoin,
                              activeThumbColor: AppTheme.primary,
                              onChanged: (v) => setState(() => _useCoin = v),
                            ),
                          ]),
                        ),

                        // ── Ringkasan Biaya ──
                        _Section(
                          title: '💰 Ringkasan Biaya',
                          child: Column(children: [
                            _SumRow('Subtotal Produk', currency.format(cart.subtotal)),
                            _SumRow('Ongkos Kirim', currency.format(_shippingFee)),
                            if (_useCoin && _coinDiscount > 0)
                              _SumRow('Potongan Diskon', '-${currency.format(_coinDiscount)}', isGreen: true),
                            const Divider(height: 16),
                            _SumRow('Total Bayar', currency.format(_total), isBold: true),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
                // ── Sticky Footer: Bayar Sekarang ──
                _CheckoutStickyFooter(
                  total: _total,
                  currency: currency,
                  isPlacing: _isPlacing,
                  onPay: _placeOrder,
                  bottomSafe: bottomSafe,
                ),
              ],
            ),
    );
  }

  Widget _emptyAddress() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          const Icon(Icons.location_off_outlined, size: 40, color: AppTheme.textHint),
          const SizedBox(height: 8),
          const Text(
            'Belum ada alamat pengiriman',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => context.push('/profile/addresses/form')
                .then((_) => _loadAddresses()),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('+ Tambah Alamat Pengiriman'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sticky Footer ──
class _CheckoutStickyFooter extends StatelessWidget {
  final int total;
  final NumberFormat currency;
  final bool isPlacing;
  final VoidCallback onPay;
  final double bottomSafe;

  const _CheckoutStickyFooter({
    required this.total,
    required this.currency,
    required this.isPlacing,
    required this.onPay,
    required this.bottomSafe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomSafe),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Bayar', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      currency.format(total),
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppTheme.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: isPlacing ? null : onPay,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              child: isPlacing
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Text('Bayar Sekarang 🔒', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section wrapper ──
class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      );
}

class _AddressOption extends StatelessWidget {
  final AddressModel address;
  final bool selected;
  final VoidCallback onTap;
  const _AddressOption({required this.address, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          decoration: BoxDecoration(
            color: selected ? AppTheme.surface2 : AppTheme.surface,
            border: Border.all(color: selected ? AppTheme.primary : AppTheme.border, width: selected ? 2 : 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(address.recipientName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        Text(address.phone, style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
                        if (address.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.surface2,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppTheme.primary),
                            ),
                            child: const Text('Utama',
                                style: TextStyle(fontSize: 9, color: AppTheme.primary, fontWeight: FontWeight.w700)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(address.fullAddress, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              if (selected) const Icon(Icons.check_circle, color: AppTheme.primary, size: 20),
            ],
          ),
        ),
      );
}

class _ShippingOption extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool selected;
  final VoidCallback onTap;
  const _ShippingOption({required this.data, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        width: double.infinity,
        decoration: BoxDecoration(
          color: selected ? AppTheme.surface2 : AppTheme.surface,
          border: Border.all(color: selected ? AppTheme.primary : AppTheme.border, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['name'], overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  Text('Estimasi ${data['est']}', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(currency.format(data['price']),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primary)),
          ],
        ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool selected;
  final VoidCallback onTap;
  const _PaymentOption({required this.data, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppTheme.surface2 : AppTheme.surface,
            border: Border.all(color: selected ? AppTheme.primary : AppTheme.border, width: selected ? 2 : 1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            children: [
              Text(data['icon'] as String, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  data['label'] as String,
                  style: TextStyle(fontSize: 12, fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
}

class _SumRow extends StatelessWidget {
  final String label, value;
  final bool isGreen, isBold;
  const _SumRow(this.label, this.value, {this.isGreen = false, this.isBold = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.w700 : FontWeight.w400, color: AppTheme.textSecondary)),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                  color: isGreen ? AppTheme.success : (isBold ? AppTheme.primary : AppTheme.textPrimary),
                ),
              ),
            ),
          ],
        ),
      );
}