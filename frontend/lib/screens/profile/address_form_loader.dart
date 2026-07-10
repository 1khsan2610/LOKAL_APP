import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/product_model.dart';
import 'address_form_screen.dart';

class AddressFormLoader extends StatefulWidget {
  final int? addressId;
  const AddressFormLoader({super.key, this.addressId});
  @override
  State<AddressFormLoader> createState() => _AddressFormLoaderState();
}

class _AddressFormLoaderState extends State<AddressFormLoader> {
  final _api = ApiService();
  AddressModel? _address;
  bool _loading = false;
  String? _error;

  @override
  void initState() { super.initState(); if (widget.addressId != null) _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final resp = await _api.getAddresses();
      final list = (resp.data['data'] as List).map((e) => AddressModel.fromJson(e)).toList();
      _address = list.firstWhere((a) => a.id == widget.addressId, orElse: () => throw Exception('not found'));
    } catch (e) { _error = 'Alamat tidak ditemukan'; }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) return Scaffold(body: Center(child: Text(_error!)));
    return AddressFormScreen(address: _address);
  }
}
