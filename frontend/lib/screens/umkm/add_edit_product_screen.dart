import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import '../../models/product_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/image_helper.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/product_card.dart';

class AddEditProductScreen extends StatefulWidget {
  final ProductModel? product;
  const AddEditProductScreen({super.key, this.product});
  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name, _price, _stock, _weight, _desc;
  String _category = 'makanan';
  bool _isSaving = false;
  final _api = ApiService();

  final _categories = ['makanan', 'minuman', 'fashion', 'kerajinan', 'bahan_pokok'];
  final List<XFile> _pickedImages = [];
  final List<MapEntry<int, String>> _existingImages = []; // (id, url) pairs
  final Set<int> _removedImageIds = {}; // IDs of removed existing images
  final _picker = ImagePicker();

  Future<void> _pickImages() async {
    try {
      final picked = await _picker.pickMultiImage(imageQuality: 80);
      if (picked.isEmpty) return;
      setState(() => _pickedImages.addAll(picked));
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(context, 'Gagal membuka galeri foto', isError: true);
    }
  }

  void _removePickedImage(int index) => setState(() => _pickedImages.removeAt(index));
  void _removeExistingImage(int index) {
    final entry = _existingImages[index];
    setState(() {
      _removedImageIds.add(entry.key);
      _existingImages.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name   = TextEditingController(text: p?.name   ?? '');
    _price  = TextEditingController(text: p != null ? '${p.price}'  : '');
    _stock  = TextEditingController(text: p != null ? '${p.stock}'  : '');
    _weight = TextEditingController(text: p != null ? '${p.weight.toInt()}' : '');
    _desc   = TextEditingController(text: p?.description ?? '');
    _category = p?.category ?? 'makanan';
    if (p != null) {
      _existingImages.addAll(p.images.map((i) => MapEntry(i.id, i.url)));
    }
  }

  @override
  void dispose() { _name.dispose(); _price.dispose(); _stock.dispose(); _weight.dispose(); _desc.dispose(); super.dispose(); }

  int _parseInt(String value, {int fallback = 0}) => int.tryParse(value.trim()) ?? fallback;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final data = {
      'name': _name.text.trim(),
      'price': _parseInt(_price.text),
      'stock': _parseInt(_stock.text),
      'weight': _parseInt(_weight.text),
      'description': _desc.text.trim(),
      'category': _category,
    };
    try {
      int productId;
      if (widget.product != null) {
        await _api.updateProduct(widget.product!.id, data);
        productId = widget.product!.id;
      } else {
        final resp = await _api.createProduct(data);
        if (resp.data['data'] == null || resp.data['data']['id'] == null) {
          throw Exception('Response data tidak valid');
        }
        productId = resp.data['data']['id'];
      }
      
      // Delete removed existing images
      for (final imgId in _removedImageIds) {
        try { await _api.deleteProductImage(productId, imgId); } catch (_) {}
      }
      _removedImageIds.clear();

      // Upload newly picked images
      if (_pickedImages.isNotEmpty) {
        try {
          await _api.uploadProductImages(productId, _pickedImages);
        } catch (e) {
          if (!mounted) return;
          String uploadError = 'Gagal upload gambar';
          try {
            final resp = (e as dynamic).response;
            if (resp?.data?['message'] != null) {
              uploadError = resp.data['message'];
            }
          } catch (_) {}
          AppSnackBar.show(context, '⚠️ $uploadError, tetapi produk sudah tersimpan', isError: true);
          if (!mounted) return;
          Navigator.pop(context);
          return;
        }
      }
      
      if (!mounted) return;
      AppSnackBar.show(context, '✓ Produk berhasil ${widget.product != null ? 'diperbarui' : 'ditambahkan'}!');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      String errorMsg = 'Gagal menyimpan produk';
      try {
        final resp = (e as dynamic).response;
        if (resp?.data?['message'] != null) {
          errorMsg = resp.data['message'];
        } else if (resp?.statusCode == 401) {
          errorMsg = 'Sesi Anda telah berakhir. Silakan login kembali.';
        } else if (resp?.statusCode == 403) {
          errorMsg = 'Anda tidak memiliki akses untuk menambah produk. Pastikan Anda sudah terdaftar sebagai UMKM.';
        }
      } catch (_) {}
      AppSnackBar.show(context, errorMsg, isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.product != null ? 'Edit Produk' : 'Tambah Produk'),
      leading: BackButton(onPressed: () => context.pop()),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Image upload
          SizedBox(
            height: 96,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Existing images (edit mode)
                ..._existingImages.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Stack(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        resolveImageUrl(e.value.value),
                        width: 96, height: 96, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 96, height: 96, color: AppTheme.surface2,
                          child: const Icon(Icons.broken_image_outlined, color: AppTheme.textHint),
                        ),
                      ),
                    ),
                    Positioned(top: 4, right: 4, child: GestureDetector(
                      onTap: () => _removeExistingImage(e.key),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    )),
                  ]),
                )),
                // Newly picked images
                ..._pickedImages.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Stack(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: FutureBuilder<Uint8List>(
                        future: e.value.readAsBytes(),
                        builder: (context, snap) => snap.hasData
                            ? Image.memory(snap.data!, width: 96, height: 96, fit: BoxFit.cover)
                            : Container(width: 96, height: 96, color: AppTheme.surface2),
                      ),
                    ),
                    Positioned(top: 4, right: 4, child: GestureDetector(
                      onTap: () => _removePickedImage(e.key),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    )),
                  ]),
                )),
                GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    width: 96, height: 96,
                    decoration: BoxDecoration(color: AppTheme.surface2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
                    child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.camera_alt_outlined, size: 26, color: AppTheme.textHint),
                      SizedBox(height: 4),
                      Text('Tambah Foto', style: TextStyle(color: AppTheme.textHint, fontSize: 10)),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text('JPG, PNG, max 5MB per foto', style: TextStyle(color: AppTheme.textHint, fontSize: 11)),
          ),
          const SizedBox(height: 16),
          CustomTextField(controller: _name, label: 'Nama Produk', hint: 'Seblak Hot Level 3', prefixIcon: Icons.inventory_2_outlined,
            validator: (v) => (v?.isEmpty ?? true) ? 'Nama wajib diisi' : null),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: CustomTextField(controller: _price, label: 'Harga (Rp)', hint: '25000', prefixIcon: Icons.attach_money,
              keyboardType: TextInputType.number, validator: (v) => (v?.isEmpty ?? true) ? 'Harga wajib' : null)),
            const SizedBox(width: 12),
            Expanded(child: CustomTextField(controller: _stock, label: 'Stok', hint: '50', prefixIcon: Icons.warehouse_outlined,
              keyboardType: TextInputType.number, validator: (v) => (v?.isEmpty ?? true) ? 'Stok wajib' : null)),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Kategori', prefixIcon: Icon(Icons.category_outlined, color: AppTheme.primary, size: 20)),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: (v) => setState(() => _category = v!),
            )),
            const SizedBox(width: 12),
            Expanded(child: CustomTextField(
              controller: _weight,
              label: 'Berat (gram)',
              hint: '250',
              prefixIcon: Icons.scale_outlined,
              keyboardType: TextInputType.number,
              validator: (v) {
                if ((v ?? '').trim().isEmpty) return null;
                return int.tryParse(v!.trim()) == null ? 'Berat harus angka' : null;
              },
            )),
          ]),
          const SizedBox(height: 14),
          CustomTextField(controller: _desc, label: 'Deskripsi Produk', hint: 'Deskripsi yang menarik...', prefixIcon: Icons.description_outlined, maxLines: 4,
            validator: (v) => (v?.isEmpty ?? true) ? 'Deskripsi wajib diisi' : null),
          const SizedBox(height: 24),
          CustomButton(label: widget.product != null ? '✓ Simpan Perubahan' : '+ Tambah Produk', isLoading: _isSaving, onPressed: _save),
          const SizedBox(height: 24),
        ]),
      ),
    ),
  );
}

