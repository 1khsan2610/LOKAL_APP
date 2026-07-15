// ═══════════════════════════════════════════════════════════════════
//  Komponen dashboard yang dipakai bersama oleh Admin Dashboard & UMKM
//  Dashboard. Sebelumnya masing-masing layar punya _StatCard/_ActionCard
//  sendiri-sendiri (kode duplikat, dan gaya visualnya berbeda satu sama
//  lain — admin pakai Colors.white + boxShadow, UMKM pakai AppTheme +
//  border). Disatukan di sini dengan satu gaya yang meniru kartu statistik
//  pada dashboard admin web: chip ikon berwarna pastel + badge label di
//  kanan atas + angka besar + keterangan kecil di bawah.
// ═══════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'app_card.dart';

/// Kartu statistik ala dashboard admin web:
///  ┌───────────────────────────────┐
///  │ [🏬 chip]           [Badge]   │
///  │ 4                             │
///  │ UMKM Terdaftar                │
///  └───────────────────────────────┘
class StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String label;
  final String? badge;
  final Color? badgeColor;

  const StatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
    this.badge,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const Spacer(),
            if (badge != null)
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? AppTheme.textHint).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: badgeColor ?? AppTheme.textSecondary),
                  ),
                ),
              ),
          ]),
          const SizedBox(height: 10),
          // FittedBox mencegah angka besar (mis. "Rp 12.4Jt") overflow
          // ketika kartu dipersempit oleh grid 2/3/4 kolom di layar kecil.
          Flexible(
            child: FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            ),
          ),
          const SizedBox(height: 2),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

/// Ubin aksi cepat (grid ikon + label) — dipakai di Admin & UMKM Dashboard.
class QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const QuickActionTile({super.key, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: AppTheme.primary),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
