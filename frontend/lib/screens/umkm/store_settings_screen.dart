import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../models/product_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/product_card.dart';
import 'umkm_layout.dart';

class StoreSettingsScreen extends StatefulWidget {
  const StoreSettingsScreen({super.key});
  @override
  State<StoreSettingsScreen> createState() => _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends State<StoreSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _province = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  UmkmModel? _store;
  String? _joinDate;

  @override
  void initState() {
    super.initState();
    _loadStore();
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _phone.dispose();
    _address.dispose();
    _city.dispose();
    _province.dispose();
    super.dispose();
  }

  Future<void> _loadStore() async {
    setState(() => _isLoading = true);
    try {
      final resp = await _api.getMyStore();
      final store = UmkmModel.fromJson(resp.data['data']);
      setState(() {
        _store = store;
        _name.text = store.name;
        _description.text = store.description ?? '';
        _phone.text = store.phone ?? '';
        _address.text = store.address ?? '';
        _city.text = store.city ?? '';
        _province.text = store.province ?? '';
        _joinDate = resp.data['data']['created_at']?.toString().substring(0, 10);
      });
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(context, 'Gagal memuat data toko', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await _api.updateMyStore({
        'name': _name.text.trim(),
        'description': _description.text.trim(),
        if (_phone.text.trim().isNotEmpty) 'phone': _phone.text.trim(),
        if (_address.text.trim().isNotEmpty) 'address': _address.text.trim(),
        'city': _city.text.trim(),
        'province': _province.text.trim(),
      });
      if (!mounted) return;
      // Update provider
      context.read<UmkmProvider>().updateStoreInfo(name: _name.text.trim());
      AppSnackBar.show(context, '✓ Profil toko berhasil diperbarui');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      String msg = 'Gagal menyimpan perubahan';
      try { final resp = (e as dynamic).response; if (resp?.data?['message'] != null) msg = resp.data['message']; } catch (_) {}
      AppSnackBar.show(context, msg, isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.bg,
    appBar: AppBar(
      title: const Text('Pengaturan Toko'),
      leading: const BackButton(),
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
        : _store == null
            ? const EmptyState(emoji: '🏪', title: 'Toko Tidak Ditemukan', subtitle: 'Tidak dapat memuat data toko kamu')
            : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // ═══════════════════════════════════════════════════
                  //  PROFILE BANNER
                  // ═══════════════════════════════════════════════════
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0A2540), Color(0xFF1966D2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              child: Text(
                                _store!.name.isNotEmpty ? _store!.name[0].toUpperCase() : 'T',
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _store!.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Silver Merchant', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFFFD54F))),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ID Merchant: ${_store!.id}',
                          style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7)),
                        ),
                        if (_joinDate != null)
                          Text(
                            'Bergabung: $_joinDate',
                            style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7)),
                          ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: const Text('Lihat Profil Publik', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ═══════════════════════════════════════════════════
                  //  FORM INFORMASI TOKO
                  // ═══════════════════════════════════════════════════
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.store_outlined, size: 18, color: AppTheme.primary),
                              SizedBox(width: 8),
                              Text('Informasi Toko', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _name, label: 'Nama Toko', hint: 'Toko Sederhana',
                            prefixIcon: Icons.store_outlined,
                            validator: (v) => (v?.isEmpty ?? true) ? 'Nama toko wajib diisi' : null,
                          ),
                          const SizedBox(height: 14),
                          CustomTextField(controller: _phone, label: 'Nomor Telepon Toko', hint: '0812xxxxxxx',
                            prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone),
                          const SizedBox(height: 14),
                          CustomTextField(controller: _address, label: 'Alamat Toko', hint: 'Jl. Contoh No. 1',
                            prefixIcon: Icons.location_on_outlined, maxLines: 2),
                          const SizedBox(height: 14),
                          Row(children: [
                            Expanded(child: CustomTextField(controller: _city, label: 'Kota', hint: 'Bandung', prefixIcon: Icons.location_city_outlined)),
                            const SizedBox(width: 12),
                            Expanded(child: CustomTextField(controller: _province, label: 'Provinsi', hint: 'Jawa Barat', prefixIcon: Icons.map_outlined)),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ═══════════════════════════════════════════════════
                  //  DESKRIPSI TOKO
                  // ═══════════════════════════════════════════════════
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.description_outlined, size: 18, color: AppTheme.primary),
                            SizedBox(width: 8),
                            Text('Deskripsi Toko', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _description,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Ceritakan tentang tokomu...',
                            hintStyle: const TextStyle(color: AppTheme.textHint, fontSize: 14),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(bottom: 64),
                              child: Icon(Icons.description_outlined, size: 20, color: AppTheme.primary),
                            ),
                            filled: true,
                            fillColor: AppTheme.bg,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppTheme.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppTheme.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_description.text.length}/500 karakter',
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontSize: 11, color: AppTheme.textHint),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ═══════════════════════════════════════════════════
                  //  SAVE BUTTON
                  // ═══════════════════════════════════════════════════
                  CustomButton(label: '✓ Simpan Perubahan', isLoading: _isSaving, onPressed: _save),
                  const SizedBox(height: 16),

                  // ═══════════════════════════════════════════════════
                  //  BANK ACCOUNT LINK
                  // ═══════════════════════════════════════════════════
                  const Divider(),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/umkm/bank-account'),
                      icon: const Icon(Icons.account_balance_outlined),
                      label: const Text('🏦 Atur Rekening Bank'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
  );
}