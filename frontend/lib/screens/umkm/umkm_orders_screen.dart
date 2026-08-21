import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';

class UmkmOrdersScreen extends StatefulWidget {
  const UmkmOrdersScreen({super.key});
  @override
  State<UmkmOrdersScreen> createState() => _UmkmOrdersScreenState();
}

class _UmkmOrdersScreenState extends State<UmkmOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _api = ApiService();
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  int _updatingId = 0;

  final _tabs = ['Perlu Diproses', 'Dikirim', 'Selesai', 'Semua'];
  final _statuses = ['pending,awaiting_payment,processing', 'shipped', 'delivered', null];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _tabCtrl.addListener(() { if (_tabCtrl.indexIsChanging) _load(_statuses[_tabCtrl.index]); });
    _load(null);
  }

  Future<void> _load(String? status) async {
    setState(() { _isLoading = true; _orders = []; });
    try {
      final resp = await _api.getUmkmOrders(status: status);
      setState(() {
        _orders = (resp.data['data']['data'] as List).map((e) => e as Map<String, dynamic>).toList();
      });
    } catch (_) {} finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(int id, String status, {String? trackingNumber}) async {
    setState(() => _updatingId = id);
    try {
      final payload = <String, dynamic>{'status': status};
      if (trackingNumber != null) payload['tracking_number'] = trackingNumber;
      await _api.updateUmkmOrderStatus(id, payload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(status == 'shipped' ? '✅ Pesanan dikirim' : '✅ Status diperbarui')),
        );
        _load(_statuses[_tabCtrl.index]);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Gagal: $e'), backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _updatingId = 0);
    }
  }

  void _showShippingModal(int orderId) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 4, height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text('Kirim Pesanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 6),
            const Text('Masukkan nomor resi pengiriman', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Nomor Resi *',
                hintText: 'Contoh: JNE001234567',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.local_shipping_outlined),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final resi = controller.text.trim();
                  if (resi.isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Nomor resi wajib diisi!'), backgroundColor: AppTheme.danger),
                    );
                    return;
                  }
                  Navigator.pop(ctx);
                  _updateStatus(orderId, 'shipped', trackingNumber: resi);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Konfirmasi Kirim', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'pending': return 'Menunggu Bayar';
      case 'awaiting_payment': return 'Menunggu Pembayaran';
      case 'processing': return 'Diproses';
      case 'shipped': return 'Dikirim';
      case 'delivered': return 'Selesai';
      case 'cancelled': return 'Dibatalkan';
      default: return s;
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'pending': case 'awaiting_payment': return AppTheme.warning;
      case 'processing': return AppTheme.info;
      case 'shipped': return AppTheme.accentDark;
      case 'delivered': return AppTheme.success;
      case 'cancelled': return AppTheme.danger;
      default: return AppTheme.textHint;
    }
  }

  Color _statusBgColor(String s) {
    switch (s) {
      case 'pending': case 'awaiting_payment': return const Color(0xFFFEF3C7);
      case 'processing': return const Color(0xFFDBEAFE);
      case 'shipped': return const Color(0xFFEDE9FE);
      case 'delivered': return const Color(0xFFDCFCE7);
      case 'cancelled': return const Color(0xFFFEE2E2);
      default: return AppTheme.surface2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Pesanan Toko'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.surface2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabCtrl,
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.textSecondary,
              indicator: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              tabs: _tabs.map((t) => Tab(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(t),
                ),
              )).toList(),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _orders.isEmpty
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.inventory_2_outlined, size: 64, color: AppTheme.textHint),
                    const SizedBox(height: 16),
                    const Text('Belum ada pesanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                    const SizedBox(height: 8),
                    const Text('Pesanan dari konsumen akan muncul di sini', style: TextStyle(fontSize: 13, color: AppTheme.textHint)),
                  ]),
                )
              : RefreshIndicator(
                  onRefresh: () => _load(_statuses[_tabCtrl.index]),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    itemBuilder: (_, i) {
                      final o = _orders[i];
                      final status = o['status']?.toString() ?? '';
                      final canShip = status == 'processing';
                      final canProcess = status == 'awaiting_payment';
                      final isPending = status == 'pending';
                      final isShipped = status == 'shipped';
                      final isDelivered = status == 'delivered';
                      final isCancelled = status == 'cancelled';
                      final buyerName = o['user']?['name'] ?? 'Pembeli';
                      final paymentMethod = o['payment_method'] ?? '-';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.cardBorder),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(children: [
                          // ── Header: Order Number + Status Badge ──
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppTheme.surface2,
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                            ),
                            child: Row(children: [
                              Expanded(
                                child: Text('#${o['order_number']}',
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _statusBgColor(status),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(_statusLabel(status),
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _statusColor(status))),
                              ),
                            ]),
                          ),

                          // ── Buyer Info ───────────────────────────
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                            child: Row(
                              children: [
                                const Icon(Icons.person_outline, size: 14, color: AppTheme.textHint),
                                const SizedBox(width: 6),
                                Text(buyerName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                                const Spacer(),
                                const Icon(Icons.payment_outlined, size: 14, color: AppTheme.textHint),
                                const SizedBox(width: 4),
                                Text(paymentMethod, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),

                          // ── Items ────────────────────────────────
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                            child: Column(children: [
                              ...((o['items'] as List?) ?? []).map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(children: [
                                  Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(
                                      color: AppTheme.surface2,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.shopping_bag_outlined, size: 18, color: AppTheme.textHint),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(
                                    item['product']?['name'] ?? 'Produk',
                                    maxLines: 2, overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  )),
                                  Text('x${item['quantity']}', style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
                                ]),
                              )),
                            ]),
                          ),

                          // ── Divider ──────────────────────────────
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),

                          // ── Total & Actions ──────────────────────
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                            child: Column(children: [
                              Row(children: [
                                const Text('Total', style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
                                const Spacer(),
                                Text(currency.format(o['total'] ?? 0),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                              ]),
                              const SizedBox(height: 10),

                              // ── Action Buttons by Status ─────────
                              if (isPending)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.info_outline, size: 16, color: Color(0xFF92400E)),
                                      SizedBox(width: 8),
                                      Text(
                                        'Menunggu Pembayaran Konsumen',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
                                      ),
                                    ],
                                  ),
                                ),

                              if (canProcess)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _updatingId == o['id'] ? null : () => _updateStatus(o['id'], 'processing'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      elevation: 0,
                                    ),
                                    child: _updatingId == o['id']
                                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                        : const Text('Proses Pesanan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                  ),
                                ),

                              if (canShip)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _updatingId == o['id'] ? null : () => _showShippingModal(o['id']),
                                    icon: _updatingId == o['id']
                                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                        : const Icon(Icons.local_shipping_outlined, size: 18),
                                    label: const Text('Kirim Pesanan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      elevation: 0,
                                    ),
                                  ),
                                ),

                              if (isShipped)
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.track_changes_outlined, size: 18),
                                    label: const Text('Lacak Pengiriman', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.accentDark,
                                      side: const BorderSide(color: Color(0xFFEDE9FE)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),

                              if (isDelivered || isCancelled)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: isDelivered ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isDelivered ? Icons.check_circle_outline : Icons.cancel_outlined,
                                        size: 16,
                                        color: isDelivered ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isDelivered ? 'Pesanan Selesai' : 'Pesanan Dibatalkan',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isDelivered ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ]),
                          ),
                        ]),
                      );
                    },
                  ),
                ),
    );
  }
}