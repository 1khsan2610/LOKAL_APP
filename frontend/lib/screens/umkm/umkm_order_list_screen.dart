import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/product_card.dart';
import '../../widgets/app_card.dart';

class UmkmOrderListScreen extends StatefulWidget {
  const UmkmOrderListScreen({super.key});

  @override
  State<UmkmOrderListScreen> createState() => _UmkmOrderListScreenState();
}

class _UmkmOrderListScreenState extends State<UmkmOrderListScreen> {
  final _api = ApiService();
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String? _status;
  final Set<int> _updatingIds = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({String? status}) async {
    setState(() {
      _isLoading = true;
      _status = status;
    });

    try {
      final resp = await _api.getUmkmOrders(status: status);
      setState(() {
        final rawData = resp.data['data']['data'];
        _orders = (rawData is List ? rawData : []).cast<Map<String, dynamic>>();
      });
    } catch (_) {
      setState(() => _orders = []);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(dynamic order, String status) async {
    final id = order['id'];

    // Jika status 'shipped', minta tracking number dulu
    String? trackingNumber;
    if (status == 'shipped') {
      final controller = TextEditingController();
      final result = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Nomor Resi Pengiriman'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Masukkan nomor resi pengiriman:', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Contoh: JNE001234567',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('Kirim'),
            ),
          ],
        ),
      );
      if (result == null || result.isEmpty) {
        if (mounted) setState(() => _updatingIds.remove(id));
        return;
      }
      trackingNumber = result;
    }

    setState(() => _updatingIds.add(id));

    Map<String, dynamic> payload = {'status': status};
    if (status == 'shipped' && trackingNumber != null) {
      payload['tracking_number'] = trackingNumber;
      payload['notes'] = 'Pesanan telah dikirim dengan nomor resi: $trackingNumber';
    }

    try {
      await _api.dio.patch('/umkm/orders/$id/status', data: payload);
      if (!mounted) return;
      AppSnackBar.show(context, 'Status pesanan #${order['order_number']} diubah');
      _load(status: _status);
    } catch (e) {
      if (!mounted) return;
      String msg = 'Gagal mengubah status';
      try {
        final resp = (e as dynamic).response;
        if (resp?.data?['message'] != null) msg = resp.data['message'];
      } catch (_) {}
      AppSnackBar.show(context, msg, isError: true);
    } finally {
      if (mounted) setState(() => _updatingIds.remove(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ['Semua', 'Pending', 'Diproses', 'Dikirim', 'Selesai', 'Batal'];
    final statuses = [null, 'pending', 'processing', 'shipped', 'delivered', 'cancelled'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan UMKM'),
        leading: BackButton(onPressed: () => context.pop()),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, index) {
                final selected = _status == statuses[index];
                return ChoiceChip(
                  label: Text(tabs[index]),
                  selected: selected,
                  onSelected: (_) => _load(status: statuses[index]),
                  selectedColor: AppTheme.primary,
                  labelStyle: TextStyle(color: selected ? Colors.white : AppTheme.textSecondary),
                );
              },
            ),
          ),
        ),
      ),
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _orders.isEmpty
              ? const EmptyState(emoji: '📦', title: 'Belum Ada Pesanan', subtitle: 'Pesanan dari pembeli akan muncul di sini')
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                  itemCount: _orders.length,
                  itemBuilder: (_, index) {
                    final order = _orders[index];
                    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
                    final status = order['status']?.toString() ?? '';
                    final isLoading = _updatingIds.contains(order['id']);
                    final dateStr = order['created_at']?.toString().substring(0, 10) ?? '-';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text('#${order['order_number']}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700))),
                                const SizedBox(width: 8),
                                StatusBadge(status: status),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('Pembeli: ${order['user']?['name'] ?? '-'}', style: const TextStyle(fontSize: 12, color: AppTheme.textHint), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 6),
                            Text('Total: ${currency.format(order['total'] ?? 0)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 3),
                            Text(dateStr, style: const TextStyle(fontSize: 12, color: AppTheme.textHint)),
                            if (status == 'pending' || status == 'processing' || status == 'shipped') ...[
                              const SizedBox(height: 8),
                              // Wrap: tombol aksi menyusun ulang ke baris baru
                              // di layar sempit alih-alih overflow di kanan.
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (status == 'pending')
                                    _ActionButton(label: 'Proses', color: AppTheme.primary, isLoading: isLoading, onTap: () => _updateStatus(order, 'processing')),
                                  if (status == 'processing')
                                    _ActionButton(label: 'Kirim', color: Colors.orange, isLoading: isLoading, onTap: () => _updateStatus(order, 'shipped')),
                                  if (status == 'shipped')
                                    _ActionButton(label: 'Selesai', color: Colors.green, isLoading: isLoading, onTap: () => _updateStatus(order, 'delivered')),
                                  if (status == 'pending' || status == 'processing')
                                    _ActionButton(label: 'Batalkan', color: AppTheme.danger, isLoading: isLoading, onTap: () => _updateStatus(order, 'cancelled')),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;
  const _ActionButton({required this.label, required this.color, required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
        : GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
              child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          );
  }
}
