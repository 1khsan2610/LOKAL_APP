import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/product_card.dart';

/// Halaman Kelola Pesanan UMKM dengan filter tab dan action buttons
class UmkmOrderListScreen extends StatefulWidget {
  const UmkmOrderListScreen({super.key});

  @override
  State<UmkmOrderListScreen> createState() => _UmkmOrderListScreenState();
}

class _UmkmOrderListScreenState extends State<UmkmOrderListScreen> {
  final _api = ApiService();
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String? _selectedStatus;
  int _totalOrders = 0;
  final Set<int> _loadingIds = {};

  final _tabs = ['Semua', 'Pending', 'Diproses', 'Dikirim', 'Selesai', 'Batal'];
  final _statuses = [null, 'pending', 'processing', 'shipped', 'delivered', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders({String? status}) async {
    setState(() {
      _isLoading = true;
      _selectedStatus = status;
    });
    try {
      final resp = await _api.getUmkmOrders(status: status);
      final data = resp.data['data'];
      final ordersList = (data['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      setState(() {
        _orders = ordersList;
        _totalOrders = data['total'] ?? ordersList.length;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _orders = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _acceptOrder(int id) async {
    setState(() => _loadingIds.add(id));
    try {
      await _api.dio.patch('/umkm/orders/$id/status', data: {'status': 'processing'});
      if (mounted) {
        AppSnackBar.show(context, '✅ Pesanan diterima');
        _loadOrders(status: _selectedStatus);
      }
    } catch (e) {
      if (mounted) _showError(e);
    } finally {
      if (mounted) setState(() => _loadingIds.remove(id));
    }
  }

  Future<void> _rejectOrder(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak Pesanan'),
        content: const Text('Yakin ingin menolak pesanan ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), style: TextButton.styleFrom(foregroundColor: AppTheme.danger), child: const Text('Tolak')),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _loadingIds.add(id));
    try {
      await _api.dio.patch('/umkm/orders/$id/status', data: {'status': 'cancelled'});
      if (mounted) {
        AppSnackBar.show(context, '✅ Pesanan ditolak');
        _loadOrders(status: _selectedStatus);
      }
    } catch (e) {
      if (mounted) _showError(e);
    } finally {
      if (mounted) setState(() => _loadingIds.remove(id));
    }
  }

  Future<void> _shipOrder(int id) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Input Resi Pengiriman'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Masukkan nomor resi untuk pesanan ini', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Nomor Resi',
                hintText: 'JNE001234567',
                prefixIcon: Icon(Icons.local_shipping_outlined),
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
    if (result == null || result.isEmpty) return;
    setState(() => _loadingIds.add(id));
    try {
      await _api.dio.patch('/umkm/orders/$id/status', data: {
        'status': 'shipped',
        'tracking_number': result,
      });
      if (mounted) {
        AppSnackBar.show(context, '✅ Pesanan dikirim dengan resi: $result');
        _loadOrders(status: _selectedStatus);
      }
    } catch (e) {
      if (mounted) _showError(e);
    } finally {
      if (mounted) setState(() => _loadingIds.remove(id));
    }
  }

  void _showError(dynamic e) {
    String msg = 'Gagal mengubah status';
    try {
      final resp = (e as dynamic).response;
      if (resp?.data?['message'] != null) msg = resp.data['message'];
    } catch (_) {}
    AppSnackBar.show(context, msg, isError: true);
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ───────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(
            children: [
              const Text('Pesanan UMKM', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$_totalOrders', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primary)),
              ),
            ],
          ),
        ),

        // ── Tab Filter ───────────────────────────────────────────
        SizedBox(
          height: 44,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _tabs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final isActive = _selectedStatus == _statuses[i];
              return GestureDetector(
                onTap: () => _loadOrders(status: _statuses[i]),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive ? AppTheme.primary : AppTheme.cardBorder,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _tabs[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.white : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // ── Order List ───────────────────────────────────────────
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
              : _orders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 64, color: AppTheme.textHint),
                          const SizedBox(height: 16),
                          const Text('Belum Ada Pesanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                          const SizedBox(height: 8),
                          const Text('Pesanan dari pembeli akan muncul di sini', style: TextStyle(fontSize: 13, color: AppTheme.textHint)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _loadOrders(status: _selectedStatus),
                      color: AppTheme.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: _orders.length,
                        itemBuilder: (_, i) => _buildOrderCard(_orders[i], currency),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, NumberFormat currency) {
    final id = order['id'] as int? ?? 0;
    final orderNumber = order['order_number']?.toString() ?? '';
    final status = order['status']?.toString() ?? '';
    final buyerName = order['user']?['name'] ?? order['buyer_name'] ?? 'Pembeli';
    final courier = order['shipping_method']?.toString() ?? order['courier']?.toString() ?? '-';
    final paymentMethod = order['payment_method']?.toString() ?? '-';
    final total = _parseNum(order['total']);
    final isLoading = _loadingIds.contains(id);
    final dateStr = order['created_at']?.toString().substring(0, 10) ?? '-';
    final items = (order['items'] as List?) ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Order ID + Badge ───────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.surface2,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '#${orderNumber.length > 8 ? orderNumber.substring(0, 8) : orderNumber}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                _buildStatusBadge(status),
              ],
            ),
          ),

          // ── Body ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Buyer & Courier
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 13, color: AppTheme.textHint),
                    const SizedBox(width: 4),
                    Text(buyerName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    if (courier != '-') ...[
                      const SizedBox(width: 12),
                      const Icon(Icons.local_shipping_outlined, size: 13, color: AppTheme.textHint),
                      const SizedBox(width: 4),
                      Text(courier, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.payment_outlined, size: 13, color: AppTheme.textHint),
                    const SizedBox(width: 4),
                    Text(paymentMethod, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    const Spacer(),
                    Text(dateStr, style: const TextStyle(fontSize: 10, color: AppTheme.textHint)),
                  ],
                ),

                // Items summary
                if (items.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...items.take(2).map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.surface2,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.shopping_bag_outlined, size: 16, color: AppTheme.textHint),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item['product']?['name'] ?? item['name'] ?? 'Produk',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text('x${item['quantity'] ?? 1}',
                          style: const TextStyle(fontSize: 10, color: AppTheme.textHint)),
                      ],
                    ),
                  )),
                  if (items.length > 2)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text('+${items.length - 2} item lainnya',
                        style: const TextStyle(fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.w600)),
                    ),
                ],

