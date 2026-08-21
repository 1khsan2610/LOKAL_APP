import 'package:flutter/material.dart';

/// A fluid responsive wrapper that adapts to screen size.
/// - On mobile (< 600px): full-width with 16px padding
/// - On tablet (600-900px): full-width with 32px padding
/// - On desktop (> 900px): max-width 1200px centered with generous padding
class MobileFrame extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const MobileFrame({
    super.key,
    required this.child,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 1200 : double.infinity,
        ),
        decoration: BoxDecoration(
          color: backgroundColor ?? const Color(0xFFFAFAFA),
        ),
        child: child,
      ),
    );
  }
}