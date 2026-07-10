import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/product_model.dart';
import 'product_detail_screen.dart';

class ProductDetailLoader extends StatefulWidget {
  final int productId;
  const ProductDetailLoader({super.key, required this.productId});

  @override
  State<ProductDetailLoader> createState() => _ProductDetailLoaderState();
}

class _ProductDetailLoaderState extends State<ProductDetailLoader> {
  final _api = ApiService();
  ProductModel? _product;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final resp = await _api.getProductDetail(widget.productId);
      final data = resp.data['data'];
      setState(() => _product = ProductModel.fromJson(data));
    } catch (e) {
      setState(() => _error = 'Gagal memuat produk');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) return Scaffold(body: Center(child: Text(_error!)));
    return ProductDetailScreen(product: _product!);
  }
}
