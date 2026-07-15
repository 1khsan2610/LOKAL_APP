// ═══════════════════════════════════════════════════════════════════
//  ChangePasswordScreen  —  lib/screens/profile/change_password_screen.dart
//  Prinsip desain: bg #F8FAFC, SafeArea utk aman dari gesture nav &
//  keyboard. Logika ganti password TIDAK diubah.
// ═══════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/product_card.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  final _oldPass = TextEditingController();
  final _newPass = TextEditingController();
  final _confirmPass = TextEditingController();
  bool _isSaving = false;
  bool _obscureOld = true, _obscureNew = true, _obscureConfirm = true;

  @override
  void dispose() {
    _oldPass.dispose();
    _newPass.dispose();
    _confirmPass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await _api.changePassword(_oldPass.text, _newPass.text);
      if (!mounted) return;
      AppSnackBar.show(context, '✓ Password berhasil diubah');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context, 'Gagal mengubah password. Periksa password lama kamu.', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.bg,
    appBar: AppBar(
      title: const Text('Ubah Password'),
        leading: BackButton(onPressed: () => context.pop()),
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('🔒 Keamanan Akun', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            const Text('Pastikan password baru kamu kuat dan tidak digunakan di akun lain.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.6)),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _oldPass, label: 'Password Lama', obscureText: _obscureOld,
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(_obscureOld ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscureOld = !_obscureOld),
              ),
              validator: (v) => (v?.isEmpty ?? true) ? 'Password lama wajib diisi' : null,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _newPass, label: 'Password Baru', obscureText: _obscureNew,
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscureNew = !_obscureNew),
              ),
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Password baru wajib diisi';
                if (v!.length < 8) return 'Minimal 8 karakter';
                return null;
              },
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _confirmPass, label: 'Konfirmasi Password Baru', obscureText: _obscureConfirm,
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              validator: (v) => v != _newPass.text ? 'Konfirmasi password tidak cocok' : null,
            ),
            const SizedBox(height: 24),
            CustomButton(label: 'Simpan Password Baru', icon: Icons.check, isLoading: _isSaving, onPressed: _submit),
          ]),
        ),
      ),
    ),
  );
}
