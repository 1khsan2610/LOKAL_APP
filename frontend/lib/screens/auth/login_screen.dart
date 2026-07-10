import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  bool  _obscure    = true;

  @override
  void dispose() {
    _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final ok   = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);

    if (!mounted) return;
    if (ok) {
      final role = auth.user?.role;
      if (role == 'admin') {
        context.go('/admin');
      } else {
        context.go('/main');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Login gagal')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 72, 24, 36),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryDark, AppTheme.primary],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(child: Text('🌿', style: TextStyle(fontSize: 28))),
                ),
                const SizedBox(height: 16),
                const Text('Selamat Datang 👋',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 6),
                Text('Masuk ke akun EkonomiLokal kamu',
                    style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8))),
              ]),
            ),

            // Form
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(children: [
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _emailCtrl,
                    label: 'Email',
                    hint: 'kamu@email.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Email wajib diisi';
                      if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                        return 'Format email tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passCtrl,
                    label: 'Password',
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outlined,
                    obscureText: _obscure,
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push('/forgot-password'),
                      child: const Text('Lupa Password?',
                          style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomButton(
                    label: 'Masuk',
                    icon: Icons.login_rounded,
                    isLoading: auth.isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 20),
                  const Row(children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('atau', style: TextStyle(color: AppTheme.textHint)),
                    ),
                    Expanded(child: Divider()),
                  ]),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/register'),
                    icon: const Icon(Icons.person_add_outlined),
                    label: const Text('Buat Akun Baru'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Demo accounts
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.surface2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('🧪 Demo Akun (password: password123)',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      _demoChip('👤 Konsumen', 'budi@test.com'),
                      const SizedBox(height: 4),
                      _demoChip('🏪 UMKM', 'busari@test.com'),
                      const SizedBox(height: 4),
                      _demoChip('⚙️ Admin', 'admin@ekonomilokal.id'),
                    ]),
                  ),
                  const SizedBox(height: 16),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _demoChip(String label, String email) => InkWell(
    onTap: () {
      _emailCtrl.text = email;
      _passCtrl.text  = 'password123';
    },
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const Spacer(),
        Text(email, style: const TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w500)),
        const SizedBox(width: 4),
        const Icon(Icons.arrow_forward_ios, size: 10, color: AppTheme.textHint),
      ]),
    ),
  );
}
