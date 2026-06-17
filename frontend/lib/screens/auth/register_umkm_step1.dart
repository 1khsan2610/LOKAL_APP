import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../config/theme.dart';

class RegisterUmkmStep1 extends StatefulWidget {
  const RegisterUmkmStep1({Key? key}) : super(key: key);

  @override
  State<RegisterUmkmStep1> createState() => _RegisterUmkmStep1State();
}

class _RegisterUmkmStep1State extends State<RegisterUmkmStep1> {
  final _formKey = GlobalKey<FormState>();
  final _ownerCtrl = TextEditingController();
  final _businessNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _accepted = false;

  @override
  void dispose() {
    _ownerCtrl.dispose();
    _businessNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_formKey.currentState?.validate() == true && _accepted) {
      Navigator.pushNamed(context, '/register-umkm-step2', arguments: {
        'owner': _ownerCtrl.text,
        'businessName': _businessNameCtrl.text,
        'email': _emailCtrl.text,
        'phone': _phoneCtrl.text,
        'password': _passCtrl.text,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi formulir dan setujui S&K')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register UMKM - Langkah 1')),
      body: Padding(
        padding: const EdgeInsets.all(AppNumbers.paddingMedium),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Informasi Pemilik & Usaha', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppNumbers.paddingSmall),
              const Text('Isi data pemilik dan informasi usaha Anda', style: TextStyle(color: AppTheme.textHint)),
              const SizedBox(height: AppNumbers.paddingMedium),
              TextFormField(controller: _ownerCtrl, decoration: const InputDecoration(prefixIcon: Icon(Icons.person), labelText: 'Nama Pemilik'), validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null),
              const SizedBox(height: AppNumbers.paddingSmall),
              TextFormField(controller: _businessNameCtrl, decoration: const InputDecoration(prefixIcon: Icon(Icons.store), labelText: 'Nama Usaha'), validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null),
              const SizedBox(height: AppNumbers.paddingSmall),
              TextFormField(controller: _emailCtrl, decoration: const InputDecoration(prefixIcon: Icon(Icons.email), labelText: 'Email Usaha'), validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: AppNumbers.paddingSmall),
              TextFormField(controller: _phoneCtrl, decoration: const InputDecoration(prefixIcon: Icon(Icons.phone), labelText: 'No. HP'), validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null, keyboardType: TextInputType.phone),
              const SizedBox(height: AppNumbers.paddingSmall),
              TextFormField(controller: _passCtrl, decoration: const InputDecoration(prefixIcon: Icon(Icons.lock), labelText: 'Password'), obscureText: true, validator: (v) => (v == null || v.length < 6) ? 'Password minimal 6 karakter' : null),
              const SizedBox(height: AppNumbers.paddingSmall),
              TextFormField(controller: _confirmCtrl, decoration: const InputDecoration(prefixIcon: Icon(Icons.lock_outline), labelText: 'Konfirmasi Password'), obscureText: true, validator: (v) => v != _passCtrl.text ? 'Password tidak cocok' : null),
              const SizedBox(height: AppNumbers.paddingSmall),
              Row(children: [Checkbox(value: _accepted, onChanged: (v) => setState(() => _accepted = v ?? false)), const Expanded(child: Text('Saya setuju dengan Syarat & Ketentuan'))]),
              const SizedBox(height: AppNumbers.paddingMedium),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _next, child: const Text('Lanjutkan ke Langkah 2'))),
            ],
          ),
        ),
      ),
    );
  }
}
