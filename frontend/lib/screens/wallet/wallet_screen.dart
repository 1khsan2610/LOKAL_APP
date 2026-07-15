import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/cart_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/product_card.dart';
import '../../widgets/app_card.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>()
        ..load()
        ..loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Dompet & Lokal Coin'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () async { await wallet.load(); await wallet.loadTransactions(); },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Coin balance card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF065F46), AppTheme.primary, AppTheme.primaryLight],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('🪙 Lokal Coin Kamu',
                  style: TextStyle(fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 6),
                // FittedBox: saldo coin besar (mis. "1.250.000") tetap satu
                // baris rapi, tidak lagi berisiko wrap/overflow di HP sempit.
                Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(wallet.coinBalance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.'),
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 4),
                Text('≈ ${currency.format(wallet.rupiahValue)} diskon',
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.white60)),
                const SizedBox(height: 16),
                // Expanded pada tiap aksi: 3 tombol berbagi lebar rata dan
                // teks di dalamnya menyusut proporsional (bukan overflow)
                // ketika layar sempit.
                Row(children: [
                  Expanded(child: _WalletAction(icon: '🛍️', label: 'Gunakan', onTap: () => context.push('/checkout'))),
                  const SizedBox(width: 8),
                  Expanded(child: _WalletAction(icon: '📜', label: 'Riwayat', onTap: () => context.push('/wallet/coin-history'))),
                  const SizedBox(width: 8),
                  Expanded(child: _WalletAction(icon: 'ℹ️', label: 'Info Coin', onTap: () => _showCoinInfo(context))),
                ]),
              ]),
            ),
            const SizedBox(height: 20),

            // How to earn
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('💡 Cara Mendapatkan Coin',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                ...[
                  ('🛒', 'Setiap pembelian', '1 Coin per Rp 1.000'),
                  ('⭐', 'Beri ulasan produk', '+50 Coin'),
                  ('👥', 'Ajak teman bergabung', '+200 Coin'),
                  ('🎂', 'Ulang tahun kamu', '+100 Coin'),
                ].map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Row(children: [
                    Text(item.$1, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item.$2, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
                    const SizedBox(width: 8),
                    Text(item.$3, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                  ]),
                )),
              ]),
            ),
            const SizedBox(height: 20),

            // Transaction history
            const Text('📋 Riwayat Transaksi Coin',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),

            if (wallet.isLoading)
              const Center(child: CircularProgressIndicator(color: AppTheme.primary))
            else if (wallet.transactions.isEmpty)
              const EmptyState(emoji: '🪙', title: 'Belum Ada Transaksi Coin', subtitle: 'Mulai berbelanja untuk mendapatkan Lokal Coin!')
            else
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: wallet.transactions.asMap().entries.map((e) {
                    final i   = e.key;
                    final txn = e.value;
                    return Column(children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(children: [
                          Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(
                              color: txn.isCredit ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(child: Text(txn.isCredit ? '📦' : '🛍️', style: const TextStyle(fontSize: 18))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(txn.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            Text(txn.createdAt, style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
                          ])),
                          const SizedBox(width: 8),
                          // Flexible+FittedBox: jumlah coin & saldo tetap satu
                          // baris meski nilainya besar, menyusut proporsional
                          // alih-alih overflow di layar sempit.
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                Text(
                                  '${txn.isCredit ? '+' : '-'}${txn.amount} Coin',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                                    color: txn.isCredit ? AppTheme.success : AppTheme.danger),
                                ),
                                Text('${txn.balanceAfter} total',
                                  style: const TextStyle(fontSize: 10, color: AppTheme.textHint)),
                              ]),
                            ),
                          ),
                        ]),
                      ),
                      if (i < wallet.transactions.length - 1) const Divider(height: 1),
                    ]);
                  }).toList(),
                ),
              ),
            const SizedBox(height: 24),
          ]),
        ),
        ),
      ),
    );
  }

  void _showCoinInfo(BuildContext context) => showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('ℹ️ Tentang Lokal Coin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        const Text('1 Lokal Coin = Rp 10 diskon\nMaksimum diskon 20% dari subtotal\nCoin berlaku selama 90 hari\nCoin tidak dapat ditarik tunai',
          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.7)),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity,
          child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Mengerti'))),
      ]),
    ),
  );
}

class _WalletAction extends StatelessWidget {
  final String icon, label;
  final VoidCallback onTap;
  const _WalletAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Text('$icon $label', textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
    ),
  );
}
