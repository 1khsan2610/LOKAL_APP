// ═══════════════════════════════════════════════════════════════════
//  TrackingScreen  —  lib/screens/order/tracking_screen.dart
//  UX/UI Refactor: Full order tracking with timeline, receipt card,
//  "Pesanan Diterima" button (active only when delivered), support section.
// ═══════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/tracking_model.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/product_card.dart';

/// Halaman Pelacakan Pesanan (Order Tracking Screen)
class TrackingScreen extends StatefulWidget {
  final int orderId;
  final String orderNumber;

  const TrackingScreen({
    super.key,
    required this.orderId,
    required this.orderNumber,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  String? _errorMessage;
  TrackingResponse? _tracking;
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    _fetchTracking();
  }

  Future<void> _fetchTracking() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final response = await _api.getOrderTracking(widget.orderId);
      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          _tracking = TrackingResponse.fromJson(response.data);
          _isLoading = false;
        });
      } else {
        setState(() { _errorMessage = 'Gagal memuat data pelacakan.'; _isLoading = false; });
      }
    } catch (e) {
      setState(() { _errorMessage = 'Terjadi kesalahan. Periksa koneksi internet Anda.'; _isLoading = false; });
    }
  }

  Future<void> _confirmReceived() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Pesanan Diterima'),
        content: const Text('Pastikan barang sudah kamu terima dengan baik. Lokal Coin akan ditambahkan ke akunmu setelah ini.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Belum')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Sudah Diterima'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isConfirming = true);
    try {
      await _api.confirmReceived(widget.orderId);
      if (!mounted) return;
      AppSnackBar.show(context, '✓ Pesanan dikonfirmasi diterima. Lokal Coin kamu bertambah! 🪙');
      _fetchTracking();
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(context, 'Gagal mengonfirmasi pesanan', isError: true);
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Order Tracking'),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 3),
          SizedBox(height: 16),
          Text('Memuat data pelacakan...', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
        ]),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: AppTheme.textHint),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary)),
            const SizedBox(height: 24),
            ElevatedButton.icon(onPressed: _fetchTracking, icon: const Icon(Icons.refresh_rounded, size: 18), label: const Text('Coba Lagi')),
          ]),
        ),
      );
    }

    final histories = _tracking?.histories ?? [];
    final isDelivered = _tracking?.statusSaatIni == 'delivered' || _tracking?.statusSaatIni == 'completed';
    final isShipped = _tracking?.statusSaatIni == 'shipped';

    return RefreshIndicator(
      onRefresh: _fetchTracking,
      color: AppTheme.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // ── Header: Order Info Card ──
          _buildHeaderCard(),
          const SizedBox(height: 16),

          // ── Tracking Number Card ──
          if (_tracking?.trackingNumber != null && _tracking!.trackingNumber!.isNotEmpty) ...[
            _buildTrackingNumberCard(),
            const SizedBox(height: 16),
          ],

          // ── Timeline ──
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text('Riwayat Perjalanan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          ),
          if (histories.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('Belum ada riwayat pelacakan', style: TextStyle(fontSize: 13, color: AppTheme.textHint)),
            )
          else
            ...List.generate(histories.length, (index) {
              final isFirst = index == 0;
              final isLast = index == histories.length - 1;
              return _TimelineItem(history: histories[index], isFirst: isFirst, isLast: isLast);
            }),

          const SizedBox(height: 20),

          // ── Confirm Received Button ──
          if (isDelivered)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isConfirming ? null : _confirmReceived,
                icon: _isConfirming
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_circle_outline, size: 20),
                label: Text(_isConfirming ? 'Mengonfirmasi...' : 'Pesanan Diterima ✓'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.success,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

          if (isShipped)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isConfirming ? null : _confirmReceived,
                icon: _isConfirming
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_circle_outline, size: 20),
                label: Text(_isConfirming ? 'Mengonfirmasi...' : 'Konfirmasi Penerimaan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

          const SizedBox(height: 16),

          // ── Help Section ──
          _buildHelpCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    final tracking = _tracking!;
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_rounded, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text('#${tracking.orderNumber}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.receipt_long_rounded, 'Order ID', '#${tracking.orderNumber}', AppTheme.textPrimary),
          const SizedBox(height: 6),
          _infoRow(Icons.circle_rounded, 'Status', _statusLabel(tracking.statusSaatIni), _statusColor(tracking.statusSaatIni)),
          if (tracking.histories.isNotEmpty) ...[
            const SizedBox(height: 6),
            _infoRow(Icons.access_time_rounded, 'Update', dateFormat.format(DateTime.parse(tracking.histories.first.createdAt)), AppTheme.textHint),
          ],
        ],
      ),
    );
  }

  Widget _buildTrackingNumberCard() {
    final tracking = _tracking!;
    return AppCard(
      padding: const EdgeInsets.all(16),
      color: AppTheme.primary.withValues(alpha: 0.03),
      child: Column(children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.local_shipping_rounded, size: 20, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('No. Resi Pengiriman', style: TextStyle(fontSize: 11, color: AppTheme.textHint)),
              const SizedBox(height: 2),
              Text(tracking.trackingNumber!,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: tracking.trackingNumber!));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Nomor resi disalin'), duration: Duration(seconds: 2)),
                );
              }
            },
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Salin Resi'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildHelpCard() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      color: AppTheme.surface2,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.headset_mic_outlined, size: 20, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Need help?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              SizedBox(height: 2),
              Text('Chat with our 24/7 support', style: TextStyle(fontSize: 11, color: AppTheme.textHint)),
            ]),
          ),
          const Icon(Icons.chevron_right, size: 20, color: AppTheme.textHint),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textHint))),
        Expanded(
          child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ),
      ],
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending': case 'awaiting_payment': return 'Menunggu Pembayaran';
      case 'processing': return 'Diproses Penjual';
      case 'shipped': return 'Dalam Pengiriman';
      case 'delivered': case 'completed': return 'Selesai';
      case 'cancelled': return 'Dibatalkan';
      default: return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': case 'awaiting_payment': return AppTheme.warning;
      case 'processing': return AppTheme.info;
      case 'shipped': return AppTheme.accentDark;
      case 'delivered': case 'completed': return AppTheme.success;
      case 'cancelled': return AppTheme.danger;
      default: return AppTheme.textSecondary;
    }
  }
}

