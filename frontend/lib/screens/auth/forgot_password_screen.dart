import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/product_card.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email   = TextEditingController();
  bool _isSent   = false;
  bool _isLoading = false;
  final _api = ApiService();

  @override
  void dispose() { _email.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _api.forgotPassword(_email.text.trim());
      if (!mounted) return;
      setState(() => _isSent = true);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(context, 'Gagal mengirim email. Coba lagi.', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Lupa Password')),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: _isSent
          ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('📧', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              const Text('Email Terkirim!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('Link reset password sudah dikirim ke ${_email.text}. Cek inbox atau folder spam kamu.',
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.6)),
              const SizedBox(height: 28),
              CustomButton(label: 'Kembali ke Login', onPressed: () => Navigator.pop(context)),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.push('/reset-password?email=${Uri.encodeComponent(_email.text.trim())}'),
                child: const Text('Saya sudah punya kode reset'),
              ),
            ])
          : Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 20),
                const Text('🔐 Reset Password', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text('Masukkan email yang kamu gunakan saat mendaftar. Kami akan mengirimkan link reset password.',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.6)),
                const SizedBox(height: 28),
                CustomTextField(
                  controller: _email, label: 'Email', hint: 'kamu@email.com',
                  prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Email wajib diisi';
                    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v!)) return 'Format email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                CustomButton(label: 'Kirim Link Reset', icon: Icons.send_outlined, isLoading: _isLoading, onPressed: _submit),
              ]),
            ),
    ),
  );
}

