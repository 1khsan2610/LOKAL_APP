import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/wallet.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/common/custom_widgets.dart' as custom_widgets;

class CoinHistoryScreen extends ConsumerStatefulWidget {
  const CoinHistoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CoinHistoryScreen> createState() => _CoinHistoryScreenState();
}

class _CoinHistoryScreenState extends ConsumerState<CoinHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<CoinTransaction> _filterTransactions(
    List<CoinTransaction> transactions,
    int tabIndex,
  ) {
    switch (tabIndex) {
      case 0:
        // All
        return transactions;
      case 1:
        // Earned (positive amount)
        return transactions.where((t) => t.amount > 0).toList();
      case 2:
        // Used (negative amount)
        return transactions.where((t) => t.amount < 0).toList();
      case 3:
        // Expired
        return transactions.where((t) => t.isExpired).toList();
      default:
        return transactions;
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(walletTransactionsProvider(1));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Lokal Coin'),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Diperoleh'),
            Tab(text: 'Digunakan'),
            Tab(text: 'Kadaluwarsa'),
          ],
        ),
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildTransactionList(context, transactions, 0),
              _buildTransactionList(context, transactions, 1),
              _buildTransactionList(context, transactions, 2),
              _buildTransactionList(context, transactions, 3),
            ],
          );
        },
        loading: () => const custom_widgets.LoadingWidget(),
        error: (error, st) =>
            custom_widgets.ErrorWidget(message: error.toString()),
      ),
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    List<CoinTransaction> transactions,
    int tabIndex,
  ) {
    final filtered = _filterTransactions(transactions, tabIndex);

    if (filtered.isEmpty) {
      return _buildEmptyState(tabIndex);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final transaction = filtered[index];
        return _TransactionCard(transaction: transaction);
      },
    );
  }

  Widget _buildEmptyState(int tabIndex) {
    final messages = {
      0: 'Belum ada transaksi',
      1: 'Belum ada koin yang diperoleh',
      2: 'Belum ada koin yang digunakan',
      3: 'Tidak ada koin yang kadaluwarsa',
    };

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '📋',
            style: TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          Text(
            messages[tabIndex] ?? 'Belum ada data',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai belanja untuk mendapatkan Lokal Coin',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

// Transaction Card Component
class _TransactionCard extends StatelessWidget {
  final CoinTransaction transaction;

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.amount > 0;
    final isExpiring = transaction.isExpiring;
    final isExpired = transaction.isExpired;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Icon Container
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _getIconBackgroundColor(transaction.type, isIncome),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    transaction.typeIcon,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Transaction Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.typeLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(transaction.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isIncome ? '+' : '-'} ${transaction.amount.abs().toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isIncome ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (isExpired)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Kadaluwarsa',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    )
                  else if (isExpiring)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Segera habis',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (transaction.description != null &&
              transaction.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  transaction.description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          // Expiry info
          if (transaction.expiresAt.isAfter(DateTime.now()))
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Berlaku hingga: ${_formatDate(transaction.expiresAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getIconBackgroundColor(CoinTransactionType type, bool isIncome) {
    switch (type) {
      case CoinTransactionType.reward:
        return Colors.blue.withOpacity(0.15);
      case CoinTransactionType.usage:
        return Colors.red.withOpacity(0.15);
      case CoinTransactionType.review:
        return Colors.amber.withOpacity(0.15);
      case CoinTransactionType.bonus:
        return Colors.purple.withOpacity(0.15);
      case CoinTransactionType.expiry:
        return Colors.red.withOpacity(0.15);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Baru saja';
      }
      return '${difference.inHours}j lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}h lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
