// ═══════════════════════════════════════════════════════════════════
//  Komponen-komponen halaman Beranda (versi rewrite no-orange)
// ═══════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../utils/image_helper.dart';
import '../models/product_model.dart';
import '../providers/wishlist_provider.dart';

// ─────────────────────────────────────────────────────────────────
//  Kategori Populer Card (Modern Pastel Soft)
// ─────────────────────────────────────────────────────────────────
class CategorySoftCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const CategorySoftCard({
    super.key,
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.iconColor,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : bgColor,
                borderRadius: BorderRadius.circular(16),
                border: isSelected
                    ? Border.all(color: AppTheme.primary, width: 2)
                    : null,
              ),
              child: Icon(
                icon,
                size: 26,
                color: isSelected ? Colors.white : iconColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Banner Promo (FIX OVERFLOW — no fixed height)
// ─────────────────────────────────────────────────────────────────
class PromoBanner extends StatelessWidget {
  final String badgeLabel;
  final String title;
  final String buttonLabel;
  final VoidCallback onButtonTap;
  final Color gradientStart;
  final Color gradientEnd;

  const PromoBanner({
    super.key,
    required this.badgeLabel,
    required this.title,
    required this.buttonLabel,
    required this.onButtonTap,
    this.gradientStart = const Color(0xFF1966D2),
    this.gradientEnd = const Color(0xFF4285F4),
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 28 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradientStart, gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badgeLabel,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: isDesktop ? 24 : 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          // Button
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: onButtonTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  buttonLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  UMKM Nearby Card (Horizontal List)
// ─────────────────────────────────────────────────────────────────
class UmkmNearbyCard extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double rating;
  final double distance;
  final VoidCallback onTap;

  const UmkmNearbyCard({
    super.key,
    required this.name,
    this.imageUrl,
    required this.rating,
    required this.distance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner image
            Container(
              height: 80,
              width: double.infinity,
              color: AppTheme.surface2,
              child: imageUrl != null
                  ? (imageUrl!.startsWith('assets/')
                      ? Image.asset(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            child: Icon(Icons.store_rounded, color: AppTheme.primary.withValues(alpha: 0.3)),
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: resolveImageUrl(imageUrl!),
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            child: Icon(Icons.store_rounded, color: AppTheme.primary.withValues(alpha: 0.3)),
                          ),
                        ))
                  : Icon(Icons.store_rounded, color: AppTheme.primary.withValues(alpha: 0.3)),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB300)),
                      const SizedBox(width: 2),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.location_on_rounded,
                        size: 12,
                        color: AppTheme.textHint,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${distance.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textHint,
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

// ─────────────────────────────────────────────────────────────────
//  Product Card for Home Grid (New Design)
// ─────────────────────────────────────────────────────────────────
class HomeProductCard extends StatelessWidget {
  final ProductModel product;

  const HomeProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final wishlist = context.watch<WishlistProvider>();
    final isFavorite = wishlist.isFavorite(product.id);

    // Determine category badge
    String? catLabel;
    Color? catBg;
    Color? catFg;
    switch (product.category) {
      case 'makanan':
        catLabel = 'MAKANAN';
        catBg = const Color(0xFFFFF0ED);
        catFg = const Color(0xFFE53935);
        break;
      case 'minuman':
        catLabel = 'MINUMAN';
        catBg = const Color(0xFFEBF3FE);
        catFg = const Color(0xFF1966D2);
        break;
      case 'fashion':
        catLabel = 'FASHION';
        catBg = const Color(0xFFF3E8FF);
        catFg = const Color(0xFF8E24AA);
        break;
      case 'kerajinan':
        catLabel = 'KRIYA';
        catBg = const Color(0xFFFFF8E1);
        catFg = const Color(0xFFFFA000);
        break;
      case 'bahan_pokok':
        catLabel = 'POKOK';
        catBg = const Color(0xFFE6F4EA);
        catFg = const Color(0xFF2E7D32);
        break;
    }

    return GestureDetector(
      onTap: () => context.push('/product/detail/${product.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Expanded(
              child: Stack(
                children: [
                  // Image
                  product.primaryImage != null
                      ? CachedNetworkImage(
                          imageUrl: resolveImageUrl(product.primaryImage),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (_, __) => Container(color: AppTheme.surface2),
                          errorWidget: (_, __, ___) => Container(
                            color: AppTheme.surface2,
                            child: const Icon(Icons.image_not_supported_outlined, color: AppTheme.textHint),
                          ),
                        )
                      : Container(
                          color: AppTheme.surface2,
                          child: const Center(child: Text('📦', style: TextStyle(fontSize: 32))),
                        ),

                  // Category badge
                  if (catLabel != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: catBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          catLabel,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: catFg,
                          ),
                        ),
                      ),
                    ),

                  // Floating Love Icon (Wishlist)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => context.read<WishlistProvider>().toggleFavorite(product),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 15,
                          color: isFavorite ? AppTheme.danger : AppTheme.textHint,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currency.format(product.price),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1966D2),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 12, color: Color(0xFFFFB300)),
                      const SizedBox(width: 2),
                      Text(
                        product.avgRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_formatSold(product.soldCount)} terjual',
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppTheme.textHint,
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

  String _formatSold(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}K' : '$n';
}

// ─────────────────────────────────────────────────────────────────
//  Top Greeting Header (Interactive — all elements clickable)
// ─────────────────────────────────────────────────────────────────
class GreetingHeader extends StatelessWidget {
  final String userName;
  final int saldoCoin;
  final String? profileImage;

  const GreetingHeader({
    super.key,
    required this.userName,
    this.saldoCoin = 0,
    this.profileImage,
  });

  void _showLocationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text('Pilih Lokasi / Kota',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Cari kota atau daerah...',
                  prefixIcon: Icon(Icons.search_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                onChanged: (v) {
                  // filter logic placeholder
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _locTile(ctx, '📍', 'Bandung Kota', 'Jawa Barat'),
                    _locTile(ctx, '📍', 'Cimahi', 'Jawa Barat'),
                    _locTile(ctx, '📍', 'Kab. Bandung', 'Jawa Barat'),
                    _locTile(ctx, '📍', 'Sumedang', 'Jawa Barat'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _locTile(BuildContext context, String emoji, String city, String province) {
    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 20)),
      title: Text(city, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(province, style: const TextStyle(fontSize: 12, color: AppTheme.textHint)),
      trailing: const Icon(Icons.chevron_right, size: 18, color: AppTheme.textHint),
      contentPadding: EdgeInsets.zero,
      onTap: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Row
        Row(
          children: [
            // Location — TAP TO CHANGE CITY
            GestureDetector(
              onTap: () => _showLocationPicker(context),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 18,
                    color: Color(0xFF1966D2),
                  ),
                  const SizedBox(width: 4),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bandung Kota',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Ekonomi Lokal',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.textHint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppTheme.textHint),
                ],
              ),
            ),
            const Spacer(),
            // Pill Balance — TAP TO WALLET
            GestureDetector(
              onTap: () => context.push('/wallet'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF3FE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.monetization_on_rounded,
                      size: 14,
                      color: Color(0xFF1966D2),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Rp ${saldoCoin >= 1000 ? '${(saldoCoin / 1000).toStringAsFixed(1)}K' : saldoCoin}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1966D2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Notification Bell — TAP TO NOTIFICATIONS
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded, size: 22, color: AppTheme.textPrimary),
                  onPressed: () => context.push('/notifications'),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  splashRadius: 18,
                ),
                // Red dot badge (simulate unread)
                Positioned(
                  right: 2, top: 2,
                  child: Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.danger,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            // Profile Avatar — TAP TO PROFILE
            GestureDetector(
              onTap: () {
                // Navigate to profile tab (index 4 or profile page)
                context.push('/main?tab=profile');
              },
              child: CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF1966D2),
                backgroundImage: profileImage != null
                    ? CachedNetworkImageProvider(resolveImageUrl(profileImage!))
                    : null,
                child: profileImage == null
                    ? const Icon(Icons.person, size: 18, color: Colors.white)
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Greeting Sub-Header
        Text(
          'Halo, $userName! 👋',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Siap dukung UMKM lokal hari ini?',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Section Header
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
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      if (showAll && onSeeAll != null)
        TextButton(
          onPressed: onSeeAll,
          child: const Text(
            'Lihat semua →',
            style: TextStyle(
              color: AppTheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
    ],
  );
}