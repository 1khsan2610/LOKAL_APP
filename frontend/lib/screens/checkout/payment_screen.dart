// ═══════════════════════════════════════════════════════════════════
//  PaymentScreen  —  lib/screens/checkout/payment_screen.dart
//  Prinsip desain (sinkron dgn Cart & Checkout):
//   • AppCard utk kartu info kepercayaan (trust badges)
//   • SingleChildScrollView + SafeArea → aman di layar pendek & gesture nav
//   • FittedBox pada nominal besar → tidak overflow di layar sempit
//   • Palet: bg #F8FAFC, aksen utama Navy #151B26 (AppTheme.primary)
//   Logika (polling status, launch Midtrans, lifecycle) TIDAK diubah.
// ═══════════════════════════════════════════════════════════════════
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/app_theme.dart';
import '../../utils/url_opener.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../widgets/app_card.dart';
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
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Konfirmasi Pembayaran')),
      // SingleChildScrollView + SafeArea: konten tetap aman & bisa
      // digulir penuh di layar pendek (mis. mode landscape/HP kecil),
      // dan tombol paling bawah tidak terpotong gesture nav bar.
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - 140),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(color: AppTheme.surface2, shape: BoxShape.circle),
                  child: const Center(child: Text('🔒', style: TextStyle(fontSize: 40))),
                ),
                const SizedBox(height: 20),
                // ── Hierarki 1: judul halaman ──
                const Text(
                  'Pembayaran via Midtrans',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 8),
                // ── Hierarki tertinggi: nominal total ── FittedBox
                // mencegah overflow saat total sangat besar (mis. Rp
                // 999.999.999) di layar sempit.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    currency.format(widget.total),
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.primary),
                  ),
                ),
                const SizedBox(height: 6),
                const Text('Aman & terenkripsi SSL', style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
                const SizedBox(height: 28),

                // ── Trust badges — dibungkus AppCard agar konsisten
                // dgn kartu section lain (Cart/Checkout/Beranda) ──
                AppCard(
                  padding: const EdgeInsets.all(14),
                  color: AppTheme.surface2,
                  child: const Column(
                    children: [
                      Row(children: [
                        Icon(Icons.security_rounded, size: 16, color: AppTheme.primary),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text('Transaksi dilindungi oleh Midtrans', style: TextStyle(fontSize: 12)),
                        ),
                      ]),
                      SizedBox(height: 6),
                      Row(children: [
                        Icon(Icons.verified_user_outlined, size: 16, color: AppTheme.success),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text('Garansi uang kembali tersedia', style: TextStyle(fontSize: 12)),
                        ),
                      ]),
                    ],
                  ),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Buka Halaman Bayar 💳', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _checkPaymentStatus,
                  child: const Text('Saya sudah bayar, cek status', style: TextStyle(color: AppTheme.primary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
