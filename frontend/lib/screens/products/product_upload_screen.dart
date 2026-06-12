import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../config/theme.dart';

class UmkmProductUploadScreen extends ConsumerStatefulWidget {
  const UmkmProductUploadScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UmkmProductUploadScreen> createState() => _UmkmProductUploadScreenState();
}

class _UmkmProductUploadScreenState extends ConsumerState<UmkmProductUploadScreen> {
  final _productNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  
  List<File> _selectedImages = [];
  String _selectedCategory = 'Makanan';
  bool _isLoading = false;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _productNameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maksimal 5 foto per produk')),
      );
      return;
    }

    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImages.add(File(image.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  void _submitProduct() {
    if (_productNameController.text.isEmpty) {
      _showError('Nama produk tidak boleh kosong');
      return;
    }
    if (_descriptionController.text.isEmpty) {
      _showError('Deskripsi tidak boleh kosong');
      return;
    }
    if (_priceController.text.isEmpty) {
      _showError('Harga tidak boleh kosong');
      return;
    }
    if (_stockController.text.isEmpty) {
      _showError('Stok tidak boleh kosong');
      return;
    }
    if (_selectedImages.isEmpty) {
      _showError('Minimal 1 foto produk harus ditambahkan');
      return;
    }

    setState(() => _isLoading = true);

    // Simulate upload
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil ditambahkan')),
        );
        // Clear form
        _productNameController.clear();
        _descriptionController.clear();
        _priceController.clear();
        _stockController.clear();
        setState(() => _selectedImages.clear());
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Produk'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Upload Section
            Text('Foto Produk', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (_selectedImages.isEmpty)
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.dividerColor, style: BorderStyle.solid),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_upload_outlined, size: 48, color: AppTheme.textSecondary),
                      const SizedBox(height: 12),
                      Text('Klik untuk upload foto', style: TextStyle(color: AppTheme.textSecondary)),
                      Text('Maksimal 5 foto', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ..._selectedImages.asMap().entries.map((e) {
                        int idx = e.key;
                        File file = e.value;
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(file, width: 100, height: 100, fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: -8,
                              right: -8,
                              child: GestureDetector(
                                onTap: () => _removeImage(idx),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                      if (_selectedImages.length < 5)
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.dividerColor),
                            ),
                            child: const Icon(Icons.add, color: AppTheme.textSecondary),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('${_selectedImages.length}/5 foto', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            const SizedBox(height: 24),

            // Product Name
            Text('Nama Produk', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _productNameController,
              decoration: InputDecoration(
                hintText: 'Contoh: Kue Brownies Premium',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // Category
            Text('Kategori', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              onChanged: (value) => setState(() => _selectedCategory = value!),
              items: ['Makanan', 'Minuman', 'Kerajinan', 'Fashion', 'Elektronik', 'Lainnya']
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            Text('Deskripsi', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Jelaskan detail produk Anda...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // Price and Stock Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Harga', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Rp',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Stok', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Unit',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                      )
                    : const Text('Simpan Produk', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
