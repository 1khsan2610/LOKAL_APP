import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  final _storeCtrl    = TextEditingController();
  String _role        = 'konsumen';
  String _storeCat    = 'Makanan & Minuman';
  bool   _obscure     = true;
  final List<String> _storeCategories = [
    'Makanan & Minuman', 'Fashion & Tekstil', 'Kerajinan Tangan',
    'Bahan Pokok', 'Kosmetik & Kecantikan', 'Elektronik', 'Lainnya',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose();
    _passCtrl.dispose(); _confirmCtrl.dispose(); _storeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name':     _nameCtrl.text.trim(),
      'email':    _emailCtrl.text.trim(),
      'phone':    _phoneCtrl.text.trim(),
      'password': _passCtrl.text,
      'password_confirmation': _confirmCtrl.text,
      'role':     _role,
      if (_role == 'umkm') ...{
        'store_name':     _storeCtrl.text.trim(),
        'store_category': _storeCat,
      },
    };

    final auth = context.read<AuthProvider>();
    final ok   = await auth.register(data);

    if (!mounted) return;
    if (ok) {
      context.go('/main');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Pendaftaran gagal')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Akun Baru')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Role selection
            const Text('Pilih Tipe Akun',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _RoleCard(
              icon: '🛒',
              title: 'Pembeli / Konsumen',
              desc: 'Berbelanja produk UMKM lokal favorit kamu',
              selected: _role == 'konsumen',
              onTap: () => setState(() { _role = 'konsumen'; }),
            ),
            const SizedBox(height: 10),
            _RoleCard(
              icon: '🏪',
              title: 'Pemilik UMKM',
              desc: 'Kelola toko dan jual produkmu secara online',
              selected: _role == 'umkm',
              onTap: () => setState(() { _role = 'umkm'; }),
            ),
            const SizedBox(height: 24),

            const Text('Data Pribadi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _nameCtrl, label: 'Nama Lengkap',
              hint: 'Nama kamu', prefixIcon: Icons.person_outlined,
              validator: (v) => (v?.isEmpty ?? true) ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _phoneCtrl, label: 'No. HP',
              hint: '08xxxxxxxxx', prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) => (v?.isEmpty ?? true) ? 'No. HP wajib diisi' : null,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _emailCtrl, label: 'Email',
              hint: 'kamu@email.com', prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Email wajib diisi';
                if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v!)) {
                  return 'Format email tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _passCtrl, label: 'Password',
              hint: 'Min. 8 karakter', prefixIcon: Icons.lock_outlined,
              obscureText: _obscure,
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Password wajib diisi';
                if ((v?.length ?? 0) < 8) return 'Password minimal 8 karakter';
                return null;
              },
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _confirmCtrl, label: 'Konfirmasi Password',
              hint: 'Ulangi password', prefixIcon: Icons.lock_outlined,
              obscureText: _obscure,
              validator: (v) {
                if (v != _passCtrl.text) return 'Password tidak cocok';
                return null;
              },
            ),

            // UMKM fields
            if (_role == 'umkm') ...[
              const SizedBox(height: 24),
              const Text('Informasi Toko',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _storeCtrl, label: 'Nama Toko',
                hint: 'Toko Rasa Nusantara', prefixIcon: Icons.store_outlined,
                validator: (v) => (v?.isEmpty ?? true) ? 'Nama toko wajib diisi' : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _storeCat,
                decoration: InputDecoration(
                  labelText: 'Kategori Usaha',
                  prefixIcon: const Icon(Icons.category_outlined, color: AppTheme.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppTheme.border),
                  ),
                ),
                items: _storeCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _storeCat = v!),
              ),
            ],

            const SizedBox(height: 28),
            CustomButton(
              label: 'Buat Akun Sekarang 🚀',
              isLoading: auth.isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('Sudah punya akun? ', style: TextStyle(color: AppTheme.textSecondary)),
              GestureDetector(
                onTap: () => context.go('/login'),
                child: const Text('Masuk',
                    style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String icon, title, desc;
  final bool selected;
  final VoidCallback onTap;
  const _RoleCard({required this.icon, required this.title, required this.desc, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selected ? AppTheme.surface2 : AppTheme.surface,
        border: Border.all(color: selected ? AppTheme.primary : AppTheme.border, width: selected ? 2 : 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 28)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(desc, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ])),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 20, height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: selected ? AppTheme.primary : AppTheme.border, width: 2),
            color: selected ? AppTheme.primary : Colors.transparent,
          ),
          child: selected ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
        ),
      ]),
    ),
  );
}
