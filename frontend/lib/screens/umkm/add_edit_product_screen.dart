import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import '../../models/product_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/image_helper.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/product_card.dart';

/// Halaman Tambah/Edit Produk dengan layout kiri (foto) & kanan (form)
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
  final List<MapEntry<int, String>> _existingImages = [];
  final Set<int> _removedImageIds = {};
  final _picker = ImagePicker();

  // Category label mapping for display
  final Map<String, String> _catLabels = {
    'makanan': 'Makanan',
    'minuman': 'Minuman',
    'fashion': 'Fashion',
    'kerajinan': 'Kerajinan',
    'bahan_pokok': 'Bahan Pokok',
  };

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
  void dispose() {
    _name.dispose();
    _price.dispose();
    _stock.dispose();
    _weight.dispose();
    _desc.dispose();
    super.dispose();
  }

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

      for (final imgId in _removedImageIds) {
        try { await _api.deleteProductImage(productId, imgId); } catch (_) {}
      }
      _removedImageIds.clear();

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
          context.pop();
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
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(widget.product != null ? 'Edit Produk' : 'Tambah Produk Baru'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
            ),
            // ── Fixed Bottom Buttons ──────────────────────────────
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── LEFT: Photo Section ───────────────────────────────
            Expanded(
              flex: 5,
              child: _buildPhotoSection(),
            ),
            const SizedBox(width: 24),
            // ── RIGHT: Form Section ───────────────────────────────
            Expanded(
              flex: 7,
              child: Column(
                children: [
                  _buildBasicInfoSection(),
                  const SizedBox(height: 16),
                  _buildPricingSection(),
                  const SizedBox(height: 16),
                  _buildCategorySection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPhotoSection(),
            const SizedBox(height: 16),
            _buildBasicInfoSection(),
            const SizedBox(height: 16),
            _buildPricingSection(),
            const SizedBox(height: 16),
            _buildCategorySection(),
          ],
        ),
      ),
    );
  }

  /// ── Photo Upload Section ──────────────────────────────────────────
  Widget _buildPhotoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.image_outlined, size: 18, color: AppTheme.primary),
              SizedBox(width: 8),
              Text('Foto Produk', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Upload foto produk yang jelas untuk menarik pembeli',
            style: TextStyle(fontSize: 11, color: AppTheme.textHint)),
          const SizedBox(height: 14),

          // Main photo dropzone
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppTheme.surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child: _pickedImages.isNotEmpty || _existingImages.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _pickedImages.isNotEmpty
                          ? FutureBuilder<Uint8List>(
                              future: _pickedImages.first.readAsBytes(),
                              builder: (_, snap) => snap.hasData
                                  ? Image.memory(snap.data!, width: double.infinity, height: 200, fit: BoxFit.cover)
                                  : const Center(child: CircularProgressIndicator()),
                            )
                          : Image.network(
                              resolveImageUrl(_existingImages.first.value),
                              width: double.infinity, height: 200, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, size: 48, color: AppTheme.textHint),
                            ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_outlined, size: 48, color: AppTheme.primary.withValues(alpha: 0.5)),
                        const SizedBox(height: 8),
                        const Text('Tap untuk upload foto utama', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                        const SizedBox(height: 4),
                        const Text('Ukuran: 1000x1000px (1:1)', style: TextStyle(fontSize: 10, color: AppTheme.textHint)),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Tips: Foto produk dengan latar polos dan pencahayaan yang baik',
            style: TextStyle(fontSize: 10, color: AppTheme.warning, fontWeight: FontWeight.w500)),

          // ── Additional Photos ───────────────────────────────────
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Existing images
                ..._existingImages.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        resolveImageUrl(e.value.value),
                        width: 80, height: 80, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80, height: 80, color: AppTheme.surface2,
                          child: const Icon(Icons.broken_image_outlined, color: AppTheme.textHint),
                        ),
                      ),
                    ),
                    Positioned(top: 4, right: 4, child: GestureDetector(
                      onTap: () => _removeExistingImage(e.key),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.close, size: 12, color: Colors.white),
                      ),
                    )),
                  ]),
                )),
                // Newly picked images (skip first which is main)
                ..._pickedImages.asMap().entries.skip(1).map((e) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: FutureBuilder<Uint8List>(
                        future: e.value.readAsBytes(),
                        builder: (_, snap) => snap.hasData
                            ? Image.memory(snap.data!, width: 80, height: 80, fit: BoxFit.cover)
                            : Container(width: 80, height: 80, color: AppTheme.surface2),
                      ),
                    ),
                    Positioned(top: 4, right: 4, child: GestureDetector(
                      onTap: () => _removePickedImage(e.key + 1),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.close, size: 12, color: Colors.white),
                      ),
                    )),
                  ]),
                )),
                // Add more button
                if (_pickedImages.length + _existingImages.length < 4)
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.surface2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 24, color: AppTheme.primary.withValues(alpha: 0.5)),
                          const Text('Tambah', style: TextStyle(fontSize: 9, color: AppTheme.textHint)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text('JPG, PNG, max 5MB per foto', style: TextStyle(fontSize: 10, color: AppTheme.textHint)),
        ],
      ),
    );
  }

  /// ── Basic Info Section ────────────────────────────────────────────
  Widget _buildBasicInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: AppTheme.primary),
              SizedBox(width: 8),
              Text('Info Dasar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),

          // Nama Produk
          const Text('Nama Produk', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _name,
            decoration: _inputDecoration(hint: 'Seblak Hot Level 3', icon: Icons.inventory_2_outlined),
            validator: (v) => (v?.isEmpty ?? true) ? 'Nama wajib diisi' : null,
          ),
          const SizedBox(height: 16),

          // Deskripsi Produk
          const Text('Deskripsi Produk', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _desc,
            maxLines: 4,
            decoration: _inputDecoration(
              hint: 'Deskripsi yang menarik...',
              icon: Icons.description_outlined,
            ).copyWith(
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 64),
                child: Icon(Icons.description_outlined, size: 20, color: AppTheme.primary),
              ),
            ),
            validator: (v) => (v?.isEmpty ?? true) ? 'Deskripsi wajib diisi' : null,
          ),
        ],
      ),
    );
  }

  /// ── Pricing Section ───────────────────────────────────────────────
  Widget _buildPricingSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.attach_money_outlined, size: 18, color: AppTheme.primary),
              SizedBox(width: 8),
              Text('Harga & Stok', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Harga (Rp)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _price,
                    decoration: _inputDecoration(hint: '25000', icon: Icons.attach_money),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v?.isEmpty ?? true) ? 'Harga wajib' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Stok', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _stock,
                    decoration: _inputDecoration(hint: '50', icon: Icons.warehouse_outlined),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v?.isEmpty ?? true) ? 'Stok wajib' : null,
                  ),
                ],
              ),
            ),
          ]),
        ],
      ),
    );
  }

  /// ── Category Section ──────────────────────────────────────────────
  Widget _buildCategorySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.category_outlined, size: 18, color: AppTheme.primary),
              SizedBox(width: 8),
              Text('Berat & Kategori', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Kategori', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    isExpanded: true,
                    decoration: _inputDecoration(hint: 'Pilih kategori', icon: Icons.category_outlined),
                    items: _categories.map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(_catLabels[c] ?? c, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                    )).toList(),
                    onChanged: (v) => setState(() => _category = v!),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Berat (gram)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _weight,
                    decoration: _inputDecoration(hint: '250', icon: Icons.scale_outlined),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if ((v ?? '').trim().isEmpty) return null;
                      return int.tryParse(v!.trim()) == null ? 'Berat harus angka' : null;
                    },
                  ),
                ],
              ),
            ),
          ]),
        ],
      ),
    );
  }

  /// ── Bottom Action Bar ─────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 12,
        bottom: MediaQuery.of(context).viewPadding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: OutlinedButton(
                onPressed: _isSaving ? null : () => context.pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textSecondary,
                  side: BorderSide(color: AppTheme.cardBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Simpan Sebagai Draft', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.primary.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(
                        widget.product != null ? 'Simpan Perubahan' : 'Simpan & Publikasikan',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppTheme.textHint, fontSize: 14),
      prefixIcon: Icon(icon, size: 20, color: AppTheme.primary),
      filled: true,
      fillColor: AppTheme.bg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.danger),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}