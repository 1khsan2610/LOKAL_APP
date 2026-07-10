import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/product_card.dart';
import '../../models/product_model.dart';

class AdminUmkmListScreen extends StatefulWidget {
  const AdminUmkmListScreen({super.key});
  @override
  State<AdminUmkmListScreen> createState() => _AdminUmkmListScreenState();
}

class _AdminUmkmListScreenState extends State<AdminUmkmListScreen> {
  final _api = ApiService();
  List<UmkmModel> _umkms = [];
  bool _isLoading = false;
  String? _filterVerified;

  @override
  void initState() {
    super.initState();
    _loadUmkms();
  }

  Future<void> _loadUmkms() async {
    setState(() => _isLoading = true);
    try {
      final resp = await _api.dio.get('/admin/umkm', queryParameters: {
        if (_filterVerified != null) 'verified': _filterVerified,
      });
      if (mounted) {
        setState(() {
          _umkms = (resp.data['data']['data'] as List)
              .map((e) => UmkmModel.fromJson(e))
              .toList();
        });
      }
    } catch (_) {
      if (mounted) AppSnackBar.show(context, 'Gagal memuat data UMKM', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyUmkm(int umkmId) async {
    try {
      await _api.dio.patch('/admin/umkm/$umkmId/verify');
      if (!mounted) return;
      AppSnackBar.show(context, '✓ UMKM berhasil diverifikasi');
      _loadUmkms();
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(context, 'Gagal memverifikasi UMKM', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola UMKM'),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<String?>(
                    segments: const [
                      ButtonSegment(value: null, label: Text('Semua')),
                      ButtonSegment(value: 'true', label: Text('Terverifikasi')),
                      ButtonSegment(value: 'false', label: Text('Menunggu')),
                    ],
                    selected: {_filterVerified},
                    onSelectionChanged: (v) {
                      setState(() => _filterVerified = v.first);
                      _loadUmkms();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : _umkms.isEmpty
                    ? const Center(child: Text('Tidak ada UMKM'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _umkms.length,
                        itemBuilder: (_, i) {
                          final umkm = _umkms[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(umkm.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                          const SizedBox(height: 4),
                                          Text('📍 ${umkm.city}', style: const TextStyle(fontSize: 12, color: AppTheme.textHint)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: umkm.isVerified ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        umkm.isVerified ? '✓ Terverifikasi' : '⏳ Menunggu',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: umkm.isVerified ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (!umkm.isVerified)
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _verifyUmkm(umkm.id),
                                      icon: const Icon(Icons.check_circle_outline, size: 16),
                                      label: const Text('Verifikasi UMKM'),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