                const Divider(height: 16),

                // ── Total & Actions ──────────────────────────────
                Row(
                  children: [
                    const Text('Total Tagihan', style: TextStyle(fontSize: 11, color: AppTheme.textHint)),
                    const Spacer(),
                    Text(currency.format(total),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                  ],
                ),
                const SizedBox(height: 10),

                // ── Action Buttons by Status ──────────────────────
                if (status == 'pending' || status == 'awaiting_payment')
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: OutlinedButton(
                            onPressed: isLoading ? null : () => _rejectOrder(id),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.danger,
                              side: BorderSide(color: AppTheme.danger.withValues(alpha: 0.3)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 0),
                            ),
                            child: isLoading
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('Tolak', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : () => _acceptOrder(id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Terima', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ],
                  ),

                if (status == 'processing')
                  SizedBox(
                    width: double.infinity,
                    child: SizedBox(
                      height: 36,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : () => _shipOrder(id),
                        icon: isLoading
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.local_shipping_outlined, size: 16),
                        label: const Text('Kirim / Input Resi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),

                if (status == 'shipped')
                  SizedBox(
                    width: double.infinity,
                    child: SizedBox(
                      height: 36,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final trackingNumber = order['tracking_number']?.toString();
                          if (trackingNumber != null && trackingNumber.isNotEmpty) {
                            context.push('/order/tracking?resi=$trackingNumber');
                          }
                        },
                        icon: const Icon(Icons.track_changes_outlined, size: 16),
                        label: const Text('Lacak Pengiriman', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.accentDark,
                          side: BorderSide(color: AppTheme.accentDark.withValues(alpha: 0.3)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 0),
                        ),
                      ),
                    ),
                  ),

                if (status == 'delivered')
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF15803D)),
                        SizedBox(width: 6),
                        Text('Pesanan Selesai', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF15803D))),
                      ],
                    ),
                  ),

                if (status == 'cancelled')
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cancel_outlined, size: 16, color: Color(0xFFB91C1C)),
                        SizedBox(width: 6),
                        Text('Pesanan Dibatalkan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFB91C1C))),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final config = {
      'pending': {'label': 'Pesanan Baru', 'bg': const Color(0xFFFEF3C7), 'fg': const Color(0xFF92400E)},
      'awaiting_payment': {'label': 'Menunggu Bayar', 'bg': const Color(0xFFFEF3C7), 'fg': const Color(0xFF92400E)},
      'processing': {'label': 'Dikemas', 'bg': const Color(0xFFDBEAFE), 'fg': const Color(0xFF1E40AF)},
      'shipped': {'label': 'Dikirim', 'bg': const Color(0xFFEDE9FE), 'fg': const Color(0xFF6D28D9)},
      'delivered': {'label': 'Selesai', 'bg': const Color(0xFFDCFCE7), 'fg': const Color(0xFF15803D)},
      'cancelled': {'label': 'Dibatalkan', 'bg': const Color(0xFFFEE2E2), 'fg': const Color(0xFFB91C1C)},
    };
    final c = config[status] ?? {'label': status, 'bg': AppTheme.surface2, 'fg': AppTheme.textSecondary};

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c['bg'] as Color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        c['label'] as String,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c['fg'] as Color),
      ),
    );
  }

  num _parseNum(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value.replaceAll(',', '')) ?? 0;
    return 0;
  }
}