import 'package:flutter/material.dart';
import '../../config/constants.dart';

class RegisterConsumerScreen extends StatefulWidget {
  const RegisterConsumerScreen({Key? key}) : super(key: key);

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
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                validator: (v) => (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: AppNumbers.paddingSmall),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => (v == null || v.isEmpty) ? 'Email wajib diisi' : null,
              ),
              const SizedBox(height: AppNumbers.paddingSmall),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: 'No. HP'),
                validator: (v) => (v == null || v.isEmpty) ? 'No. HP wajib diisi' : null,
              ),
              const SizedBox(height: AppNumbers.paddingSmall),
              TextFormField(
                controller: _passCtrl,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) => (v == null || v.length < 6) ? 'Password minimal 6 karakter' : null,
              ),
              const SizedBox(height: AppNumbers.paddingSmall),
              TextFormField(
                controller: _confirmCtrl,
                decoration: const InputDecoration(labelText: 'Konfirmasi Password'),
                obscureText: true,
                validator: (v) => v != _passCtrl.text ? 'Password tidak cocok' : null,
              ),
              const SizedBox(height: AppNumbers.paddingSmall),
              Row(
                children: [
                  Checkbox(value: _accepted, onChanged: (v) => setState(() => _accepted = v ?? false)),
                  const Expanded(child: Text('Saya setuju dengan Syarat & Ketentuan')),
                ],
              ),
              const SizedBox(height: AppNumbers.paddingMedium),
              ElevatedButton(onPressed: _submit, child: const Text('Daftar')),
            ],
          ),
        ),
      ),
    );
  }
}
