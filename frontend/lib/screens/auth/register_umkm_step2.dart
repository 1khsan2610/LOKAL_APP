import 'package:flutter/material.dart';
import '../../config/constants.dart';

class RegisterUmkmStep2 extends StatefulWidget {
  const RegisterUmkmStep2({super.key});

  @override
  State<RegisterUmkmStep2> createState() => _RegisterUmkmStep2State();
}

class _RegisterUmkmStep2State extends State<RegisterUmkmStep2> {
  final _formKey = GlobalKey<FormState>();
  final _addressCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();

  @override
  void dispose() {
    _addressCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() == true) {
      Navigator.pushNamed(context, '/register-success');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi formulir')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register UMKM - Langkah 2')),
      body: Padding(
        padding: const EdgeInsets.all(AppNumbers.paddingMedium),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _addressCtrl, decoration: const InputDecoration(labelText: 'Alamat Usaha'), validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null),
              const SizedBox(height: AppNumbers.paddingSmall),
              TextFormField(controller: _categoryCtrl, decoration: const InputDecoration(labelText: 'Kategori Usaha'), validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null),
              const SizedBox(height: AppNumbers.paddingSmall),
              // Placeholder for upload NIB/SIUP
              ElevatedButton(onPressed: () {}, child: const Text('Upload NIB/SIUP (kamera/galeri)')),
              const SizedBox(height: AppNumbers.paddingMedium),
              ElevatedButton(onPressed: _submit, child: const Text('Kirim')),
            ],
          ),
        ),
      ),
    );
  }
}
