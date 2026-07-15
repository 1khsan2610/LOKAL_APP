import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../models/product_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/product_card.dart';
import '../../widgets/product_manage_tile.dart';

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
    backgroundColor: AppTheme.bg,
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
                // LayoutBuilder: di layar sempit (HP) daftar tampil sebagai
                // satu kolom kartu horizontal; begitu lebar tersedia cukup
                // (tablet/desktop/Flutter web), otomatis beralih ke grid
                // kartu vertikal — supaya "Kelola Produk" tidak terasa kaku
                // memanjang ke bawah saat ruang layar sebenarnya lebih luas.
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      if (width < 700) {
                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(14, 0, 14, 90),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) {
                            final p = _filtered[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: ProductManageTile(
                                product: p,
                                onEdit: () => context.push('/umkm/products/form?id=${p.id}').then((_) => _load()),
                                onDelete: () => _confirmDelete(p),
                              ),
                            );
                          },
                        );
                      }
                      final crossAxisCount = width < 1000 ? 3 : width < 1300 ? 4 : 5;
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 90),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.78,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) {
                          final p = _filtered[i];
                          return ProductManageGridTile(
                            product: p,
                            onEdit: () => context.push('/umkm/products/form?id=${p.id}').then((_) => _load()),
                            onDelete: () => _confirmDelete(p),
                          );
                        },
                      );
                    },
                  ),
      ),
    ]),
  );
}
