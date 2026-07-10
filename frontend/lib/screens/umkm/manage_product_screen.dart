import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../models/product_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/image_helper.dart';
import '../../widgets/product_card.dart';

class ManageProductScreen extends StatefulWidget {
  const ManageProductScreen({super.key});
  @override
  State<ManageProductScreen> createState() => _ManageProductScreenState();
}

class _ManageProductScreenState extends State<ManageProductScreen> {
  final _api = ApiService();
  List<ProductModel> _products = [];
  bool _isLoading = true;
  String _searchQ = '';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final resp = await _api.getMyProducts();
      setState(() { _products = (resp.data['data']['data'] as List).map((e) => ProductModel.fromJson(e)).toList(); });
    } catch (_) {} finally { setState(() => _isLoading = false); }
  }

  List<ProductModel> get _filtered => _searchQ.isEmpty ? _products
      : _products.where((p) => p.name.toLowerCase().contains(_searchQ.toLowerCase())).toList();

  Future<void> _checkUmkmAndAddProduct() async {
    try {
      await _api.getMyStore();
      if (!mounted) return;
      context.push('/umkm/products/form').then((_) => _load());
    } catch (e) {
      if (!mounted) return;
      String msg = 'Gagal mengakses toko Anda';
      try {
        final resp = (e as dynamic).response;
        if (resp?.statusCode == 403) {
          msg = 'Toko UMKM Anda belum terdaftar. Hubungi administrator.';
        } else if (resp?.statusCode == 401) {
          msg = 'Sesi Anda telah berakhir. Silakan login kembali.';
        } else if (resp?.data?['message'] != null) {
          msg = resp.data['message'];
        }
      } catch (_) {}
      AppSnackBar.show(context, msg, isError: true);
    }
  }

  Future<void> _confirmDelete(ProductModel product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Yakin ingin menghapus "${product.name}"? Produk akan dinonaktifkan dan tidak akan muncul di toko.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), style: TextButton.styleFrom(foregroundColor: AppTheme.danger), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _api.deleteProduct(product.id);
      if (!mounted) return;
      AppSnackBar.show(context, '🗑️ Produk ${product.name} berhasil dihapus');
      _load();
    } catch (e) {
      if (!mounted) return;
      String msg = 'Gagal menghapus produk';
      try {
        final resp = (e as dynamic).response;
        if (resp?.data?['message'] != null) msg = resp.data['message'];
      } catch (_) {}
      AppSnackBar.show(context, msg, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Kelola Produk')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _checkUmkmAndAddProduct,
      backgroundColor: AppTheme.primary,
      icon: const Icon(Icons.add),
      label: const Text('Tambah Produk'),
    ),
    body: Column(children: [
      Padding(
        padding: const EdgeInsets.all(14),
        child: TextField(
          onChanged: (v) => setState(() => _searchQ = v),
          decoration: const InputDecoration(
            hintText: 'Cari produk...', prefixIcon: Icon(Icons.search, color: AppTheme.primary),
          ),
        ),
      ),
      Expanded(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
            : _filtered.isEmpty
                ? const EmptyState(emoji: '📦', title: 'Belum Ada Produk', subtitle: 'Tambahkan produk pertama kamu!')
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final p = _filtered[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
                        child: Row(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: SizedBox(
                              width: 58, height: 58,
                              child: p.primaryImage != null
                                  ? Image.network(resolveImageUrl(p.primaryImage), fit: BoxFit.cover)
                                  : Container(color: AppTheme.surface2, child: const Icon(Icons.image_outlined)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(p.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 3),
                            Row(children: [
                              PriceText(p.price, fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w700),
                              const SizedBox(width: 10),
                              Text('Stok: ${p.stock}', style: TextStyle(fontSize: 11, color: p.stock < 5 ? AppTheme.danger : AppTheme.textHint)),
                            ]),
                            Text('${p.soldCount} terjual · ⭐${p.avgRating.toStringAsFixed(1)}', style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
                          ])),
                          PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'edit') context.push('/umkm/products/form?id=${p.id}').then((_) => _load());
                              if (v == 'delete') _confirmDelete(p);
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'edit',   child: Text('✏️ Edit')),
                              PopupMenuItem(value: 'delete', child: Text('🗑️ Hapus', style: TextStyle(color: AppTheme.danger))),
                            ],
                          ),
                        ]),
                      );
                    },
                  ),
      ),
    ]),
  );
}

