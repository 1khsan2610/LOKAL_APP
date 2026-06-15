import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../config/theme.dart';

class RegisterSuccessScreen extends StatelessWidget {
  const RegisterSuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrasi Berhasil')),
      body: Padding(
        padding: const EdgeInsets.all(AppNumbers.paddingMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.mark_email_read, size: 96, color: AppTheme.primaryColor),
            const SizedBox(height: AppNumbers.paddingLarge),
            Text('Silakan cek email Anda untuk verifikasi akun.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppNumbers.paddingLarge),
            ElevatedButton(onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false), child: const Text('Kembali ke Login')),
          ],
        ),
      ),
    );
  }
}
