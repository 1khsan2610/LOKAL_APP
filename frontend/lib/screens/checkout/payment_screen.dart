import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/app_theme.dart';
import '../../utils/url_opener.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../widgets/product_card.dart';

class PaymentScreen extends StatefulWidget {
  final String snapToken;
  final String? snapUrl;
  final int orderId;
  final int total;

  const PaymentScreen({
    super.key,
    required this.snapToken,
    this.snapUrl,
    required this.orderId,
    required this.total,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> with WidgetsBindingObserver {
  final _api = ApiService();
  bool _didLaunch = false;
  bool _isCheckingStatus = false;
  Timer? _statusTimer;
  String _statusText = 'Menunggu konfirmasi pembayaran dari Midtrans...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _launchPaymentUrl();
      _startStatusPolling();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _statusTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPaymentStatus();
    }
  }

  Future<void> _launchPaymentUrl() async {
    if (_didLaunch) return;
    _didLaunch = true;

    final targetUrl = (widget.snapUrl != null && widget.snapUrl!.isNotEmpty)
        ? widget.snapUrl!
        : 'https://app.sandbox.midtrans.com/snap/v2/vtweb/${widget.snapToken}';

    if (!await openBrowserUrl(targetUrl)) {
      if (!mounted) return;
      AppSnackBar.show(context, 'Tidak bisa membuka halaman pembayaran', isError: true);
    }
  }

  void _startStatusPolling() {
    _statusTimer?.cancel();
    _checkPaymentStatus();
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (_) => _checkPaymentStatus());
  }

  Future<void> _checkPaymentStatus() async {
    if (_isCheckingStatus) return;
    _isCheckingStatus = true;
    try {
      final resp = await _api.getPaymentStatus(widget.orderId);
      final data = resp.data['data'] as Map<String, dynamic>;
      final orderStatus = data['order_status']?.toString();
      final paymentStatus = data['payment_status']?.toString();

      if (!mounted) return;
      if (paymentStatus == 'paid' || orderStatus == 'shipped') {
        _statusTimer?.cancel();
        context.go('/order/success/${widget.orderId}');
        return;
      }

      if (kDebugMode && paymentStatus == 'pending') {
        _statusTimer?.cancel();
        context.go('/order/success/${widget.orderId}');
        return;
      }

      setState(() {
        _statusText = paymentStatus == 'pending'
            ? 'Pembayaran belum selesai. Selesaikan pembayaran di halaman Midtrans.'
            : 'Status pembayaran: ${paymentStatus ?? 'menunggu'}';
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _statusText = 'Belum bisa membaca status pembayaran. Coba cek lagi sebentar lagi.';
        });
      }
    } finally {
      _isCheckingStatus = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // In production, load Midtrans Snap URL via WebView
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Konfirmasi Pembayaran')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 80, height: 80,
              decoration: const BoxDecoration(color: AppTheme.surface2, shape: BoxShape.circle),
              child: const Center(child: Text('🔒', style: TextStyle(fontSize: 40))),
            ),
            const SizedBox(height: 20),
            const Text('Pembayaran via Midtrans',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Total: ${currency.format(widget.total)}',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.primary)),
            const SizedBox(height: 6),
            const Text('Aman & terenkripsi SSL', style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppTheme.surface2, borderRadius: BorderRadius.circular(12)),
              child: const Column(children: [
                Row(children: [
                  Icon(Icons.security_rounded, size: 16, color: AppTheme.primary),
                  SizedBox(width: 8),
                  Text('Transaksi dilindungi oleh Midtrans', style: TextStyle(fontSize: 12)),
                ]),
                SizedBox(height: 6),
                Row(children: [
                  Icon(Icons.verified_user_outlined, size: 16, color: AppTheme.success),
                  SizedBox(width: 8),
                  Text('Garansi uang kembali tersedia', style: TextStyle(fontSize: 12)),
                ]),
              ]),
            ),
            const SizedBox(height: 14),
            Text(
              _statusText,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _launchPaymentUrl,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Buka Halaman Bayar 💳', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _checkPaymentStatus,
              child: const Text('Saya sudah bayar, cek status', style: TextStyle(color: AppTheme.primary)),
            ),
          ]),
        ),
      ),
    );
  }
}
