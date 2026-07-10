import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Ganti nilai ini dengan base URL API Anda
const String kApiBaseUrl = 'https://example.com';

class TambahProdukPage extends StatefulWidget {
  const TambahProdukPage({super.key});

  @override
  State<TambahProdukPage> createState() => _TambahProdukPageState();
}

class _TambahProdukPageState extends State<TambahProdukPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _stockController = TextEditingController(text: '1');
  final TextEditingController _categoryController = TextEditingController(text: 'general');
  final TextEditingController _weightController = TextEditingController(text: '0');

  Uint8List? _imageBytes;
  String? _imageName;
  bool _isUploading = false;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> _pickImage() async {
    final file = await FilePicker.pickFile(
      type: FileType.image,
    );
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = file.name;
      });
    }
  }

  /// Unified save function for create (productId == null) and update (productId provided).
  /// If `productId` is provided, this will POST with `_method=PUT` to support Laravel's multipart PUT handling.
  Future<http.Response?> saveProduct({String? productId, String? token}) async {
    if (!_formKey.currentState!.validate()) return null;

    setState(() => _isUploading = true);
    try {
        final uri = productId == null
          ? Uri.parse('$kApiBaseUrl/api/umkm/products')
          : Uri.parse('$kApiBaseUrl/api/umkm/products/$productId');

      final request = http.MultipartRequest('POST', uri);

      if (productId != null) request.fields['_method'] = 'PUT';

      request.fields['name'] = _namaController.text;
      request.fields['price'] = _hargaController.text;
      request.fields['description'] = _descriptionController.text;
      request.fields['stock'] = _stockController.text;
      request.fields['category'] = _categoryController.text;
      request.fields['weight'] = _weightController.text;

      if (token != null) request.headers['Authorization'] = 'Bearer $token';

      if (_imageBytes != null) {
        final mime = _guessMimeType(_imageName ?? 'image.png');
        final parts = mime.split('/');
        request.files.add(http.MultipartFile.fromBytes(
          'images[]',
          _imageBytes!,
          filename: _imageName ?? 'upload.png',
          contentType: parts.length == 2 ? MediaType(parts[0], parts[1]) : null,
        ));
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(productId == null ? 'Produk berhasil ditambahkan' : 'Produk berhasil diperbarui')),
          );
        }

        if (productId == null && mounted) {
          setState(() {
            _namaController.clear();
            _hargaController.clear();
            _descriptionController.clear();
            _stockController.text = '1';
            _categoryController.text = 'general';
            _weightController.text = '0';
            _imageBytes = null;
            _imageName = null;
          });
        }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: ${response.statusCode} ${response.body}')));
      }

      return response;
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
      return null;
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _simpanProduk() async {
    final token = await _getAuthToken();
    await saveProduct(token: token);
  }


  /// Example helper to update an existing product by id.
  /// Frontend must send POST with `_method=PUT` when uploading multipart/form-data.
  // ignore: unused_element
  Future<void> _updateProduk(String productId) async {
    final token = await _getAuthToken();
    await saveProduct(productId: productId, token: token);
  }

  Future<String?> _getAuthToken() async {
    try {
      return await _secureStorage.read(key: 'auth_token');
    } catch (_) {
      return null;
    }
  }

  String _guessMimeType(String filename) {
    final ext = filename.split('.').length > 1 ? filename.split('.').last.toLowerCase() : '';
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'gif':
        return 'image/gif';
      default:
        return 'application/octet-stream';
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    _categoryController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Produk')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                keyboardType: TextInputType.multiline,
                minLines: 2,
                maxLines: 5,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Deskripsi wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _hargaController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Harga wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(labelText: 'Stok'),
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Stok wajib diisi' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      decoration: const InputDecoration(labelText: 'Berat (kg)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Berat wajib diisi' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Kategori'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Kategori wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              // PERBAIKAN 1: subtitle1 diubah menjadi titleMedium
              Text('Gambar Produk', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 170,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: _imageBytes != null
                        ? Image.memory(
                            _imageBytes!,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        // PERBAIKAN 2: Kata const di depan Column dihapus, dipindah ke widget statis di dalamnya
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.image, size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Klik untuk memilih gambar'),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _simpanProduk,
                icon: _isUploading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_isUploading ? 'Mengunggah...' : 'Simpan Produk'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}