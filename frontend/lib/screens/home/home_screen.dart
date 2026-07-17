import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:go_router/go_router.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/home_components.dart';
import '../../widgets/dashboard_components.dart';
import '../../utils/app_theme.dart';
import '../../utils/responsive_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bannerIdx = 0;
  String? _selectedCategory;
  final CarouselSliderController _carouselCtrl = CarouselSliderController();

  final List<Map<String, dynamic>> _banners = [
    {'title': 'Lokal Coin\n2x Reward! 🪙', 'subtitle': 'Kumpulkan coin setiap pembelian', 'color1': const Color(0xFF92400E), 'color2': const Color(0xFFF59E0B), 'emoji': '🪙', 'route': '/wallet'},
    {'title': 'UMKM\ndi Sekitarmu 📍', 'subtitle': 'Belanja langsung dari pengusaha lokal', 'color1': AppTheme.primary, 'color2': const Color(0xFF3B4E6B), 'emoji': '🗺️', 'route': '/map'},
  ];

  final List<Map<String, dynamic>> _categories = [
    {'id': null,          'icon': '🏪', 'label': 'Semua'},
    {'id': 'makanan',     'icon': '🍜', 'label': 'Makanan'},
    {'id': 'minuman',     'icon': '☕', 'label': 'Minuman'},
    {'id': 'fashion',     'icon': '👗', 'label': 'Fashion'},
    {'id': 'kerajinan',   'icon': '🧺', 'label': 'Kerajinan'},
    {'id': 'bahan_pokok', 'icon': '🌾', 'label': 'Bahan Pokok'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts(refresh: true);
      context.read<ProductProvider>().loadFlashSale();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prod = context.watch<ProductProvider>();
    final auth = context.watch<AuthProvider>();
    final role = auth.user?.role ?? 'konsumen';

    return Scaffold(
      backgroundColor: AppTheme.bg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: RichText(text: const TextSpan(
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
          children: [
            TextSpan(text: 'Ekonomi'),
            TextSpan(text: 'Lokal', style: TextStyle(color: AppTheme.accent)),
          ],
        )),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.chat_outlined),
            onPressed: () => context.push('/chats'),
            tooltip: 'Pesan',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () => context.read<ProductProvider>().loadProducts(refresh: true),
        // LayoutBuilder di root body: seluruh keputusan responsif (jumlah
        // kolom grid, rasio aspek kartu, padding) diturunkan dari lebar
        // konstrain aktual — bukan diasumsikan dari MediaQuery layar penuh.
        // Ini penting saat HomeScreen dipakai di dalam layout ber-panel
        // (mis. tablet dua kolom) di mana lebarnya lebih kecil dari layar.
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final crossAxisCount = ResponsiveHelper.getGridColumns(context);
            final childAspectRatio = ResponsiveHelper.getResponsiveChildAspectRatio(context);
            final horizontalPadding = width >= 900 ? 24.0 : 16.0;

            return SingleChildScrollView(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom + 24),
              child: Column(children: [

                // ── Banner Carousel ────────────────────────────────────
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: AspectRatio(
                      aspectRatio: width >= 600 ? 16 / 5 : 16 / 7,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          CarouselSlider(
                            carouselController: _carouselCtrl,
                            options: CarouselOptions(
                              height: double.infinity,
                              viewportFraction: 1.0,
                              autoPlay: true,
                              autoPlayInterval: const Duration(seconds: 4),
                              onPageChanged: (i, _) => setState(() => _bannerIdx = i),
                            ),
                            items: _banners.map((b) => BannerItem(banner: b)).toList(),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: AnimatedSmoothIndicator(
                              activeIndex: _bannerIdx,
                              count: _banners.length,
                              effect: const WormEffect(
                                dotWidth: 8, dotHeight: 8,
                                activeDotColor: Colors.white,
                                dotColor: Colors.white38,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Promo Chips ────────────────────────────────────────
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    children: const [
                      PromoChip(label: '🔥 Flash Sale 50% OFF'),
                      PromoChip(label: '🚚 Gratis Ongkir'),
                      PromoChip(label: '🪙 2x Coin Weekend'),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(horizontalPadding),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    // ── Categories ────────────────────────────────────
                    const SectionHeader(title: '🗂️ Kategori', showAll: false),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 80,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _categories.map((c) {
                          final sel = _selectedCategory == c['id'];
                          return CategoryChip(
                            icon: c['icon'],
                            label: c['label'],
                            selected: sel,
                            onTap: () {
                              setState(() => _selectedCategory = c['id']);
                              context.read<ProductProvider>().loadProducts(category: c['id'], refresh: true);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Flash Sale ────────────────────────────────────
                    if (prod.flashSale.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF991B1B), Color(0xFFEF4444)]),
                          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                        ),
                        child: Column(children: [
                          Row(children: [
                            const Text('⚡ Flash Sale', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                            const Spacer(),
                            // FittedBox + Flexible mencegah overflow: pada layar
                            // sempit (mis. 320px), teks "Berakhir:" + timer +
                            // tombol tidak lagi menyebabkan RenderFlex overflow,
                            // melainkan menyusut proporsional.
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  const Text('Berakhir: ', style: TextStyle(fontSize: 11, color: Colors.white70)),
                                  const CountdownTimer(),
                                  TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6)),
                                    child: const Text('Lihat Semua →', style: TextStyle(color: Colors.white, fontSize: 11)),
                                  ),
                                ]),
                              ),
                            ),
                          ]),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 190,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: prod.flashSale.length,
                              itemBuilder: (_, i) => ProductCard(
                                product: prod.flashSale[i],
                                isFlashSale: true,
                                width: 140,
                              ),
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Products / UMKM dashboard preview ───────────────
                    if (role != 'umkm') ...[
                      SectionHeader(
                        title: _selectedCategory == null ? '🔥 Produk Terpopuler' : '📦 ${_categories.firstWhere((c) => c["id"] == _selectedCategory)["label"]}',
                        onSeeAll: () => context.read<ProductProvider>().loadMore(),
                      ),
                      const SizedBox(height: 10),

                      if (prod.isLoading && prod.products.isEmpty)
                        const ShimmerProductGrid()
                      else if (prod.products.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Column(mainAxisSize: MainAxisSize.min, children: [
                              Text('🔍', style: TextStyle(fontSize: 48)),
                              SizedBox(height: 10),
                              Text('Produk tidak ditemukan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                            ]),
                          ),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: childAspectRatio,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: prod.products.length + (prod.hasMore ? 1 : 0),
                          itemBuilder: (_, i) {
                            if (i == prod.products.length) {
                              context.read<ProductProvider>().loadMore();
                              return const Center(child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                              ));
                            }
                            return ProductCard(product: prod.products[i]);
                          },
                        ),
                    ] else ...[
                      // Untuk UMKM tampilkan ringkasan dashboard singkat sebagai pengganti katalog
                      const SectionHeader(title: '📊 Dashboard Toko', showAll: false),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(child: QuickActionTile(icon: Icons.inventory_2_outlined, label: 'Produk', onTap: () => context.push('/umkm/products'))),
                        const SizedBox(width: 10),
                        Expanded(child: QuickActionTile(icon: Icons.list_alt_outlined, label: 'Pesanan', onTap: () => context.push('/umkm/orders'))),
                        const SizedBox(width: 10),
                        Expanded(child: QuickActionTile(icon: Icons.bar_chart_outlined, label: 'Analitik', onTap: () => context.push('/umkm/analytics'))),
                        const SizedBox(width: 10),
                        Expanded(child: QuickActionTile(icon: Icons.settings_outlined, label: 'Pengaturan', onTap: () => context.push('/umkm/store-settings'))),
                      ]),
                      const SizedBox(height: 14),
                      const Text('Halo, pemilik UMKM — gunakan tautan di atas untuk mengelola toko Anda.', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 18),
                    ],
                    SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 80),
                  ]),
                ),
              ]),
            );
          },
        ),
      ),
    );
  }
}
