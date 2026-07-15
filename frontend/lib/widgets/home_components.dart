// ═══════════════════════════════════════════════════════════════════
//  Komponen-komponen kecil milik Beranda yang sebelumnya berupa
//  private class (_BannerItem, _CountdownTimer) atau widget inline
//  di dalam HomeScreen. Dipisah ke sini agar:
//   1) HomeScreen lebih ramping & mudah dibaca,
//   2) komponen bisa dipakai ulang di layar lain (mis. promo chip di
//      halaman search, banner di halaman kategori), dan
//   3) setiap komponen bisa diaudit responsivitasnya secara terpisah.
// ═══════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_theme.dart';

/// Chip kategori horizontal pada Beranda.
class CategoryChip extends StatelessWidget {
  final String icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double width;

  const CategoryChip({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.width = 72,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        width: width,
        decoration: BoxDecoration(
          color: selected ? AppTheme.surface2 : AppTheme.surface,
          border: Border.all(color: selected ? AppTheme.primary : AppTheme.cardBorder, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(14),
        ),
        // mainAxisSize.min + Flexible pada label mencegah overflow ketika
        // width chip dipersempit di layar sangat kecil.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppTheme.primary : AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chip promo kecil ("Flash Sale 50% OFF", dsb.) pada baris atas Beranda.
class PromoChip extends StatelessWidget {
  final String label;
  const PromoChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: AppTheme.primary,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Center(
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
      ),
    ),
  );
}

/// Satu slide banner carousel — dipakai lagi bila banner ditampilkan
/// di layar lain (mis. halaman kategori/promo).
class BannerItem extends StatelessWidget {
  final Map<String, dynamic> banner;
  const BannerItem({super.key, required this.banner});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      final route = banner['route'] as String?;
      if (route != null && route.isNotEmpty) context.push(route);
    },
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [banner['color1'], banner['color2']]),
      ),
      // LayoutBuilder memastikan padding & ukuran font banner menyesuaikan
      // lebar yang tersedia, bukan diasumsikan selalu lebar layar HP.
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 340;
          return Stack(children: [
            Positioned(
              right: -10, bottom: -10,
              child: Text(banner['emoji'], style: const TextStyle(fontSize: 100, color: Colors.white10)),
            ),
            Padding(
              padding: EdgeInsets.all(isNarrow ? 18 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    banner['title'],
                    style: TextStyle(fontSize: isNarrow ? 18 : 22, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    banner['subtitle'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.85)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(8)),
                    child: const Text('Belanja Sekarang →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ]);
        },
      ),
    ),
  );
}

/// Timer mundur untuk Flash Sale.
class CountdownTimer extends StatefulWidget {
  const CountdownTimer({super.key});
  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
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
    return Row(mainAxisSize: MainAxisSize.min, children: [
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
