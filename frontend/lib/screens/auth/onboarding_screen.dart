import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../config/theme.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Selamat Datang')),
      body: Padding(
        padding: const EdgeInsets.all(AppNumbers.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Center(child: Icon(Icons.local_grocery_store, size: 96, color: AppTheme.primaryColor)),
            const SizedBox(height: AppNumbers.paddingLarge),
            Text(
              'LOKAL — Ekonomi Lokal Dimulai di Sini',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppNumbers.paddingMedium),
            Text(
              'Daftar sebagai Konsumen atau UMKM untuk mulai bertransaksi.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppNumbers.paddingLarge),
            ElevatedButton.icon(
              icon: const Icon(Icons.person_add),
              onPressed: () => Navigator.pushNamed(context, '/register-choice'),
              label: const Text('Register Account'),
            ),
            const SizedBox(height: AppNumbers.paddingSmall),
            OutlinedButton.icon(
              icon: const Icon(Icons.login),
              onPressed: () => Navigator.pushNamed(context, '/login'),
              label: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
