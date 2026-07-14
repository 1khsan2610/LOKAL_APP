import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:go_router/go_router.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../../utils/app_theme.dart';

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
    {'title': 'Ramadan Sale\n-60% OFF!', 'subtitle': 'Produk UMKM pilihan terbaik', 'color1': const Color(0xFF065F46), 'color2': const Color(0xFF059669), 'emoji': '🌙', 'route': '/search?q=sale'},
    {'title': 'Lokal Coin\n2x Reward! 🪙', 'subtitle': 'Kumpulkan coin setiap pembelian', 'color1': const Color(0xFF92400E), 'color2': const Color(0xFFF59E0B), 'emoji': '🪙', 'route': '/wallet'},
    {'title': 'UMKM\ndi Sekitarmu 📍', 'subtitle': 'Belanja langsung dari pengusaha lokal', 'color1': const Color(0xFF1E3A5F), 'color2': const Color(0xFF3B82F6), 'emoji': '🗺️', 'route': '/map'},
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

    return Scaffold(
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
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () => context.read<ProductProvider>().loadProducts(refresh: true),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom + 24),
          child: Column(children: [

            // ── Banner Carousel ────────────────────────────────────
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                CarouselSlider(
                  carouselController: _carouselCtrl,
                  options: CarouselOptions(
                    height: 170,
                    viewportFraction: 1.0,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 4),
                    onPageChanged: (i, _) => setState(() => _bannerIdx = i),
                  ),
                  items: _banners.map((b) => _BannerItem(banner: b)).toList(),
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

            // ── Promo Chips ────────────────────────────────────────
            SizedBox(
              height: 40,
              child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  '🔥 Flash Sale 50% OFF', '🚚 Gratis Ongkir', '🪙 2x Coin Weekend',
                ].map((t) => Container(
                  margin: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryDark, borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(child: Text(t, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600))),
                )).toList(),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // ── Categories ────────────────────────────────────
                const SectionHeader(title: '🗂️ Kategori', showAll: false),
                const SizedBox(height: 10),
                SizedBox(
                  height: 80,
                  child: ListView(scrollDirection: Axis.horizontal,
                    children: _categories.map((c) {
                      final sel = _selectedCategory == c['id'];
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedCategory = c['id']);
                          context.read<ProductProvider>().loadProducts(category: c['id'], refresh: true);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 10),
                          width: 72,
                          decoration: BoxDecoration(
                            color: sel ? AppTheme.surface2 : AppTheme.surface,
                            border: Border.all(color: sel ? AppTheme.primary : AppTheme.border, width: sel ? 2 : 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(c['icon'], style: const TextStyle(fontSize: 24)),
                            const SizedBox(height: 4),
                            Text(c['label'], style: TextStyle(fontSize: 10, fontWeight: sel ? FontWeight.w700 : FontWeight.w500, color: sel ? AppTheme.primary : AppTheme.textSecondary)),
                          ]),
                        ),
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
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(children: [
                      Row(children: [
                        const Text('⚡ Flash Sale', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                        const Spacer(),
                        const Text('Berakhir: ', style: TextStyle(fontSize: 11, color: Colors.white70)),
                        _CountdownTimer(),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Lihat Semua →', style: TextStyle(color: Colors.white, fontSize: 11)),
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

                // ── Products ──────────────────────────────────────
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
                      child: Column(children: [
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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
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
                SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 80),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// Banner widget — clickable with navigation
class _BannerItem extends StatelessWidget {
  final Map<String, dynamic> banner;
  const _BannerItem({required this.banner});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      final route = banner['route'] as String?;
      if (route != null && route.isNotEmpty) {
        context.push(route);
      }
    },
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [banner['color1'], banner['color2']]),
      ),
      child: Stack(children: [
        Positioned(right: -10, bottom: -10,
          child: Text(banner['emoji'], style: const TextStyle(fontSize: 100, color: Colors.white10))),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(banner['title'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2)),
            const SizedBox(height: 6),
            Text(banner['subtitle'], style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.85))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(8)),
              child: const Text('Belanja Sekarang →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ]),
        ),
      ]),
    ),
  );
}

// Countdown timer widget
class _CountdownTimer extends StatefulWidget {
  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = const Duration(hours: 2, minutes: 45, seconds: 30);
    _tick();
  }

  void _tick() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        if (_remaining.inSeconds > 0) {
          _remaining -= const Duration(seconds: 1);
        } else {
          _remaining = const Duration(hours: 3);
        }
      });
      _tick();
    });
  }

  String _fmt(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _block(_fmt(_remaining.inHours)),
      const Text(':', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      _block(_fmt(_remaining.inMinutes.remainder(60))),
      const Text(':', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      _block(_fmt(_remaining.inSeconds.remainder(60))),
    ]);
  }

  Widget _block(String v) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 2),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(5)),
    child: Text(v, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
  );
}
