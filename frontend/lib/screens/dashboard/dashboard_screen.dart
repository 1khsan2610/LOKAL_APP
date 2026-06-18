import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Widget _featureCard(BuildContext context, IconData icon, String title, String subtitle, {Color? color}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color ?? AppTheme.primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppTheme.primaryDark, AppTheme.primaryColor], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                boxShadow: [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.12), blurRadius: 18, offset: const Offset(0, 8))],
              ),
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white24),
                    child: Icon(Icons.shopping_basket, size: 40, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.appName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Text(AppStrings.appTagline, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Padding(padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10), child: Text('Masuk', style: TextStyle(color: Colors.white))),
                  )
                ],
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                children: [
                  _featureCard(context, Icons.shopping_bag, 'Belanja Lokal', 'Temukan produk berkualitas dari UMKM setempat'),
                  const SizedBox(height: 12),
                  _featureCard(context, Icons.storefront, 'Bagi UMKM', 'Kelola toko dan produk Anda dengan mudah'),
                  const SizedBox(height: 12),
                  _featureCard(context, Icons.auto_awesome, 'Promo & Koin', 'Dapatkan koin saat bergabung dan gunakan untuk diskon'),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, '/signup'),
                          style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.symmetric(vertical: 14)),
                          child: const Text('Daftar Sekarang'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Atau telusuri produk tanpa akun', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
                  const SizedBox(height: 18),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text('Versi pengembangan • LOKAL', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
            )
          ],
        ),
      ),
    );
  }
}
