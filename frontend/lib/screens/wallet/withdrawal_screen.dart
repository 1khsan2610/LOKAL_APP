import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/custom_button.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final _api = ApiService();
  final _amountCtrl = TextEditingController();

  bool _isLoading = true;
  bool _isSubmitting = false;
  String _bankStatus = 'not_configured'; // 'not_configured', 'pending', 'approved', 'rejected'
  String? _bankName;
  String? _accountNumber;
  String? _accountHolder;
  String? _rejectionReason;
  int _cashBalance = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _api.getWallet(),
        _api.getBankAccount(),
      ]);

      final walletData = results[0].data['data'];
      _cashBalance = walletData['cash_balance'] ?? 0;

      final bankData = results[1].data['data'];
      if (bankData != null) {
        _bankStatus = bankData['status'] ?? 'not_configured';
        _bankName = bankData['bank_name'];
        _accountNumber = bankData['account_number'];
        _accountHolder = bankData['account_holder'];
        _rejectionReason = bankData['rejection_reason'];
      } else {
        _bankStatus = 'not_configured';
      }
    } catch (_) {
      _bankStatus = 'not_configured';
    }
    if (mounted) setState(() => _isLoading = false);
  }

  bool get _canWithdraw => _bankStatus == 'approved' && _cashBalance > 0;

  String? get _statusMessage {
    switch (_bankStatus) {
      case 'not_configured':
        return 'Anda belum mengatur rekening bank. Silakan atur rekening bank terlebih dahulu.';
      case 'pending':
        return 'Rekening bank Anda sedang diverifikasi oleh Admin.';
      case 'rejected':
        return _rejectionReason != null
            ? 'Rekening bank Anda ditolak. Alasan: $_rejectionReason. Silakan perbaiki data rekening bank Anda.'
            : 'Rekening bank Anda ditolak. Silakan perbaiki data rekening bank Anda.';
      case 'approved':
        return _cashBalance <= 0 ? 'Saldo Anda belum mencukupi untuk penarikan.' : null;
      default:
        return 'Silakan atur rekening bank terlebih dahulu.';
    }
  }

  Future<void> _submitWithdrawal() async {
    if (!_canWithdraw) return;

    final amount = int.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      AppSnackBar.show(context, 'Masukkan jumlah penarikan yang valid', isError: true);
      return;
    }
    if (amount > _cashBalance) {
      AppSnackBar.show(context, 'Jumlah penarikan melebihi saldo', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final resp = await _api.dio.post('/wallet/withdraw', data: {'amount': amount});
      if (!mounted) return;
      AppSnackBar.show(context, resp.data['message'] ?? '✓ Permintaan penarikan berhasil dikirim');
      _loadData();
      _amountCtrl.clear();
    } catch (e) {
      if (!mounted) return;
      final msg = (e as dynamic).response?.data?['message'] ?? 'Gagal mengirim permintaan penarikan.';
      AppSnackBar.show(context, msg, isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String formatCurrency(int v) => NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(v);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Tarik Saldo'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Balance card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF065F46), AppTheme.primary],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('💰 Saldo Tersedia', style: TextStyle(fontSize: 13, color: Colors.white70)),
                      const SizedBox(height: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          formatCurrency(_cashBalance),
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  // Bank account status
                  AppCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Rekening Tujuan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),

                      if (_bankStatus == 'not_configured') ...[
                        const Icon(Icons.warning_amber_rounded, color: AppTheme.warning, size: 20),
                        const SizedBox(height: 6),
                        Text(_statusMessage!, style: const TextStyle(fontSize: 12, color: AppTheme.textHint)),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => context.push('/umkm/bank-account'),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Atur Rekening Bank'),
                          ),
                        ),
                      ] else ...[
                        _BankStatusBanner(
                          status: _bankStatus,
                          bankName: _bankName,
                          accountNumber: _accountNumber,
                          accountHolder: _accountHolder,
                          rejectionReason: _rejectionReason,
                        ),
                      ],
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // Status message (if any)
                  if (_statusMessage != null && _bankStatus != 'not_configured') ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _bankStatus == 'rejected'
                            ? const Color(0xFFFEE2E2)
                            : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(children: [
                        Icon(
                          _bankStatus == 'rejected' ? Icons.cancel : Icons.access_time,
                          color: _bankStatus == 'rejected' ? AppTheme.danger : AppTheme.warning,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_statusMessage!,
                              style: TextStyle(fontSize: 12, color: _bankStatus == 'rejected' ? AppTheme.danger : Colors.black87)),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Withdrawal form (only if bank approved)
                  if (_canWithdraw) ...[
                    AppCard(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Jumlah Penarikan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _amountCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            prefixText: 'Rp ',
                            hintText: '0',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('Maksimal penarikan: ${formatCurrency(_cashBalance)}',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
                        const SizedBox(height: 20),
                        CustomButton(
                          label: '💰 Ajukan Penarikan',
                          isLoading: _isSubmitting,
                          onPressed: _submitWithdrawal,
                        ),
                      ]),
                    ),
                  ],

                  const SizedBox(height: 24),
                ]),
              ),
      ),
    );
  }
}

class _BankStatusBanner extends StatelessWidget {
  final String status;
  final String? bankName;
  final String? accountNumber;
  final String? accountHolder;
  final String? rejectionReason;

  const _BankStatusBanner({
    required this.status,
    this.bankName,
    this.accountNumber,
    this.accountHolder,
    this.rejectionReason,
  });

  @override
  Widget build(BuildContext context) {
    final isApproved = status == 'approved';
    final isPending = status == 'pending';
    final isRejected = status == 'rejected';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isApproved
            ? const Color(0xFFDCFCE7)
            : isPending
                ? const Color(0xFFFEF3C7)
                : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        Icon(
          isApproved ? Icons.check_circle : isPending ? Icons.access_time : Icons.cancel,
          color: isApproved ? AppTheme.success : isPending ? AppTheme.warning : AppTheme.danger,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              isApproved ? '✅ Rekening Terverifikasi' : isPending ? '⏳ Menunggu Verifikasi' : '❌ Rekening Ditolak',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            if (bankName != null)
              Text('$bankName - $accountNumber ($accountHolder)',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
            if (isRejected && rejectionReason != null)
              Text('Alasan: $rejectionReason',
                  style: const TextStyle(fontSize: 11, color: AppTheme.danger)),
          ]),
        ),
      ]),
    );
  }
}

/// Helper snackbar
class AppSnackBar {
  static void show(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white, fontSize: 13)),
      backgroundColor: isError ? AppTheme.danger : AppTheme.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ));
  }
}