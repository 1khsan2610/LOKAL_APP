import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/product_card.dart';

class TrackingPage extends StatefulWidget {
  final int orderId;
  final String orderCode;

  const TrackingPage({super.key, required this.orderId, required this.orderCode});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final ApiService _apiService = ApiService();
  List<dynamic> _trackingLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTrackingData();
  }

  Future<void> _fetchTrackingData() async {
    setState(() => _isLoading = true);
    try {
      // Memanggil API
      final response = await _apiService.getOrderTracking(widget.orderId);

      // DEBUG: Menampilkan respon di console VS Code agar kita tahu isinya
      debugPrint("RESPON DARI BACKEND: ${response.data}");

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Memastikan data ada
        if (responseData != null && responseData['data'] != null) {
          setState(() {
            _trackingLogs = List.from(responseData['data']);
          });
        }
      }
    } catch (e) {
      debugPrint("ERROR SAAT MENGAMBIL DATA: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text('Lacak Paket #${widget.orderCode}', maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
            : _trackingLogs.isEmpty
                ? const EmptyState(
                    emoji: '🚚',
                    title: 'Belum Ada Riwayat',
                    subtitle: 'Riwayat pengiriman paket akan muncul di sini',
                  )
                : RefreshIndicator(
                    onRefresh: _fetchTrackingData,
                    color: AppTheme.primary,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      itemCount: _trackingLogs.length,
                      itemBuilder: (context, index) {
                        final log = _trackingLogs[index];
                        final isLast = index == _trackingLogs.length - 1;
                        // Item pertama dianggap status terbaru — ditandai
                        // aksen amber, sisanya riwayat sebelumnya (navy pudar).
                        final isLatest = index == 0;
                        return _TrackingTile(
                          status: log['status']?.toString() ?? 'Proses',
                          description: log['description']?.toString() ?? '-',
                          timestamp: log['updated_at']?.toString() ?? '',
                          isLatest: isLatest,
                          isLast: isLast,
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}

/// Satu titik pada linimasa pengiriman: bulatan ikon + garis penghubung di
/// kiri, kartu status di kanan. Menggantikan Card/ListTile bawaan yang
/// datar dan rawan overflow saat deskripsi/status panjang.
class _TrackingTile extends StatelessWidget {
  final String status;
  final String description;
  final String timestamp;
  final bool isLatest;
  final bool isLast;

  const _TrackingTile({
    required this.status,
    required this.description,
    required this.timestamp,
    required this.isLatest,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = isLatest ? AppTheme.accent : AppTheme.textHint;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kolom linimasa: ikon truk di titik terbaru, titik polos untuk
          // riwayat lain, dihubungkan garis vertikal.
          Column(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: isLatest ? AppTheme.accent.withValues(alpha: 0.15) : AppTheme.surface2,
                  shape: BoxShape.circle,
                  border: Border.all(color: dotColor, width: isLatest ? 2 : 1),
                ),
                child: Icon(
                  isLatest ? Icons.local_shipping_rounded : Icons.check_circle_outline,
                  size: 16,
                  color: isLatest ? AppTheme.accentDark : AppTheme.textHint,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: AppTheme.cardBorder, margin: const EdgeInsets.symmetric(vertical: 4)),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: AppCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            status,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isLatest ? AppTheme.accentDark : AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (description.isNotEmpty && description != '-') ...[
                      const SizedBox(height: 4),
                      Text(description, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                    if (timestamp.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(timestamp, style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
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
}
