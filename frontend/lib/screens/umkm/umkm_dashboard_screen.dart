import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/image_helper.dart';
import '../../widgets/app_card.dart';
import 'umkm_layout.dart';

class UmkmDashboardScreen extends StatefulWidget {
  const UmkmDashboardScreen({super.key});

  @override
  State<UmkmDashboardScreen> createState() => _UmkmDashboardScreenState();
}

class _UmkmDashboardScreenState extends State<UmkmDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _analytics;
  Map<String, dynamic>? _weekly;
  Map<String, dynamic>? _wallet;
  List<Map<String, dynamic>> _recentOrders = [];
  List<Map<String, dynamic>> _activeProducts = [];
  String? _bankStatus;

  final _api = ApiService();

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _api.getUmkmAnalytics(),
        _api.dio.get('/umkm/analytics/weekly'),
        _api.getWallet(),
        _api.getUmkmOrders(),
        _api.getMyProducts(),
      ]);

      final walletData = results[2].data['data'];
      final productsData = (results[4].data['data']['data'] as List?) ?? [];

      setState(() {
        _analytics = results[0].data['data'];
        _weekly = results[1].data['data'];
        _wallet = walletData;
        _recentOrders = ((results[3].data['data']['data'] as List?) ?? []).take(5).toList().cast<Map<String, dynamic>>();
        _activeProducts = productsData.take(8).map((e) => e as Map<String, dynamic>).toList();
        _bankStatus = walletData['bank_account']?['status'];
        _isLoading = false;
      });

      // Update provider with balances
      if (mounted) {
        context.read<UmkmProvider>().updateBalances(
          cash: (walletData['cash_balance'] ?? 0).toDouble(),
          coin: (walletData['coin_balance'] ?? 0).toDouble(),
        );

        // Count pending orders for badge
        final pendingOrders = await _api.getUmkmOrders(status: 'pending');
        final pendingList = (pendingOrders.data['data']['data'] as List?) ?? [];
        if (mounted) {
          context.read<UmkmProvider>().updateBadges(newOrders: pendingList.length);
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  num _parseNum(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value.replaceAll(',', '')) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final totalSales = _analytics?['total_sales'] != null ? currency.format(_parseNum(_analytics!['total_sales'])) : 'Rp 0';
    final orderCount = _analytics?['order_count']?.toString() ?? '0';
    final totalProducts = _analytics?['total_products']?.toString() ?? '0';
    final revenueTrend = _weekly?['revenue_trend'] ?? 'up';
    final revenueChange = _weekly?['revenue_change'] ?? 0;
    final cashBalance = _parseNum(_wallet?['cash_balance'] ?? 0);
    final coinBalance = _parseNum(_wallet?['coin_balance'] ?? 0);

    return RefreshIndicator(
      onRefresh: _loadDashboard,
      color: AppTheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ═══════════════════════════════════════════════════════════
          //  BANK VERIFICATION WARNING
          // ═══════════════════════════════════════════════════════════
          if (_bankStatus != 'approved' && _bankStatus != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFEE2E2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.warning_amber_rounded, color: AppTheme.danger, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rekening Bank Belum Diverifikasi',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF991B1B)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Verifikasi rekening untuk menikmati fitur penuh',
                          style: TextStyle(fontSize: 11, color: Colors.red.shade700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => context.push('/umkm/bank-account'),
                    style: TextButton.styleFrom(
                      backgroundColor: AppTheme.danger,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Verifikasi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),

          // ═══════════════════════════════════════════════════════════
          //  HERO CARD — Saldo & Coin
          // ═══════════════════════════════════════════════════════════
          _buildHeroCard(currency, cashBalance, coinBalance, revenueTrend, revenueChange, _bankStatus),

          const SizedBox(height: 20),

          // ═══════════════════════════════════════════════════════════
          //  WEEKLY PERFORMANCE
          // ═══════════════════════════════════════════════════════════
          _buildWeeklyCard(currency, revenueTrend, revenueChange),

          const SizedBox(height: 20),

          // ═══════════════════════════════════════════════════════════
          //  STATS ROW
          // ═══════════════════════════════════════════════════════════
          Row(children: [
            _statCard(Icons.payments_outlined, totalSales, 'Pendapatan', const Color(0xFF15803D), const Color(0xFFE6F4EA)),
            const SizedBox(width: 10),
            _statCard(Icons.receipt_long_outlined, orderCount, 'Pesanan', const Color(0xFF1E40AF), const Color(0xFFDBEAFE)),
            const SizedBox(width: 10),
            _statCard(Icons.inventory_2_outlined, totalProducts, 'Produk', const Color(0xFFB45309), const Color(0xFFFFF8E1)),
          ]),
          const SizedBox(height: 24),

          // ═══════════════════════════════════════════════════════════
          //  QUICK MENU GRID
          // ═══════════════════════════════════════════════════════════
          const Text('Menu Cepat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
          const SizedBox(height: 14),
          Row(children: [
            _quickMenu(Icons.add_circle_outline, 'Tambah Produk', const Color(0xFFEBF3FE), const Color(0xFF1966D2), () => context.push('/umkm/products/form')),
            const SizedBox(width: 10),
            _quickMenu(Icons.receipt_long_outlined, 'Pesanan', const Color(0xFFFFF0ED), const Color(0xFFE53935), () => context.push('/umkm/orders')),
            const SizedBox(width: 10),
            _quickMenu(Icons.analytics_outlined, 'Analitik', const Color(0xFFF3E8FF), const Color(0xFF8E24AA), () => context.push('/umkm/analytics')),
            const SizedBox(width: 10),
            _quickMenu(Icons.settings_outlined, 'Pengaturan', const Color(0xFFE6F4EA), const Color(0xFF2E7D32), () => context.push('/umkm/store-settings')),
          ]),
          const SizedBox(height: 24),

          // ═══════════════════════════════════════════════════════════
          //  ACTIVE PRODUCTS
          // ═══════════════════════════════════════════════════════════
          Row(
            children: [
              const Text('Produk Aktif', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const Spacer(),
              TextButton(
                onPressed: () => context.push('/umkm/products'),
                child: const Text('Lihat Semua →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ..._activeProducts.map((p) => _buildProductCard(p, currency)),
                // Add product card
                GestureDetector(
                  onTap: () => context.push('/umkm/products/form'),
                  child: Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEBF3FE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.add_circle_outline, color: AppTheme.primary, size: 24),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '+ Produk Baru',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ═══════════════════════════════════════════════════════════
          //  RECENT ORDERS
          // ═══════════════════════════════════════════════════════════
          Row(
            children: [
              const Text('Pesanan Terbaru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const Spacer(),
              TextButton(
                onPressed: () => context.push('/umkm/orders'),
                child: const Text('Lihat Semua →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...(_recentOrders.isEmpty
              ? [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 48, color: AppTheme.textHint),
                        SizedBox(height: 12),
                        Text('Belum Ada Pesanan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                        SizedBox(height: 4),
                        Text('Pesanan terbaru akan muncul di sini', style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
                      ],
                    ),
                  ),
                ]
              : _recentOrders.map((o) {
                  final dateStr = o['created_at']?.toString().substring(0, 10) ?? '-';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.surface2,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '#${o['order_number']?.toString().substring(0, 4) ?? ''}',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.primary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('#${o['order_number']}', maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                            const SizedBox(height: 2),
                            Text(dateStr, style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
                          ]),
                        ),
                        Text(currency.format(_parseNum(o['total'])),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                        const SizedBox(width: 10),
                        _statusBadge(o['status']?.toString() ?? ''),
                      ]),
                    ),
                  );
                })),

          // ═══════════════════════════════════════════════════════════
          //  LINK TO FULL REPORT
          // ═══════════════════════════════════════════════════════════
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/umkm/analytics'),
              icon: const Icon(Icons.bar_chart_rounded, size: 18),
              label: const Text('Lihat Laporan Lengkap', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 24),
        ]),
      ),
    );
  }

  Widget _buildHeroCard(NumberFormat currency, num cashBalance, num coinBalance, String revenueTrend, num revenueChange, String? bankStatus) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A2540), Color(0xFF1966D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A2540).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Top row: label + level
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Saldo Tunai', style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500)),
                    Text('Tersedia', style: TextStyle(fontSize: 10, color: Colors.white38)),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, size: 12, color: Color(0xFFFFD54F)),
                  const SizedBox(width: 4),
                  const Text('Silver Merchant', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFFFD54F))),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Saldo amount
        Text(
          currency.format(cashBalance),
          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
        ),
        const SizedBox(height: 12),
        // Growth + Coin
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(revenueTrend == 'up' ? Icons.trending_up : Icons.trending_down, size: 14, color: Colors.greenAccent),
                  const SizedBox(width: 4),
                  Text('${revenueChange >= 0 ? '+' : ''}$revenueChange%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.greenAccent)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.monetization_on, size: 14, color: Colors.white60),
            const SizedBox(width: 4),
            Text('🪙 ${coinBalance.toInt()} Lokal Coin', style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        const SizedBox(height: 16),
        // Progress bar
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (coinBalance % 1000) / 1000,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD54F)),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text('${(coinBalance % 1000).toInt()}/1000', style: const TextStyle(fontSize: 11, color: Colors.white60, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 20),
        // Action buttons
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: bankStatus == 'approved' ? () => context.push('/wallet/withdraw') : () => context.push('/umkm/bank-account'),
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Tarik Dana', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0A2540),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/umkm/lokal-coin'),
                  icon: const Icon(Icons.history_rounded, size: 18),
                  label: const Text('Riwayat', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _buildWeeklyCard(NumberFormat currency, String revenueTrend, num revenueChange) {
    final weeklyRevenue = _parseNum(_weekly?['current_week']?['revenue']);
    final prevRevenue = _parseNum(_weekly?['previous_week']?['revenue']);
    final weeklyOrders = _weekly?['current_week']?['orders']?.toString() ?? '0';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEBF3FE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.trending_up_rounded, size: 20, color: AppTheme.primary),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Performa Minggu Ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: revenueTrend == 'up' ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(
                  revenueTrend == 'up' ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  size: 14,
                  color: revenueTrend == 'up' ? AppTheme.success : AppTheme.danger,
                ),
                const SizedBox(width: 4),
                Text(
                  '${revenueChange >= 0 ? '+' : ''}$revenueChange%',
                  style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: revenueTrend == 'up' ? AppTheme.success : AppTheme.danger,
                  ),
                ),
              ]),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(currency.format(weeklyRevenue),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Text('vs ${currency.format(prevRevenue)} minggu lalu',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textHint)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.surface2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(children: [
                Text(weeklyOrders,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                const Text('Pesanan', style: TextStyle(fontSize: 10, color: AppTheme.textHint, fontWeight: FontWeight.w500)),
              ]),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, NumberFormat currency) {
    final name = product['name'] ?? 'Produk';
    final price = _parseNum(product['price']);
    final stock = _parseNum(product['stock']).toInt();
    final imageUrl = (product['images'] as List?)?.isNotEmpty == true
        ? resolveImageUrl(product['images'][0]['url']?.toString())
        : null;
    final soldCount = _parseNum(product['sold_count'] ?? product['terjual'] ?? 0).toInt();

    return GestureDetector(
      onTap: () => context.push('/umkm/products/form?id=${product['id']}'),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Container(
                height: 90,
                color: AppTheme.surface2,
                child: imageUrl != null
                    ? Image.network(imageUrl, width: double.infinity, height: 90, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, size: 32, color: AppTheme.textHint))
                    : const Icon(Icons.image_outlined, size: 32, color: AppTheme.textHint),
              ),
            ),
            // Badges
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
              child: Row(
                children: [
                  if (soldCount > 10)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('Terlaris', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xFF92400E))),
                    ),
                  const Spacer(),
                  if (stock <= 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('Habis', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xFFB91C1C))),
                    ),
                  ] else if (stock <= 5) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('Restok', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xFFB45309))),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            ),
            // Price
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 2, 8, 6),
              child: Text(currency.format(price),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primary)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickMenu(IconData icon, String label, Color bgColor, Color iconColor, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.cardBorder),
          ),
          child: Column(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 22, color: iconColor),
            ),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
          ]),
        ),
      ),
    );
  }

  Widget _statCard(IconData icon, String value, String label, Color color, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Column(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 8),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textHint, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final colors = {
      'pending': const Color(0xFFFEF3C7),
      'awaiting_payment': const Color(0xFFFEF3C7),
      'processing': const Color(0xFFDBEAFE),
      'shipped': const Color(0xFFEDE9FE),
      'delivered': const Color(0xFFDCFCE7),
      'cancelled': const Color(0xFFFEE2E2),
    };
    final textColors = {
      'pending': const Color(0xFF92400E),
      'awaiting_payment': const Color(0xFF92400E),
      'processing': const Color(0xFF1E40AF),
      'shipped': const Color(0xFF6D28D9),
      'delivered': const Color(0xFF15803D),
      'cancelled': const Color(0xFFB91C1C),
    };
    final labels = {
      'pending': 'Pending',
      'awaiting_payment': 'Menunggu Bayar',
      'processing': 'Diproses',
      'shipped': 'Dikirim',
      'delivered': 'Selesai',
      'cancelled': 'Dibatalkan',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors[status] ?? AppTheme.surface2,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        labels[status] ?? status,
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: textColors[status] ?? AppTheme.textSecondary),
      ),
    );
  }
}