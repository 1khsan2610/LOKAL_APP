import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../config/theme.dart';

class RegisterConsumerScreen extends StatefulWidget {
  const RegisterConsumerScreen({super.key});

  @override
  State<RegisterConsumerScreen> createState() => _RegisterConsumerScreenState();
}

class _RegisterConsumerScreenState extends State<RegisterConsumerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _accepted = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String? _emailValidator(String? v) {
    if (v == null || v.isEmpty) return 'Email wajib diisi';
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}");
    if (!emailRegex.hasMatch(v)) return 'Format email tidak valid';
    return null;
  }

  void _submit() {
    if (_formKey.currentState?.validate() == true && _accepted) {
      Navigator.pushNamed(context, '/register-success');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi formulir dan setujui S&K')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register - Konsumen')),
      body: Padding(
        padding: const EdgeInsets.all(AppNumbers.paddingMedium),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Buat Akun Konsumen',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppNumbers.paddingSmall),
              const Text('Isi data berikut untuk membuat akun Anda', style: TextStyle(color: AppTheme.textHint)),
              const SizedBox(height: AppNumbers.paddingMedium),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.person), labelText: 'Nama Lengkap'),
                validator: (v) => (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: AppNumbers.paddingSmall),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.email), labelText: 'Email'),
                validator: _emailValidator,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppNumbers.paddingSmall),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.phone), labelText: 'No. HP'),
                validator: (v) => (v == null || v.isEmpty) ? 'No. HP wajib diisi' : null,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppNumbers.paddingSmall),
              TextFormField(
                controller: _passCtrl,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.lock), labelText: 'Password'),
                obscureText: true,
                validator: (v) => (v == null || v.length < 6) ? 'Password minimal 6 karakter' : null,
              ),
              const SizedBox(height: AppNumbers.paddingSmall),
              TextFormField(
                controller: _confirmCtrl,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.lock_outline), labelText: 'Konfirmasi Password'),
                obscureText: true,
                validator: (v) => v != _passCtrl.text ? 'Password tidak cocok' : null,
              ),
              const SizedBox(height: AppNumbers.paddingSmall),
              Row(
                children: [
                  Checkbox(value: _accepted, onChanged: (v) => setState(() => _accepted = v ?? false)),
                  Expanded(child: GestureDetector(onTap: () => setState(() => _accepted = !_accepted), child: const Text('Saya setuju dengan Syarat & Ketentuan'))),
                ],
              ),
              const SizedBox(height: AppNumbers.paddingMedium),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: _submit, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)), child: const Text('Daftar')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
