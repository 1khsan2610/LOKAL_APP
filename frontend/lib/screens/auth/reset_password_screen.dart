import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/product_card.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, this.email = ''});
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  late final TextEditingController _email;
  final _token = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    _email.dispose();
    _token.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _api.resetPassword(
        token: _token.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
        passwordConfirmation: _confirmPassword.text,
      );
      if (!mounted) return;
      AppSnackBar.show(context, '✓ Password berhasil direset. Silakan masuk kembali.');
      context.go('/login');
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(context, 'Kode reset tidak valid atau sudah kedaluwarsa.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Reset Password')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('🔑 Buat Password Baru', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Masukkan kode reset yang dikirimkan ke email kamu, beserta password baru.',
            style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.6)),
          const SizedBox(height: 24),
          CustomTextField(
            controller: _email, label: 'Email', hint: 'kamu@email.com',
            prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress,
            validator: (v) => (v?.isEmpty ?? true) ? 'Email wajib diisi' : null,
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: _token, label: 'Kode Reset', hint: 'Kode dari email',
            prefixIcon: Icons.vpn_key_outlined,
            validator: (v) => (v?.isEmpty ?? true) ? 'Kode reset wajib diisi' : null,
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: _password, label: 'Password Baru', obscureText: _obscure,
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
            validator: (v) {
              if (v?.isEmpty ?? true) return 'Password baru wajib diisi';
              if (v!.length < 8) return 'Minimal 8 karakter';
              return null;
            },
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: _confirmPassword, label: 'Konfirmasi Password', obscureText: _obscure,
            prefixIcon: Icons.lock_outline,
            validator: (v) => v != _password.text ? 'Konfirmasi password tidak cocok' : null,
          ),
          const SizedBox(height: 24),
          CustomButton(label: 'Reset Password', icon: Icons.check, isLoading: _isLoading, onPressed: _submit),
        ]),
      ),
    ),
  );
}
