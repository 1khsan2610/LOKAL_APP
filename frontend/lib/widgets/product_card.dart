import 'custom_button.dart';
// ═══════════════════════════════════════════════════════════════════
//  SHARED WIDGETS
//  File: lib/widgets/  (semua widget diimport dari sini)
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../utils/image_helper.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../models/product_model.dart';
import '../providers/wishlist_provider.dart';
import '../utils/app_theme.dart';

// ─────────────────────────────────────────────────────────────────
//  ProductCard
// ─────────────────────────────────────────────────────────────────
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isFlashSale;
  final double? width;

  const ProductCard({
    super.key,
    required this.product,
    this.isFlashSale = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final wishlist = context.watch<WishlistProvider>();
    final isFavorite = wishlist.isFavorite(product.id);

    return GestureDetector(
      onTap: () => context.push('/product/detail/${product.id}'),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Image
          Stack(children: [
            AspectRatio(
              aspectRatio: 1,
              child: product.primaryImage != null
                  ? CachedNetworkImage(
                      imageUrl: resolveImageUrl(product.primaryImage),
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: AppTheme.surface2,
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary))),
                      errorWidget: (_, __, ___) => Container(color: AppTheme.surface2,
                        child: const Icon(Icons.image_not_supported_outlined, color: AppTheme.textHint, size: 40)),
                    )
                  : Container(color: AppTheme.surface2,
                      child: const Center(child: Text('📦', style: TextStyle(fontSize: 40)))),
            ),
            // Badge
            if (product.badge != null)
              Positioned(top: 8, left: 8, child: _Badge(text: product.badge!)),
            // Wishlist
            Positioned(
              top: 8, right: 8,
              child: GestureDetector(
                onTap: () async {
                  await context.read<WishlistProvider>().toggleFavorite(product);
                },
                child: Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
                  child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, size: 16, color: isFavorite ? AppTheme.danger : AppTheme.textSecondary),
                ),
              ),
            ),
            // Flash sale overlay
            if (isFlashSale && product.flashSaleDiscount != null)
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  color: Colors.red.withValues(alpha: 0.85),
                  child: Text(
                    '⚡ -${product.flashSaleDiscount}% OFF',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ]),

          // Info
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.3)),
              const SizedBox(height: 3),
              Text(product.umkm?.name ?? '',
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
              const SizedBox(height: 6),
              if (isFlashSale && product.flashSalePrice != null) ...[
                Text(currency.format(product.flashSalePrice),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                Text(currency.format(product.price),
                  style: const TextStyle(fontSize: 11, color: AppTheme.textHint, decoration: TextDecoration.lineThrough)),
              ] else
                Text(currency.format(product.price),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.primary)),
              const SizedBox(height: 5),
              Row(children: [
                const Icon(Icons.star_rounded, size: 13, color: AppTheme.warning),
                const SizedBox(width: 2),
                Text(product.avgRating.toStringAsFixed(1), style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                const Spacer(),
                Text('${_formatSold(product.soldCount)} terjual', style: const TextStyle(fontSize: 10, color: AppTheme.textHint)),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  String _formatSold(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}K' : '$n';

  String? get badge {
    if (product.hasFlashSale) return null;
    if (product.soldCount > 200) return 'hot';
    if (product.soldCount < 20)  return 'new';
    return null;
  }
}

extension _ProductBadge on ProductModel {
  String? get badge {
    if (hasFlashSale) return null;
    if (soldCount > 200) return 'hot';
    if (soldCount < 20)  return 'new';
    return null;
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});
  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (text) {
      'hot'   => ('🔥 Hot',   const Color(0xFFFEE2E2), const Color(0xFFB91C1C)),
      'new'   => ('✨ Baru',  const Color(0xFFDCFCE7), const Color(0xFF15803D)),
      'promo' => ('🏷️ Promo', const Color(0xFFFEF3C7), const Color(0xFF92400E)),
      _       => (text,       AppTheme.surface2,       AppTheme.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  CustomButton
// ─────────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  final bool showAll;

  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
    this.showAll = true,
  });

  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
    ),
    if (showAll && onSeeAll != null)
      TextButton(
        onPressed: onSeeAll,
        child: const Text('Lihat semua →',
          style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
  ]);
}

// ─────────────────────────────────────────────────────────────────
//  ShimmerLoader
// ─────────────────────────────────────────────────────────────────
class ShimmerProductGrid extends StatelessWidget {
  const ShimmerProductGrid({super.key});

  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2, childAspectRatio: 0.68,
      crossAxisSpacing: 12, mainAxisSpacing: 12,
    ),
    itemCount: 6,
    itemBuilder: (_, __) => const _ShimmerCard(),
  );
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: Colors.grey.shade200,
    highlightColor: Colors.grey.shade50,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AspectRatio(aspectRatio: 1, child: Container(color: Colors.grey.shade200)),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(height: 13, width: double.infinity, color: Colors.grey.shade200),
            const SizedBox(height: 6),
            Container(height: 11, width: 100, color: Colors.grey.shade200),
            const SizedBox(height: 8),
            Container(height: 15, width: 80, color: Colors.grey.shade200),
          ]),
        ),
      ]),
    ),
  );
}

