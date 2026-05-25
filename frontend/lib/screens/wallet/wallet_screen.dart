import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/common/custom_widgets.dart' as custom_widgets;

class WalletScreen extends ConsumerWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletProvider);
    final transactionsAsync = ref.watch(walletTransactionsProvider(1));

    return Scaffold(
      appBar: custom_widgets.CustomAppBar(title: AppStrings.navWallet),
      body: walletAsync.when(
        data: (wallet) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Coin Balance Card
                Container(
                  margin: const EdgeInsets.all(AppNumbers.paddingMedium),
                  padding: const EdgeInsets.all(AppNumbers.paddingLarge),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryDark,
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(AppNumbers.borderRadius),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saldo Lokal Coin',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${wallet.coinBalance.toStringAsFixed(0)} koin',
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '💰',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Expiring coins warning
                if (wallet.coinExpiring30Days > 0)
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppNumbers.paddingMedium,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(AppNumbers.paddingSmall),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withOpacity(0.1),
                      border: Border.all(color: AppTheme.warningColor),
                      borderRadius:
                          BorderRadius.circular(AppNumbers.smallBorderRadius),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_rounded,
                          color: AppTheme.warningColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${wallet.coinExpiring30Days.toStringAsFixed(0)} koin akan hangus dalam 30 hari',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Info cards
                Padding(
                  padding: const EdgeInsets.all(AppNumbers.paddingMedium),
                  child: Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: '📊',
                          title: 'Keuntungan',
                          subtitle: 'Per Transaksi',
                          value: '2%',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoCard(
                          icon: '🎁',
                          title: 'Max Diskon',
                          subtitle: 'Per Transaksi',
                          value: '20%',
                        ),
                      ),
                    ],
                  ),
                ),

                // Recent Transactions
                Padding(
                  padding: const EdgeInsets.all(AppNumbers.paddingMedium),
                  child: Text(
                    'Riwayat Transaksi',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),

                transactionsAsync.when(
                  data: (transactions) {
                    if (transactions.isEmpty) {
                      return custom_widgets.EmptyStateWidget(
                        icon: '📝',
                        title: 'Belum ada transaksi',
                        message: 'Mulai belanja untuk mendapatkan Lokal Coin',
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return ListTile(
                          leading: Text(
                            transaction.typeIcon,
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(transaction.typeLabel),
                          subtitle: Text(
                            transaction.description ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            '${transaction.amount > 0 ? '+' : ''} ${transaction.amount.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                              color: transaction.amount > 0
                                  ? AppTheme.successColor
                                  : AppTheme.errorColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const custom_widgets.LoadingWidget(),
                  error: (e, st) => custom_widgets.ErrorWidget(message: e.toString()),
                ),
              ],
            ),
          );
        },
        loading: () => const custom_widgets.LoadingWidget(message: 'Memuat dompet...'),
        error: (error, st) => custom_widgets.ErrorWidget(message: error.toString()),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppNumbers.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