/// ── Timeline Item ──
class _TimelineItem extends StatelessWidget {
  final TrackingHistory history;
  final bool isFirst;
  final bool isLast;

  const _TimelineItem({required this.history, required this.isFirst, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy · HH:mm');
    DateTime? dateTime;
    try { dateTime = DateTime.parse(history.createdAt); } catch (_) {}

    final dotColor = _dotColor(history.status);
    final isActive = isFirst;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column (dot + line)
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: isActive ? 20 : 14,
                  height: isActive ? 20 : 14,
                  margin: EdgeInsets.only(top: isActive ? 2 : 5),
                  decoration: BoxDecoration(
                    color: isActive ? dotColor : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: dotColor, width: isActive ? 4 : 2.5),
                    boxShadow: isActive ? [BoxShadow(color: dotColor.withValues(alpha: 0.3), blurRadius: 8, spreadRadius: 1)] : null,
                  ),
                ),
                if (!isLast)
                  Expanded(child: Container(width: 2, color: AppTheme.cardBorder, margin: const EdgeInsets.symmetric(vertical: 4))),
              ],
            ),
          ),
          // Content card
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 4, bottom: isLast ? 0 : 16),
              child: AppCard(
                padding: const EdgeInsets.all(14),
                color: isActive ? dotColor.withValues(alpha: 0.04) : AppTheme.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _statusLabel(history.status),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                              color: isActive ? dotColor : AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        if (isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: dotColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
                            child: Text('Terkini', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: dotColor)),
                          ),
                      ],
                    ),
                    if (history.notes.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(history.notes, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4)),
                    ],
                    if (dateTime != null) ...[
                      const SizedBox(height: 8),
                      Row(children: [
                        Icon(Icons.access_time_rounded, size: 12, color: AppTheme.textHint),
                        const SizedBox(width: 4),
                        Text(dateFormat.format(dateTime), style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
                      ]),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _dotColor(String status) {
    switch (status) {
      case 'pending': case 'awaiting_payment': return AppTheme.warning;
      case 'processing': return AppTheme.info;
      case 'shipped': return AppTheme.accentDark;
      case 'delivered': case 'completed': return AppTheme.success;
      case 'cancelled': return AppTheme.danger;
      default: return AppTheme.textHint;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending': return 'Pesanan Dibuat';
      case 'awaiting_payment': return 'Menunggu Pembayaran';
      case 'processing': return 'Diproses Penjual';
      case 'shipped': return 'Dikirim';
      case 'delivered': return 'Pesanan Selesai';
      case 'completed': return 'Pesanan Selesai';
      case 'cancelled': return 'Dibatalkan';
      default: return status;
    }
  }
}