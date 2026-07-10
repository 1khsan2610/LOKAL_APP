import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';

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
      appBar: AppBar(title: Text('Lacak Paket ${widget.orderCode}')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _trackingLogs.isEmpty
              ? const Center(
                  child: Text('Belum ada riwayat pengiriman.', 
                  style: TextStyle(color: AppTheme.textHint)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _trackingLogs.length,
                  itemBuilder: (context, index) {
                    final log = _trackingLogs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.local_shipping, color: AppTheme.primary),
                        title: Text(log['status'] ?? 'Proses'),
                        subtitle: Text(log['description'] ?? '-'),
                        trailing: Text(log['updated_at'] ?? ''),
                      ),
                    );
                  },
                ),
    );
  }
}