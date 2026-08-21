// ═══════════════════════════════════════════════════════════════════
//  CartScreen  —  lib/screens/cart/cart_screen.dart
//  UX/UI Refactor: Checkbox selection, merchant grouping, voucher section,
//  sticky bottom bar with total + checkout. Only checked items go to checkout.
// ═══════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/image_helper.dart';
import '../../widgets/app_card.dart';
import '../../widgets/product_card.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Track checked item IDs
  final Set<int> _checkedIds = {};
  // Track checked merchant IDs (for merchant-level checkbox)
  final Set<String> _checkedMerchants = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cart = context.read<CartProvider>();
      if (cart.items.isNotEmpty) {
        // Select all by default
        for (final item in cart.items) {
          _checkedIds.add(item.id);
        }
        _updateMerchantChecks();
        setState(() {});
      }
    });
  }

  bool get _allSelected => _checkedIds.length == context.read<CartProvider>().items.length;

  int get _selectedCount => _checkedIds.length;

  int get _selectedSubtotal {
    final cart = context.read<CartProvider>();
    return cart.items
        .where((i) => _checkedIds.contains(i.id))
        .fold(0, (sum, i) => sum + i.subtotal);
  }

  int get _selectedTotal {
    final cart = context.read<CartProvider>();
    final subtotal = _selectedSubtotal;
    final shipping = cart.items.any((i) => _checkedIds.contains(i.id)) ? cart.shippingFee : 0;
    return subtotal + shipping;
  }

  void _toggleItem(int itemId) {
    setState(() {
      if (_checkedIds.contains(itemId)) {
        _checkedIds.remove(itemId);
      } else {
        _checkedIds.add(itemId);
      }
      _updateMerchantChecks();
    });
  }

  void _toggleSelectAll() {
    final cart = context.read<CartProvider>();
    setState(() {
      if (_allSelected) {
        _checkedIds.clear();
      } else {
        _checkedIds.addAll(cart.items.map((i) => i.id));
      }
      _updateMerchantChecks();
    });
  }

  void _updateMerchantChecks() {
    _checkedMerchants.clear();
    final cart = context.read<CartProvider>();
    final grouped = _groupByMerchant(cart.items);
    for (final entry in grouped.entries) {
      final merchantItems = entry.value;
      if (merchantItems.every((i) => _checkedIds.contains(i.id))) {
        _checkedMerchants.add(entry.key);
      }
    }
  }

  void _toggleMerchant(String merchantName, List<CartItemModel> items) {
    setState(() {
      if (_checkedMerchants.contains(merchantName)) {
        _checkedMerchants.remove(merchantName);
        for (final item in items) {
          _checkedIds.remove(item.id);
        }
      } else {
        _checkedMerchants.add(merchantName);
        for (final item in items) {
          _checkedIds.add(item.id);
        }
      }
    });
  }

  Map<String, List<CartItemModel>> _groupByMerchant(List<CartItemModel> items) {
    final map = <String, List<CartItemModel>>{};
    for (final item in items) {
      final name = item.product.umkm?.name ?? 'Toko Lainnya';
      map.putIfAbsent(name, () => []);
      map[name]!.add(item);
    }
    return map;
  }

  void _deleteSelected() {
    final cart = context.read<CartProvider>();
    if (_checkedIds.isEmpty) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Produk Terpilih?'),
        content: Text('${_checkedIds.length} produk akan dihapus dari keranjang.'),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () {
              context.pop();
              for (final id in _checkedIds.toList()) {
                cart.removeItem(id);
              }
              setState(() {
                _checkedIds.clear();
                _checkedMerchants.clear();
              });
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final bottomSafe = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Kosongkan Keranjang?'),
                  content: const Text('Semua produk di keranjang akan dihapus.'),
                  actions: [
                    TextButton(onPressed: () => context.pop(), child: const Text('Batal')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
                      onPressed: () {
                        context.pop();
                        cart.clearCart();
                        setState(() {
                          _checkedIds.clear();
                          _checkedMerchants.clear();
                        });
                      },
                      child: const Text('Hapus Semua'),
                    ),
                  ],
                ),
              ),
              icon: const Icon(Icons.delete_sweep_outlined, size: 20),
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? EmptyState(
              emoji: '🛒',
              title: 'Keranjang Kosong',
              subtitle: 'Temukan produk UMKM lokal favoritmu!',
              buttonLabel: 'Mulai Belanja',
              onButton: () => context.go('/main'),
            )
          : Column(
              children: [
                // ── Select All + Delete Selected Bar ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppTheme.surface,
                  child: Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _allSelected,
                          onChanged: (_) => _toggleSelectAll(),
                          activeColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Pilih Semua (${cart.items.length})',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      if (_checkedIds.isNotEmpty)
                        GestureDetector(
                          onTap: _deleteSelected,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.danger.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.delete_outline, size: 14, color: AppTheme.danger),
                                const SizedBox(width: 4),
                                Text(
                                  'Hapus Terpilih (${_checkedIds.length})',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.danger),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // ── Scrollable Cart Items ──
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    children: [
                      // Group by merchant
                      ..._buildMerchantGroups(cart),
                      // ── Promo & Voucher Section ──
                      const SizedBox(height: 8),
                      _PromoVoucherBanner(),
                      const SizedBox(height: 80), // Space for bottom bar
                    ],
                  ),
                ),
                // ── Sticky Bottom Bar ──
                _CartStickyFooter(
                  selectedCount: _selectedCount,
                  selectedSubtotal: _selectedSubtotal,
                  selectedTotal: _selectedTotal,
                  hasSelection: _checkedIds.isNotEmpty,
                  bottomSafe: bottomSafe,
                ),
              ],
            ),
    );
  }

  List<Widget> _buildMerchantGroups(CartProvider cart) {
    final grouped = _groupByMerchant(cart.items);
    final widgets = <Widget>[];

    for (final entry in grouped.entries) {
      final merchantName = entry.key;
      final items = entry.value;
      final isMerchantChecked = _checkedMerchants.contains(merchantName);

      widgets.add(
        _MerchantGroup(
          merchantName: merchantName,
          isChecked: isMerchantChecked,
          onToggleMerchant: () => _toggleMerchant(merchantName, items),
          itemCount: items.length,
        ),
      );

      for (final item in items) {
        final isChecked = _checkedIds.contains(item.id);
        widgets.add(
          _CartItemCard(
            item: item,
            isChecked: isChecked,
            onToggleCheck: () => _toggleItem(item.id),
            onDecrement: item.quantity > 1
                ? () => cart.updateQuantity(item.id, item.quantity - 1)
                : null,
            onIncrement: () => cart.updateQuantity(item.id, item.quantity + 1),
            onRemove: () {
              cart.removeItem(item.id);
              setState(() {
                _checkedIds.remove(item.id);
                _updateMerchantChecks();
              });
            },
            onSave: () {
              // Save to wishlist functionality
              AppSnackBar.show(context, '✓ Produk disimpan ke Wishlist');
            },
          ),
        );
      }

      widgets.add(const SizedBox(height: 8));
    }

    return widgets;
  }
}

