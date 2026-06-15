import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
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
  bool _isRecommendationLoading = false;
  bool _recommendationAvailable = true;
  double? _recommendedPrice;
  double? _marketPriceLow;
  double? _marketPriceHigh;
  String? _recommendationMessage;

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

  Future<void> _requestPriceRecommendation() async {
    if (!_recommendationAvailable) {
      return;
    }
    final input = double.tryParse(_priceController.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (input == null || input <= 0) {
      _showError('Masukkan harga dasar yang valid untuk rekomendasi.');
      return;
    }
    setState(() {
      _isRecommendationLoading = true;
      _recommendationMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    final modifier = _getCategoryPriceModifier(_selectedCategory);
    final price = input * modifier;
    setState(() {
      _recommendedPrice = price;
      _marketPriceLow = price * 0.9;
      _marketPriceHigh = price * 1.1;
      _isRecommendationLoading = false;
      _recommendationMessage = 'Perkiraan harga berdasarkan kategori dan kondisi pasar.';
    });
  }

  double _getCategoryPriceModifier(String category) {
    switch (category) {
      case 'Makanan':
        return 1.15;
      case 'Minuman':
        return 1.12;
      case 'Kerajinan':
        return 1.25;
      case 'Fashion':
        return 1.18;
      case 'Elektronik':
        return 1.22;
      default:
        return 1.10;
    }
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

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil ditambahkan')),
        );
        _productNameController.clear();
        _descriptionController.clear();
        _priceController.clear();
        _stockController.clear();
        setState(() {
          _selectedImages.clear();
          _recommendedPrice = null;
          _marketPriceLow = null;
          _marketPriceHigh = null;
          _recommendationMessage = null;
        });
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
            if (_recommendationAvailable)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: AppTheme.primaryLight.withValues(alpha: 0.12),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Rekomendasi Harga', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 6),
                              Text(
                                _recommendedPrice != null ? 'Nilai pasar saat ini diperbarui otomatis.' : 'Gunakan rekomendasi harga setelah mengisi harga dasar.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: _isRecommendationLoading ? null : _requestPriceRecommendation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isRecommendationLoading
                                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                                : const Text('Cek Harga'),
                          ),
                        ],
                      ),
                      if (_recommendedPrice != null) ...[
                        const SizedBox(height: 16),
                        Text('Harga yang direkomendasikan', style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 8),
                        Text('Rp ${_recommendedPrice!.toStringAsFixed(0)}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.primaryColor)),
                        const SizedBox(height: 10),
                        Text('Rentang pasar: Rp ${_marketPriceLow!.toStringAsFixed(0)} - Rp ${_marketPriceHigh!.toStringAsFixed(0)}', style: Theme.of(context).textTheme.bodyMedium),
                        if (_recommendationMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(_recommendationMessage!, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
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
