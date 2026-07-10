import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, this.email = ''});
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _emailCtrl   = TextEditingController();
  final _tokenCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass   = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    if (widget.email.isNotEmpty) _emailCtrl.text = widget.email;
  }

  @override
  void dispose() {
    _emailCtrl.dispose(); _tokenCtrl.dispose();
    _passCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final ok   = await auth.resetPassword(
      _emailCtrl.text.trim(),
      _tokenCtrl.text.trim(),
      _passCtrl.text,
      _confirmCtrl.text,
    );

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✓ Password berhasil direset. Silakan login.')),
      );
      context.go('/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Gagal mereset password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(children: [
            const SizedBox(height: 20),
            const Icon(Icons.lock_reset, size: 64, color: AppTheme.primary),
            const SizedBox(height: 16),
            const Text('Buat Password Baru', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Masukkan token reset yang dikirim ke email kamu',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 30),
            CustomTextField(
              controller: _emailCtrl,
              label: 'Email',
              hint: 'kamu@email.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || v.isEmpty) ? 'Email wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _tokenCtrl,
              label: 'Token Reset',
              hint: 'Masukkan token dari email',
              prefixIcon: Icons.token_outlined,
              validator: (v) => (v == null || v.isEmpty) ? 'Token wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _passCtrl,
              label: 'Password Baru',
              hint: 'Minimal 6 karakter',
              prefixIcon: Icons.lock_outlined,
              obscureText: _obscurePass,
              suffixIcon: IconButton(
                icon: Icon(_obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password wajib diisi';
                if (v.length < 6) return 'Minimal 6 karakter';
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _confirmCtrl,
              label: 'Konfirmasi Password',
              hint: 'Ulangi password baru',
              prefixIcon: Icons.lock_outlined,
              obscureText: _obscureConfirm,
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Konfirmasi password wajib diisi';
                if (v != _passCtrl.text) return 'Password tidak cocok';
                return null;
              },
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: 'Reset Password',
              icon: Icons.lock_reset,
              isLoading: auth.isLoading,
              onPressed: _submit,
            ),
          ]),
        ),
      ),
    );
  }
}