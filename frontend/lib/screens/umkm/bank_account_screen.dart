import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_card.dart';

class BankAccountScreen extends StatefulWidget {
  const BankAccountScreen({super.key});

  @override
  State<BankAccountScreen> createState() => _BankAccountScreenState();
}

class _BankAccountScreenState extends State<BankAccountScreen> {
  final _api = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _bankNameCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  final _accountHolderCtrl = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _currentStatus;
  String? _rejectionReason;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBankAccount();
  }

  @override
  void dispose() {
    _bankNameCtrl.dispose();
    _accountNumberCtrl.dispose();
    _accountHolderCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadBankAccount() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final resp = await _api.getBankAccount();
      final data = resp.data['data'];
      if (data != null) {
        _bankNameCtrl.text = data['bank_name'] ?? '';
        _accountNumberCtrl.text = data['account_number'] ?? '';
        _accountHolderCtrl.text = data['account_holder'] ?? '';
        _currentStatus = data['status'];
        _rejectionReason = data['rejection_reason'];
      }
    } catch (e) {
      _error = 'Gagal memuat data rekening bank.';
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final resp = await _api.saveBankAccount({
        'bank_name': _bankNameCtrl.text.trim(),
        'account_number': _accountNumberCtrl.text.trim(),
        'account_holder': _accountHolderCtrl.text.trim(),
      });
      if (!mounted) return;
      setState(() => _currentStatus = 'pending');
      AppSnackBar.show(context, resp.data['message'] ?? '✓ Rekening bank berhasil disimpan');
    } catch (e) {
      if (!mounted) return;
      final msg = (e as dynamic).response?.data?['message'] ?? 'Gagal menyimpan rekening bank.';
      AppSnackBar.show(context, msg, isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Rekening Bank'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 768;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status banner
                        if (_currentStatus != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: _currentStatus == 'approved'
                                  ? const Color(0xFFDCFCE7)
                                  : _currentStatus == 'rejected'
                                      ? const Color(0xFFFEE2E2)
                                      : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(children: [
                              Icon(
                                _currentStatus == 'approved'
                                    ? Icons.check_circle
                                    : _currentStatus == 'rejected'
                                        ? Icons.cancel
                                        : Icons.access_time,
                                color: _currentStatus == 'approved'
                                    ? AppTheme.success
                                    : _currentStatus == 'rejected'
                                        ? AppTheme.danger
                                        : AppTheme.warning,
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(
                                    _currentStatus == 'approved'
                                        ? '✅ Disetujui'
                                        : _currentStatus == 'rejected'
                                            ? '❌ Ditolak'
                                            : '⏳ Menunggu Verifikasi',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                                  ),
                                  if (_currentStatus == 'pending')
                                    const Text('Rekening Anda sedang diverifikasi oleh Admin. (1x24 jam)',
                                        style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
                                  if (_currentStatus == 'rejected' && _rejectionReason != null)
                                    Text('Alasan: $_rejectionReason',
                                        style: const TextStyle(fontSize: 12, color: AppTheme.danger)),
                                  if (_currentStatus == 'approved')
                                    const Text('Rekening Anda sudah aktif untuk penarikan.',
                                        style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
                                ]),
                              ),
                            ]),
                          ),

                        if (_error != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(_error!, style: const TextStyle(fontSize: 13, color: AppTheme.danger)),
                          ),

                        // ── 2-Column Layout ──
                        isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 3, child: _buildFormColumn()),
                                  const SizedBox(width: 20),
                                  Expanded(flex: 2, child: _buildInfoColumn()),
                                ],
                              )
                            : Column(
                                children: [
                                  _buildFormColumn(),
                                  const SizedBox(height: 20),
                                  _buildInfoColumn(),
                                ],
                              ),
                      ],
                    );
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildFormColumn() {
    return AppCard(
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(
            children: [
              Icon(Icons.account_balance_outlined, size: 20, color: AppTheme.primary),
              SizedBox(width: 8),
              Text('Data Rekening Bank', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 6),
          const Text('Isi data rekening bank Anda untuk penarikan saldo. Data akan diverifikasi oleh Admin dalam 1x24 jam.',
              style: TextStyle(fontSize: 12, color: AppTheme.textHint, height: 1.4)),
          const SizedBox(height: 20),

          // Pilih Bank
          TextFormField(
            controller: _bankNameCtrl,
            decoration: const InputDecoration(
              labelText: 'Pilih Bank',
              hintText: 'Contoh: Bank Mandiri, BCA, BRI',
              prefixIcon: Icon(Icons.account_balance_outlined),
            ),
            textInputAction: TextInputAction.next,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Bank harus dipilih' : null,
          ),
          const SizedBox(height: 16),

          // Nomor Rekening
          TextFormField(
            controller: _accountNumberCtrl,
            decoration: const InputDecoration(
              labelText: 'Nomor Rekening',
              hintText: 'Masukkan nomor rekening',
              prefixIcon: Icon(Icons.pin_outlined),
            ),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Nomor rekening harus diisi' : null,
          ),
          const SizedBox(height: 16),

          // Nama Pemilik
          TextFormField(
            controller: _accountHolderCtrl,
            decoration: const InputDecoration(
              labelText: 'Nama Pemilik Rekening',
              hintText: 'Sesuai dengan nama di buku tabungan',
              prefixIcon: Icon(Icons.person_outline),
            ),
            textInputAction: TextInputAction.done,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama pemilik harus diisi' : null,
          ),
          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save_outlined, size: 20),
              label: Text(_isSaving ? 'Menyimpan...' : '💾 Simpan Rekening Bank'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildInfoColumn() {
    return Column(
      children: [
        // Keamanan Terjamin
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.cardBorder),
          ),
          child: Column(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.shield, color: Color(0xFF15803D), size: 28),
              ),
              const SizedBox(height: 12),
              const Text('Keamanan Terjamin',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              const SizedBox(height: 6),
              const Text('Data rekening Anda dienkripsi dan hanya digunakan untuk verifikasi penarikan dana.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppTheme.textHint, height: 1.4)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Alur Verifikasi
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
              const Row(
                children: [
                  Icon(Icons.route_outlined, size: 18, color: AppTheme.primary),
                  SizedBox(width: 8),
                  Text('Alur Verifikasi',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                ],
              ),
              const SizedBox(height: 16),
              _stepItem(1, 'Unggah data rekening bank', 'Lengkapi form di samping dengan data yang valid'),
              const SizedBox(height: 12),
              _stepItem(2, 'Admin validasi data', 'Tim kami akan memverifikasi data dalam 1x24 jam'),
              const SizedBox(height: 12),
              _stepItem(3, 'Status terverifikasi', 'Rekening aktif dan siap digunakan untuk penarikan'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Ilustrasi Bank Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0A2540), Color(0xFF1966D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Container(
                width: 64, height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.credit_card, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 12),
              const Text('Pembayaran & Penarikan Aman',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 4),
              const Text('Terhubung dengan berbagai bank nasional',
                style: TextStyle(fontSize: 11, color: Colors.white70)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepItem(int step, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text('$step',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 2),
              Text(desc,
                style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
            ],
          ),
        ),
      ],
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