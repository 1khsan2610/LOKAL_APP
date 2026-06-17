import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/constants.dart';
import '../../config/theme.dart';

class RegisterUmkmStep2 extends StatefulWidget {
  const RegisterUmkmStep2({super.key});

  @override
  State<RegisterUmkmStep2> createState() => _RegisterUmkmStep2State();
}

class _RegisterUmkmStep2State extends State<RegisterUmkmStep2> {
  final _formKey = GlobalKey<FormState>();
  final _addressCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  File? _nibFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _addressCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickNib(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, maxWidth: 1200, maxHeight: 1600);
      if (picked != null) {
        setState(() => _nibFile = File(picked.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memilih file')));
    }
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
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(title: const Text('Register UMKM - Langkah 2')),
      body: Padding(
        padding: const EdgeInsets.all(AppNumbers.paddingMedium),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Informasi Usaha', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppNumbers.paddingSmall),
              const Text('Tambahkan alamat usaha, kategori, dan unggah NIB/SIUP jika ada', style: TextStyle(color: AppTheme.textHint)),
              const SizedBox(height: AppNumbers.paddingMedium),
              TextFormField(controller: _addressCtrl, decoration: const InputDecoration(prefixIcon: Icon(Icons.location_on), labelText: 'Alamat Usaha'), validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null),
              const SizedBox(height: AppNumbers.paddingSmall),
              TextFormField(controller: _categoryCtrl, decoration: const InputDecoration(prefixIcon: Icon(Icons.category), labelText: 'Kategori Usaha'), validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null),
              const SizedBox(height: AppNumbers.paddingSmall),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(AppNumbers.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Upload NIB / SIUP', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 12),
                      if (_nibFile != null)
                        ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(_nibFile!, height: 180, fit: BoxFit.cover))
                      else
                        Container(
                          height: 140,
                          decoration: BoxDecoration(color: AppTheme.dividerColor, borderRadius: BorderRadius.circular(8)),
                          child: Center(child: Icon(Icons.upload_file, size: 48, color: AppTheme.textHint)),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: OutlinedButton.icon(onPressed: () => _pickNib(ImageSource.camera), icon: const Icon(Icons.camera_alt), label: const Text('Kamera'))),
                          const SizedBox(width: 8),
                          Expanded(child: OutlinedButton.icon(onPressed: () => _pickNib(ImageSource.gallery), icon: const Icon(Icons.photo_library), label: const Text('Galeri'))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppNumbers.paddingMedium),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _submit, child: const Text('Kirim'))),
            ],
          ),
        ),
      ),
    );
  }
}
