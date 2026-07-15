import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// Kartu dasar yang seragam di seluruh aplikasi, meniru gaya kartu pada
/// dashboard admin web: radius besar, elevation 0, border tipis shade200.
/// Dipakai ulang di Beranda, Produk, Pesanan, dsb. supaya tidak ada lagi
/// styling Container/BoxDecoration kartu yang berulang & tidak konsisten.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final double radius;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.onTap,
    this.color,
    this.radius = AppTheme.cardRadius,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppTheme.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: child,
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: content,
      ),
    );
  }
}
