import 'dart:async';

import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/order_model.dart';
import 'order_success_screen.dart';

class OrderSuccessLoader extends StatefulWidget {
  final int orderId;
  const OrderSuccessLoader({super.key, required this.orderId});
  @override
  State<OrderSuccessLoader> createState() => _OrderSuccessLoaderState();
}

class _OrderSuccessLoaderState extends State<OrderSuccessLoader> {
  final _api = ApiService();
  OrderModel? _order;
  bool _loading = true;
  String? _error;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final resp = await _api.getOrderDetail(widget.orderId);
      _order = OrderModel.fromJson(resp.data['data']);
      _updatePolling();
    } catch (e) {
      _error = 'Gagal memuat detail pesanan';
    }
    if (mounted) setState(() => _loading = false);
  }

  void _updatePolling() {
    _pollTimer?.cancel();
    if (_order == null) return;
    final status = _order!.status;
    if (status == 'pending' || status == 'awaiting_payment') {
      _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
        try {
          final resp = await _api.getOrderDetail(widget.orderId);
          final updated = OrderModel.fromJson(resp.data['data']);
          if (mounted) {
            setState(() {
              _order = updated;
            });
          }
          if (updated.status != 'pending' && updated.status != 'awaiting_payment') {
            _pollTimer?.cancel();
          }
        } catch (_) {
          // Ignore polling errors and retry on next tick.
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) return Scaffold(body: Center(child: Text(_error!)));
    return OrderSuccessScreen(order: _order!);
  }
}