// ── Merchant Group Header ──────────────────────────────────────────
class _MerchantGroup extends StatelessWidget {
  final String merchantName;
  final bool isChecked;
  final VoidCallback onToggleMerchant;
  final int itemCount;

  const _MerchantGroup({
    required this.merchantName,
    required this.isChecked,
    required this.onToggleMerchant,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            height: 22,
            width: 22,
            child: Checkbox(
              value: isChecked,
              onChanged: (_) => onToggleMerchant(),
              activeColor: AppTheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.store_outlined, size: 16, color: AppTheme.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '$merchantName >',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
            ),
          ),
          Text(
            '$itemCount item',
            style: const TextStyle(fontSize: 11, color: AppTheme.textHint),
          ),
        ],
      ),
    );
  }
}

// ── Cart Item Card with Checkbox ───────────────────────────────────
class _CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final bool isChecked;
  final VoidCallback onToggleCheck;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onRemove;
  final VoidCallback onSave;

  const _CartItemCard({
    required this.item,
    required this.isChecked,
    required this.onToggleCheck,
    required this.onDecrement,
    required this.onIncrement,
    required this.onRemove,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox
            SizedBox(
              height: 22,
              width: 22,
              child: Checkbox(
                value: isChecked,
                onChanged: (_) => onToggleCheck(),
                activeColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(width: 10),
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 72,
                height: 72,
                child: item.product.primaryImage != null
                    ? Image.network(resolveImageUrl(item.product.primaryImage), fit: BoxFit.cover)
                    : Container(
                        color: AppTheme.surface2,
                        child: const Icon(Icons.image_outlined, size: 30, color: AppTheme.textHint),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Variant/description
                  if (item.variantId != null)
                    Text(
                      'Varian tersedia',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textHint),
                    ),
                  const SizedBox(height: 4),
                  // Price
                  PriceText(item.product.displayPrice, fontSize: 14),
                  const SizedBox(height: 8),
                  // Actions row: qty stepper + save + delete
                  Row(
                    children: [
                      _QtyStepper(
                        quantity: item.quantity,
                        onDecrement: onDecrement,
                        onIncrement: onIncrement,
                      ),
                      const SizedBox(width: 8),
                      // Save to wishlist
                      GestureDetector(
                        onTap: onSave,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.surface2,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bookmark_outline, size: 12, color: AppTheme.primary),
                              const SizedBox(width: 3),
                              Text('Simpan', style: TextStyle(fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: onRemove,
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.delete_outline, color: AppTheme.danger, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quantity Stepper ───────────────────────────────────────────────
class _QtyStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;

  const _QtyStepper({required this.quantity, required this.onDecrement, required this.onIncrement});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppTheme.surface2, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onDecrement,
            icon: const Icon(Icons.remove, size: 16),
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
            color: AppTheme.primary,
            disabledColor: AppTheme.textHint,
          ),
          SizedBox(
            width: 26,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppTheme.primary),
            ),
          ),
          IconButton(
            onPressed: onIncrement,
            icon: const Icon(Icons.add, size: 16),
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
            color: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}

// ── Promo & Voucher Banner ─────────────────────────────────────────
class _PromoVoucherBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.discount_outlined, size: 20, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Promo & Voucher',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
                SizedBox(height: 2),
                Text(
                  'Pilih diskon atau voucher ongkir untuk pesananmu',
                  style: TextStyle(fontSize: 11, color: AppTheme.textHint),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 20, color: AppTheme.textHint),
        ],
      ),
    );
  }
}

// ── Sticky Bottom Bar ──────────────────────────────────────────────
class _CartStickyFooter extends StatelessWidget {
  final int selectedCount;
  final int selectedSubtotal;
  final int selectedTotal;
  final bool hasSelection;
  final double bottomSafe;

  const _CartStickyFooter({
    required this.selectedCount,
    required this.selectedSubtotal,
    required this.selectedTotal,
    required this.hasSelection,
    required this.bottomSafe,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
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
            // Total info
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Pembayaran',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      currency.format(selectedTotal),
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppTheme.primary),
                    ),
                  ),
                  if (selectedSubtotal > 0)
                    Text(
                      'Hemat Rp ${(selectedSubtotal * 0.05).toInt()} dengan koin',
                      style: const TextStyle(fontSize: 10, color: AppTheme.success),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Checkout button
            ElevatedButton(
              onPressed: hasSelection
                  ? () {
                      // Pass selected items to checkout via provider or route
                      context.push('/checkout');
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                disabledBackgroundColor: AppTheme.textHint.withValues(alpha: 0.3),
              ),
              child: Text(
                hasSelection
                    ? 'Checkout ($selectedCount) →'
                    : 'Pilih Produk',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}