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
  String? _currentStatus; // 'pending', 'approved', 'rejected', null
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
    setState(() {
      _isLoading = true;
      _error = null;
    });
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
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Status banner
                  if (_currentStatus != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
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
                              const Text('Rekening Anda sedang diverifikasi oleh Admin.',
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
                    const SizedBox(height: 20),
                  ],

                  if (_error != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(_error!, style: const TextStyle(fontSize: 13, color: AppTheme.danger)),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Form
                  AppCard(
                    child: Form(
                      key: _formKey,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Data Rekening Bank', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        const Text('Isi data rekening bank Anda untuk penarikan saldo. Data akan diverifikasi oleh Admin.',
                            style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
                        const SizedBox(height: 18),

                        // Nama Bank
                        TextFormField(
                          controller: _bankNameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Nama Bank',
                            hintText: 'Contoh: Bank Mandiri, BCA, BRI',
                            prefixIcon: Icon(Icons.account_balance_outlined),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama bank harus diisi' : null,
                        ),
                        const SizedBox(height: 14),

                        // Nomor Rekening
                        TextFormField(
                          controller: _accountNumberCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Nomor Rekening',
                            hintText: 'Contoh: 1234567890',
                            prefixIcon: Icon(Icons.pin_outlined),
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Nomor rekening harus diisi' : null,
                        ),
                        const SizedBox(height: 14),

                        // Nama Pemilik
                        TextFormField(
                          controller: _accountHolderCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Nama Pemilik Rekening',
                            hintText: 'Sesuai dengan nama di rekening bank',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          textInputAction: TextInputAction.done,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama pemilik harus diisi' : null,
                        ),
                        const SizedBox(height: 24),

                        // Save button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _save,
                            child: _isSaving
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('💾 Simpan Rekening Bank'),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ]),
              ),
      ),
    );
  }
}

/// Helper snackbar — inline to avoid import conflicts
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