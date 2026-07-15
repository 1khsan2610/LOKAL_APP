import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/product_card.dart';
import '../../models/product_model.dart';

class CoinHistoryScreen extends StatefulWidget {
  const CoinHistoryScreen({super.key});

  @override
  State<CoinHistoryScreen> createState() => _CoinHistoryScreenState();
}

class _CoinHistoryScreenState extends State<CoinHistoryScreen> {
  final _api = ApiService();

  List<CoinTransactionModel> _transactions = [];
  bool _isLoading = true;
  int _coinBalance = 0;
  int _page = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
      _transactions = [];
    }
    if (!_hasMore) return;

    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _api.getWallet(),
        _api.getCoinTransactions(page: _page),
      ]);
      final walletData = results[0].data['data'];
      final txnData = results[1].data['data'];

      setState(() {
        _coinBalance = walletData['coin_balance'] ?? 0;
        final newTxns = (txnData['data'] as List)
            .map((e) => CoinTransactionModel.fromJson(e))
            .toList();
        _transactions.addAll(newTxns);
        _hasMore = txnData['current_page'] < txnData['last_page'];
        _page++;
      });
    } catch (_) {} finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Riwayat Koin'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: () => _load(refresh: true),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Coin balance header
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF065F46), AppTheme.primary, AppTheme.primaryLight],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('🪙 Saldo Lokal Coin',
                        style: TextStyle(fontSize: 13, color: Colors.white70)),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _coinBalance.toStringAsFixed(0).replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.'),
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('≈ ${currency.format(_coinBalance * 10)} diskon',
                        style: const TextStyle(fontSize: 12, color: Colors.white60)),
                  ]),
                ),
              ),

              // Legend
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(children: [
                    _LegendChip(color: AppTheme.success, label: 'Masuk (Cashback / Refund)'),
                    const SizedBox(width: 10),
                    _LegendChip(color: AppTheme.danger, label: 'Keluar (Digunakan)'),
                  ]),
                ),
              ),
              const SizedBox(height: 8),

              // Transaction list
              if (_transactions.isEmpty && !_isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    emoji: '🪙',
                    title: 'Belum Ada Riwayat Koin',
                    subtitle: 'Transaksi koin akan muncul di sini',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        if (i >= _transactions.length) {
                          // Load more trigger
                          if (_hasMore) WidgetsBinding.instance.addPostFrameCallback((_) => _load());
                          return const SizedBox.shrink();
                        }

                        final txn = _transactions[i];
                        final isCredit = txn.isCredit;
                        final dateStr = txn.createdAt.length >= 16
                            ? txn.createdAt.substring(0, 16)
                            : txn.createdAt;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: AppCard(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Row(children: [
                              // Icon
                              Container(
                                width: 42, height: 42,
                                decoration: BoxDecoration(
                                  color: isCredit ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(isCredit ? '📥' : '📤', style: const TextStyle(fontSize: 20)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(txn.description, maxLines: 1, overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 2),
                                    Text(dateStr,
                                        style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Amount
                              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                Text(
                                  '${isCredit ? '+' : '-'}${txn.amount} 🪙',
                                  style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w800,
                                    color: isCredit ? AppTheme.success : AppTheme.danger,
                                  ),
                                ),
                                Text('Saldo: ${txn.balanceAfter}',
                                    style: const TextStyle(fontSize: 10, color: AppTheme.textHint)),
                              ]),
                            ]),
                          ),
                        );
                      },
                      childCount: _transactions.length + (_hasMore ? 1 : 0),
                    ),
                  ),
                ),

              // Loading indicator at bottom
              if (_isLoading && _transactions.isNotEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendChip({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 10, height: 10,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
      ),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
    ]);
  }
}