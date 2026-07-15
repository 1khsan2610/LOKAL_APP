import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/tracking_model.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_card.dart';

/// Halaman Pelacakan Pesanan (Order Tracking Screen)
/// Menampilkan timeline perjalanan paket dari awal hingga status terkini.
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

  /// Status halaman: loading, loaded, error
  bool _isLoading = true;
  String? _errorMessage;
  TrackingResponse? _tracking;

  @override
  void initState() {
    super.initState();
    _fetchTracking();
  }

  Future<void> _fetchTracking() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _api.getOrderTracking(widget.orderId);
      if (response.statusCode == 200 && response.data != null) {
        final parsed = TrackingResponse.fromJson(response.data);
        setState(() {
          _tracking = parsed;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat data pelacakan.';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('TrackingScreen error: $e');
      setState(() {
        _errorMessage = 'Terjadi kesalahan. Periksa koneksi internet Anda.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(
          'Lacak Pesanan',
          style: const TextStyle(fontSize: 16),
        ),
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    // ── Loading State ──
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppTheme.primary,
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Memuat data pelacakan...',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // ── Error State ──
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: AppTheme.textHint,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchTracking,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    // ── Empty State ──
    final histories = _tracking?.histories ?? [];
    if (histories.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppTheme.textHint,
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada riwayat pelacakan',
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Riwayat akan muncul setelah penjual memproses pesanan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textHint,
              ),
            ),
          ],
        ),
      );
    }

    // ── Loaded State: Timeline ──
    return RefreshIndicator(
      onRefresh: _fetchTracking,
      color: AppTheme.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // ── Header Card: Info Ringkas ──
          _buildHeaderCard(),
          const SizedBox(height: 20),

          // ── Timeline ──
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Riwayat Perjalanan',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          ...List.generate(histories.length, (index) {
            final isFirst = index == 0;
            final isLast = index == histories.length - 1;
            return _TimelineItem(
              history: histories[index],
              isFirst: isFirst,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }

  /// Kartu informasi ringkas di bagian atas
  Widget _buildHeaderCard() {
    final tracking = _tracking!;
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nomor Pesanan
          Row(
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                size: 18,
                color: AppTheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '#${tracking.orderNumber}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Status Saat Ini
          _infoRow(
            Icons.circle_rounded,
            'Status',
            _statusLabel(tracking.statusSaatIni),
            _statusColor(tracking.statusSaatIni),
          ),
          const SizedBox(height: 8),

          // Nomor Resi (jika ada)
          if (tracking.trackingNumber != null &&
              tracking.trackingNumber!.isNotEmpty) ...[
            _infoRow(
              Icons.local_shipping_rounded,
              'Nomor Resi',
              tracking.trackingNumber!,
              AppTheme.primary,
            ),
            const SizedBox(height: 8),
          ],

          // Waktu update terakhir
          if (tracking.histories.isNotEmpty)
            _infoRow(
              Icons.access_time_rounded,
              'Terakhir diperbarui',
              dateFormat.format(
                DateTime.parse(tracking.histories.first.createdAt),
              ),
              AppTheme.textHint,
            ),
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
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textHint,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  /// Label status yang user-friendly
  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'awaiting_payment':
        return 'Menunggu Pembayaran';
      case 'processing':
        return 'Diproses Penjual';
      case 'shipped':
        return 'Dikirim';
      case 'delivered':
        return 'Selesai';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
      case 'awaiting_payment':
        return AppTheme.warning;
      case 'processing':
        return AppTheme.info;
      case 'shipped':
        return AppTheme.accentDark;
      case 'delivered':
      case 'completed':
        return AppTheme.success;
      case 'cancelled':
        return AppTheme.danger;
      default:
        return AppTheme.textSecondary;
    }
  }
}

/// ─────────────────────────────────────────────────────────────────────
/// Widget satu titik pada timeline: dot + garis vertikal + kartu status
/// ─────────────────────────────────────────────────────────────────────
class _TimelineItem extends StatelessWidget {
  final TrackingHistory history;
  final bool isFirst;
  final bool isLast;

  const _TimelineItem({
    required this.history,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy · HH:mm');
    DateTime? dateTime;
    try {
      dateTime = DateTime.parse(history.createdAt);
    } catch (_) {
      // ignore invalid date
    }

    // Tentukan warna dot & aksen berdasarkan status
    final dotColor = _dotColor(history.status);
    final isActive = isFirst; // item teratas = status terkini

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Kolom Timeline (dot + garis) ──
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Dot
                Container(
                  width: isActive ? 20 : 14,
                  height: isActive ? 20 : 14,
                  margin: EdgeInsets.only(top: isActive ? 2 : 5),
                  decoration: BoxDecoration(
                    color: isActive ? dotColor : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: dotColor,
                      width: isActive ? 4 : 2.5,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: dotColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
                // Garis vertikal penghubung
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppTheme.cardBorder,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
              ],
            ),
          ),

          // ── Kartu Konten ──
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: 4,
                bottom: isLast ? 0 : 16,
              ),
              child: AppCard(
                padding: const EdgeInsets.all(14),
                color: isActive
                    ? dotColor.withValues(alpha: 0.04)
                    : AppTheme.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama Status
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _statusLabel(history.status),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  isActive ? FontWeight.w700 : FontWeight.w600,
                              color: isActive
                                  ? dotColor
                                  : AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        if (isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: dotColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Terkini',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: dotColor,
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Catatan
                    if (history.notes.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        history.notes,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],

                    // Waktu
                    if (dateTime != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: AppTheme.textHint,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dateFormat.format(dateTime),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textHint,
                            ),
                          ),
                        ],
                      ),
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
      case 'pending':
      case 'awaiting_payment':
        return AppTheme.warning;
      case 'processing':
        return AppTheme.info;
      case 'shipped':
        return AppTheme.accentDark;
      case 'delivered':
      case 'completed':
        return AppTheme.success;
      case 'cancelled':
        return AppTheme.danger;
      default:
        return AppTheme.textHint;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pesanan Dibuat';
      case 'awaiting_payment':
        return 'Menunggu Pembayaran';
      case 'processing':
        return 'Diproses Penjual';
      case 'shipped':
        return 'Dikirim';
      case 'delivered':
        return 'Pesanan Selesai';
      case 'completed':
        return 'Pesanan Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }
}