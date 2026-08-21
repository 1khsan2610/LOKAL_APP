import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/home_components.dart';
import '../../utils/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCategory;

  final List<Map<String, dynamic>> _categories = [
    {'id': 'makanan',     'icon': Icons.restaurant_rounded,     'label': 'Makanan',     'bg': const Color(0xFFFFF0ED), 'fg': const Color(0xFFE53935)},
    {'id': 'minuman',     'icon': Icons.local_cafe_rounded,     'label': 'Minuman',     'bg': const Color(0xFFEBF3FE), 'fg': const Color(0xFF1966D2)},
    {'id': 'fashion',     'icon': Icons.checkroom_rounded,      'label': 'Fashion',     'bg': const Color(0xFFF3E8FF), 'fg': const Color(0xFF8E24AA)},
    {'id': 'kerajinan',   'icon': Icons.palette_rounded,        'label': 'Kerajinan',   'bg': const Color(0xFFFFF8E1), 'fg': const Color(0xFFFFA000)},
    {'id': 'bahan_pokok', 'icon': Icons.shopping_basket_rounded, 'label': 'Bahan Pokok', 'bg': const Color(0xFFE6F4EA), 'fg': const Color(0xFF2E7D32)},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final prod = context.watch<ProductProvider>();
    final auth = context.watch<AuthProvider>();
    final role = auth.user?.role ?? 'konsumen';
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPad = screenWidth > 600 ? 60.0 : 16.0;
    final isDesktop = screenWidth > 900;
    final gridCols = isDesktop ? 4 : (screenWidth > 600 ? 3 : 2);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: () => context.read<ProductProvider>().loadProducts(refresh: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              left: horizontalPad,
              right: horizontalPad,
              top: 16,
              bottom: MediaQuery.of(context).viewPadding.bottom + 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── A. Greeting Header ──────────────────────────────
                GreetingHeader(
                  userName: auth.user?.name.split(' ').first ?? 'Budi',
                  saldoCoin: auth.user?.wallet?.coinBalance ?? 25000,
                  profileImage: auth.user?.avatar,
                ),
                const SizedBox(height: 20),

                // ── B. Search Bar ────────────────────────────────────
                Material(
                  elevation: 2,
                  shadowColor: Colors.black.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(30),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () => context.push('/search'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(children: [
                        const Icon(Icons.search_rounded, size: 20, color: AppTheme.textHint),
                        const SizedBox(width: 10),
                        const Text(
                          'Cari produk UMKM lokal...',
                          style: TextStyle(fontSize: 14, color: AppTheme.textHint),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('🔍', style: TextStyle(fontSize: 12)),
                        ),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── C. Banner Promo (FIX OVERFLOW) ──────────────────
                PromoBanner(
                  badgeLabel: 'PROMO KOMUNITAS',
                  title: 'Lokal Coin 2x Reward!',
                  buttonLabel: 'Ambil Sekarang',
                  onButtonTap: () => context.push('/wallet'),
                ),
                const SizedBox(height: 24),

                // ── D. Kategori Populer ─────────────────────────────
                const SectionHeader(title: '🗂️ Kategori Populer', showAll: false),
                const SizedBox(height: 12),
                SizedBox(
                  height: 80,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _categories.map((c) {
                      final sel = _selectedCategory == c['id'];
                      return CategorySoftCard(
                        icon: c['icon'],
                        label: c['label'],
                        bgColor: c['bg'],
                        iconColor: c['fg'],
                        isSelected: sel,
                        onTap: () {
                          setState(() => _selectedCategory = c['id']);
                          context.read<ProductProvider>().loadProducts(
                            category: c['id'],
                            refresh: true,
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // ── E. UMKM Terdekat ────────────────────────────────
                const SectionHeader(title: '📍 UMKM Terdekat', showAll: false),
                const SizedBox(height: 12),
                SizedBox(
                  height: 150,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      UmkmNearbyCard(
                        name: 'Bu Sari - Bakso Aci Spesial',
                        imageUrl: 'assets/images/bakso-aci.jpg',
                        rating: 4.8,
                        distance: 0.5,
                        onTap: () => context.push('/umkm/detail/1'),
                      ),
                      UmkmNearbyCard(
                        name: 'Kopi Lokal Bandung',
                        imageUrl: 'assets/images/cofee-latte.png',
                        rating: 4.6,
                        distance: 0.8,
                        onTap: () => context.push('/umkm/detail/2'),
                      ),
                      UmkmNearbyCard(
                        name: 'Batikkuh Cihampelas',
                        imageUrl: 'assets/images/kemeja.png',
                        rating: 4.9,
                        distance: 1.2,
                        onTap: () => context.push('/umkm/detail/3'),
                      ),
                      UmkmNearbyCard(
                        name: 'Tahu Susu Lembang',
                        imageUrl: 'assets/images/beras.jpeg',
                        rating: 4.7,
                        distance: 1.5,
                        onTap: () => context.push('/umkm/detail/4'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── F. Produk Unggulan (Grid Responsive) ────────────
                if (role != 'umkm') ...[
                  SectionHeader(
                    title: _selectedCategory == null
                        ? '🔥 Produk Unggulan'
                        : '📦 ${_categories.firstWhere((c) => c["id"] == _selectedCategory)["label"]}',
                    onSeeAll: () => context.read<ProductProvider>().loadMore(),
                  ),
                  const SizedBox(height: 12),

                  if (prod.isLoading && prod.products.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primary,
                        ),
                      ),
                    )
                  else if (prod.products.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🔍', style: TextStyle(fontSize: 48)),
                            SizedBox(height: 10),
                            Text(
                              'Produk tidak ditemukan',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridCols,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: prod.products.length + (prod.hasMore ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (i == prod.products.length) {
                          context.read<ProductProvider>().loadMore();
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primary,
                              ),
                            ),
                          );
                        }
                        return HomeProductCard(product: prod.products[i]);
                      },
                    ),
                ] else ...[
                  // ── UMKM Dashboard Preview ──────────────────────────
                  const SectionHeader(title: '📊 Dashboard Toko', showAll: false),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: _quickActionTile(
                        Icons.inventory_2_outlined,
                        'Tambah Produk',
                        () => context.push('/umkm/products/form'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _quickActionTile(
                        Icons.list_alt_outlined,
                        'Pesanan Masuk',
                        () => context.push('/umkm/orders'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _quickActionTile(
                        Icons.bar_chart_outlined,
                        'Laporan',
                        () => context.push('/umkm/analytics'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _quickActionTile(
                        Icons.settings_outlined,
                        'Pengaturan',
                        () => context.push('/umkm/store-settings'),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF3FE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.store_rounded, color: AppTheme.primary, size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Halo, pemilik UMKM — gunakan tautan di atas untuk mengelola toko Anda.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickActionTile(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: AppTheme.primary),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}