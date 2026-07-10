import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/product_model.dart';
import 'add_edit_product_screen.dart';

class AddEditProductLoader extends StatefulWidget {
  final int? productId;
  const AddEditProductLoader({super.key, this.productId});
  @override
  State<AddEditProductLoader> createState() => _AddEditProductLoaderState();
}

class _AddEditProductLoaderState extends State<AddEditProductLoader> {
  final _api = ApiService();
  ProductModel? _product;
  bool _loading = false;
  String? _error;

  @override
  void initState() { super.initState(); if (widget.productId != null) _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final resp = await _api.getMyProductDetail(widget.productId!);
      _product = ProductModel.fromJson(resp.data['data']);
    } catch (e) { _error = 'Produk tidak ditemukan'; }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) return Scaffold(body: Center(child: Text(_error!)));
    return AddEditProductScreen(product: _product);
  }
}
