import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/product_card.dart';
import 'package:intl/intl.dart';

class AdminOrdersListScreen extends StatefulWidget {
  const AdminOrdersListScreen({super.key});
  @override
  State<AdminOrdersListScreen> createState() => _AdminOrdersListScreenState();
}

class _AdminOrdersListScreenState extends State<AdminOrdersListScreen> {
  final _api = ApiService();
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = false;
  String? _filterStatus;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final resp = await _api.dio.get('/admin/orders', queryParameters: {
        if (_filterStatus != null) 'status': _filterStatus,
      });
      if (mounted) {
        setState(() {
          _orders = (resp.data['data']['data'] as List).cast<Map<String, dynamic>>();
        });
      }
    } catch (_) {
      if (mounted) AppSnackBar.show(context, 'Gagal memuat data pesanan', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'shipped':
        return 'Dikirim';
      case 'delivered':
        return 'Diterima';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFFEE2E2);
      case 'confirmed':
      case 'shipped':
        return const Color(0xFFEDE9FE);
      case 'delivered':
        return const Color(0xFFDCFCE7);
      case 'cancelled':
        return const Color(0xFFF3F4F6);
      default:
        return AppTheme.surface;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFB91C1C);
      case 'confirmed':
      case 'shipped':
        return const Color(0xFF6D28D9);
      case 'delivered':
        return const Color(0xFF15803D);
      case 'cancelled':
        return const Color(0xFF6B7280);
      default:
        return AppTheme.textPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pesanan'),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatusFilter(null, 'Semua'),
                  _buildStatusFilter('pending', 'Menunggu'),
                  _buildStatusFilter('confirmed', 'Dikonfirmasi'),
                  _buildStatusFilter('shipped', 'Dikirim'),
                  _buildStatusFilter('delivered', 'Diterima'),
                  _buildStatusFilter('cancelled', 'Dibatalkan'),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : _orders.isEmpty
                    ? const Center(child: Text('Tidak ada pesanan'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _orders.length,
                        itemBuilder: (_, i) {
                          final order = _orders[i];
                          final status = order['status'] as String;
                          final total = order['total'] as int? ?? 0;
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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '#${order['id']}',
                                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          order['user']?['name'] ?? 'Pengguna',
                                          style: const TextStyle(fontSize: 12, color: AppTheme.textHint),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(status),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        _getStatusLabel(status),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: _getStatusTextColor(status),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Total: ${currency.format(total)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primary,
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

  Widget _buildStatusFilter(String? value, String label) {
    final isSelected = _filterStatus == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() => _filterStatus = value);
          _loadOrders();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : AppTheme.surface,
            border: Border.all(
              color: isSelected ? AppTheme.primary : AppTheme.border,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
