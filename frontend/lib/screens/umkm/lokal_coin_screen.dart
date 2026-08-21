import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';

class LokalCoinScreen extends StatefulWidget {
  const LokalCoinScreen({super.key});

  @override
  State<LokalCoinScreen> createState() => _LokalCoinScreenState();
}

class _LokalCoinScreenState extends State<LokalCoinScreen> {
  final _api = ApiService();
  bool _isLoading = true;
  double _coinBalance = 42550;
  List<Map<String, dynamic>> _transactions = [];

  final _rewardTasks = [
    {'icon': '📦', 'task': 'Selesaikan 5 Order', 'reward': '+500', 'progress': '3/5'},
    {'icon': '⭐', 'task': 'Rating Bintang 5', 'reward': '+200', 'progress': '1/5'},
    {'icon': '🔗', 'task': 'Bagikan Toko', 'reward': '+50', 'progress': '0/3'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final walletResp = await _api.getWallet();
      final wallet = walletResp.data['data'];
      _coinBalance = (wallet['coin_balance'] ?? 42550).toDouble();

      final txResp = await _api.getCoinTransactions();
      _transactions = ((txResp.data['data']['data'] as List?) ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 768;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Main Banner ──
              Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Icon(Icons.monetization_on, color: Color(0xFFFFD54F), size: 26),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Saldo Lokal Coin',
                              style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500)),
                            SizedBox(height: 2),
                            Text('Dapatkan lebih banyak koin dengan bertransaksi',
                              style: TextStyle(fontSize: 10, color: Colors.white38)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${_coinBalance.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} Koin',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.trending_up, size: 14, color: Colors.greenAccent),
                              SizedBox(width: 4),
                              Text('+12.5%',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.greenAccent)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton.icon(
                              onPressed: () => context.push('/wallet/withdrawal'),
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
                              onPressed: () {},
                              icon: const Text('🪙', style: TextStyle(fontSize: 16)),
                              label: const Text('Tukar Koin', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
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
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Main Content Row ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        // Tier Progress Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppTheme.cardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3E8FF),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.emoji_events_outlined, color: Color(0xFF8E24AA), size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Silver Merchant',
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                                        Text('Level & Progress Tier',
                                          style: TextStyle(fontSize: 11, color: AppTheme.textHint)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3E8FF),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text('Silver',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF8E24AA))),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: 0.745,
                                  backgroundColor: const Color(0xFFF3E8FF),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8E24AA)),
                                  minHeight: 10,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text('7.450 / 10.000 Koin ke Gold Tier',
                                style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _benefitChip('Prioritas', Icons.star, const Color(0xFFFFD54F)),
                                  const SizedBox(width: 8),
                                  _benefitChip('Fee 0%', Icons.money_off, const Color(0xFF22C55E)),
                                  const SizedBox(width: 8),
                                  _benefitChip('Support 24/7', Icons.headset_mic, AppTheme.primary),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Transaction History
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppTheme.cardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Riwayat Transaksi Coin',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                              const SizedBox(height: 4),
                              const Text('Catatan pemasukan dan pengeluaran koin',
                                style: TextStyle(fontSize: 11, color: AppTheme.textHint)),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: AppTheme.surface2,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    Expanded(flex: 3, child: Text('Keterangan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary))),
                                    Expanded(flex: 2, child: Text('Tanggal', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary))),
                                    Expanded(flex: 1, child: Text('Tipe', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary))),
                                    Expanded(flex: 1, child: Text('Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary))),
                                    Expanded(flex: 1, child: Text('Jumlah', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary))),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_transactions.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Icon(Icons.receipt_long_outlined, size: 48, color: AppTheme.textHint),
                                        SizedBox(height: 8),
                                        Text('Belum ada transaksi', style: TextStyle(fontSize: 13, color: AppTheme.textHint)),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                ...(_transactions.take(10).map((tx) {
                                  final desc = tx['description'] ?? '-';
                                  final date = tx['created_at']?.toString().substring(0, 10) ?? '-';
                                  final type = tx['type'] ?? 'credit';
                                  final status = tx['status'] ?? 'completed';
                                  final amount = _parseNum(tx['amount']);
                                  final isCredit = type == 'credit';

                                  return Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                    decoration: const BoxDecoration(
                                      border: Border(bottom: BorderSide(color: AppTheme.cardBorder)),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(flex: 3, child: Text(desc,
                                          style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
                                          maxLines: 1, overflow: TextOverflow.ellipsis)),
                                        Expanded(flex: 2, child: Text(date,
                                          style: const TextStyle(fontSize: 11, color: AppTheme.textHint))),
                                        Expanded(flex: 1, child: _typeBadge(type)),
                                        Expanded(flex: 1, child: _statusBadge(status)),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            '${isCredit ? '+' : '-'}${amount.toInt()}',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: isCredit ? AppTheme.success : AppTheme.danger,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                })),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Right Sidebar (Desktop) ──
                  if (isWide) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppTheme.cardBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 36, height: 36,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.rocket_launch_outlined, color: Color(0xFFD97706), size: 20),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text('Dapatkan Lebih Banyak',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ..._rewardTasks.map((task) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      Text(task['icon'] as String, style: const TextStyle(fontSize: 20)),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(task['task'] as String,
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                                            const SizedBox(height: 4),
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: LinearProgressIndicator(
                                                value: _parseProgress(task['progress'] as String),
                                                backgroundColor: const Color(0xFFF1F5F9),
                                                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                                                minHeight: 6,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(task['progress'] as String,
                                              style: const TextStyle(fontSize: 10, color: AppTheme.textHint)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDCFCE7),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text('${task['reward']}',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF15803D))),
                                      ),
                                    ],
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _benefitChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _typeBadge(String type) {
    final isCredit = type == 'credit';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isCredit ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isCredit ? 'Masuk' : 'Keluar',
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
          color: isCredit ? const Color(0xFF15803D) : const Color(0xFFB91C1C)),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final isCompleted = status == 'completed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isCompleted ? 'Berhasil' : 'Pending',
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
          color: isCompleted ? const Color(0xFF15803D) : const Color(0xFF92400E)),
      ),
    );
  }

  double _parseProgress(String progress) {
    final parts = progress.split('/');
    if (parts.length == 2) {
      final current = double.tryParse(parts[0]) ?? 0;
      final total = double.tryParse(parts[1]) ?? 1;
      return current / total;
    }
    return 0;
  }
}