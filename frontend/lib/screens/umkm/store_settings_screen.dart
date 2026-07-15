import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../models/product_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/product_card.dart';

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
                child: Form(
                  key: _formKey,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _description, label: 'Deskripsi Toko', hint: 'Ceritakan tentang tokomu...',
                      prefixIcon: Icons.description_outlined, maxLines: 4,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(label: '✓ Simpan Perubahan', isLoading: _isSaving, onPressed: _save),
                    const SizedBox(height: 20),
                    // Bank account link
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
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ),
  );
}