class ShimmerListItem extends StatelessWidget {
  const ShimmerListItem({super.key});

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: Colors.grey.shade200,
    highlightColor: Colors.grey.shade50,
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(children: [
        Container(width: 64, height: 64, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(height: 13, width: double.infinity, color: Colors.grey.shade200),
          const SizedBox(height: 6),
          Container(height: 11, width: 120, color: Colors.grey.shade200),
          const SizedBox(height: 6),
          Container(height: 14, width: 80, color: Colors.grey.shade200),
        ])),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────
//  AppSnackBar helper
// ─────────────────────────────────────────────────────────────────
class AppSnackBar {
  static void show(BuildContext ctx, String msg, {bool isError = false}) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppTheme.danger : AppTheme.primaryDark,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }
}

// ─────────────────────────────────────────────────────────────────
//  PriceText helper
// ─────────────────────────────────────────────────────────────────
class PriceText extends StatelessWidget {
  final int amount;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;

  const PriceText(this.amount, {
    super.key,
    this.fontSize = 15,
    this.fontWeight = FontWeight.w700,
    this.color = AppTheme.primary,
  });

  @override
  Widget build(BuildContext context) => Text(
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount),
    style: TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color),
  );
}

// ─────────────────────────────────────────────────────────────────
//  StatusBadge
// ─────────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      'pending'          => ('⏳ Menunggu',    const Color(0xFFFEF3C7), const Color(0xFF92400E)),
      'awaiting_payment' => ('💳 Bayar',       const Color(0xFFDBEAFE), const Color(0xFF1E40AF)),
      'processing'       => ('📦 Dikemas',     const Color(0xFFE0E7FF), const Color(0xFF3730A3)),
      'shipped'          => ('🚚 Dikirim',     const Color(0xFFD1FAE5), const Color(0xFF065F46)),
      'delivered'        => ('✅ Diterima',    const Color(0xFFDCFCE7), const Color(0xFF15803D)),
      'cancelled'        => ('❌ Dibatalkan',  const Color(0xFFFEE2E2), const Color(0xFFB91C1C)),
      _                  => (status,            AppTheme.surface2,       AppTheme.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  EmptyState
// ─────────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String? subtitle;
  final String? buttonLabel;
  final VoidCallback? onButton;

  const EmptyState({
    super.key,
    required this.emoji,
    required this.title,
    this.subtitle,
    this.buttonLabel,
    this.onButton,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(emoji, style: const TextStyle(fontSize: 56)),
        const SizedBox(height: 14),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(subtitle!, style: const TextStyle(fontSize: 13, color: AppTheme.textHint), textAlign: TextAlign.center),
        ],
        if (buttonLabel != null && onButton != null) ...[
          const SizedBox(height: 20),
          CustomButton(label: buttonLabel!, onPressed: onButton),
        ],
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────
//  CoinBadge
// ─────────────────────────────────────────────────────────────────
class CoinBadge extends StatelessWidget {
  final int amount;
  const CoinBadge({super.key, required this.amount});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF9C4), borderRadius: BorderRadius.circular(7),
      border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      const Text('🪙', style: TextStyle(fontSize: 12)),
      const SizedBox(width: 3),
      Text('+$amount Coin', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFB45309))),
    ]),
  );
}
