// ═══════════════════════════════════════════════════════════════════
//  AddressFormScreen  —  lib/screens/profile/address_form_screen.dart
//  Prinsip desain: bg #F8FAFC, SafeArea (gesture nav), form fields
//  dibungkus Expanded pada Row supaya tidak overflow di layar sempit.
//  Menambahkan checkbox "Jadikan Alamat Utama" sesuai permintaan.
// ═══════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../models/product_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/product_card.dart';

class AddressFormScreen extends StatefulWidget {
  final AddressModel? address;
  const AddressFormScreen({super.key, this.address});
  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey  = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _detail;
  late final TextEditingController _city;
  late final TextEditingController _zip;
  late String _province;
  bool _isPrimary = false;
  bool _isSaving  = false;
  final _api      = ApiService();

  bool get _isEdit => widget.address != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.address?.recipientName ?? '');
    _phone = TextEditingController(text: widget.address?.phone ?? '');
    _detail = TextEditingController(text: widget.address?.detail ?? '');
    _city = TextEditingController(text: widget.address?.city ?? '');
    _zip = TextEditingController(text: widget.address?.zip ?? '');
    _province = widget.address?.province ?? 'Jawa Barat';
    _isPrimary = widget.address?.isDefault ?? false;
  }

  final _provinces = ['Jawa Barat', 'Jawa Tengah', 'Jawa Timur', 'DKI Jakarta', 'Banten', 'DI Yogyakarta', 'Sumatera Utara', 'Lainnya'];

  @override
  void dispose() { _name.dispose(); _phone.dispose(); _detail.dispose(); _city.dispose(); _zip.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final data = {
      'recipient_name': _name.text.trim(),
      'phone': _phone.text.trim(),
      'detail': _detail.text.trim(),
      'city': _city.text.trim(),
      'zip': _zip.text.trim(),
      'province': _province,
      'is_default': _isPrimary,
    };
    try {
      if (_isEdit) {
        await _api.updateAddress(widget.address!.id, data);
      } else {
        await _api.createAddress(data);
      }
      if (!mounted) return;

      AppSnackBar.show(context, _isEdit ? '✓ Alamat berhasil diperbarui!' : '✓ Alamat berhasil disimpan!');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.pop();
      });
    } catch (_) {
      AppSnackBar.show(context, 'Gagal menyimpan alamat', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.bg,
    appBar: AppBar(
      title: Text(_isEdit ? 'Edit Alamat' : 'Tambah Alamat Baru'),
      leading: BackButton(onPressed: () => context.pop()),
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Form(
          key: _formKey,
          child: Column(children: [
            // ── Nama Penerima ────────────────────────────────────
            CustomTextField(
              controller: _name,
              label: 'Nama Penerima',
              hint: 'Nama lengkap',
              prefixIcon: Icons.person_outlined,
              validator: (v) => (v?.isEmpty ?? true) ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 14),

            // ── No. HP ───────────────────────────────────────────
            CustomTextField(
              controller: _phone,
              label: 'No. HP',
              hint: '08xxxxxxxxx',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) => (v?.isEmpty ?? true) ? 'No. HP wajib diisi' : null,
            ),
            const SizedBox(height: 14),

            // ── Alamat Lengkap ───────────────────────────────────
            CustomTextField(
              controller: _detail,
              label: 'Alamat Lengkap',
              hint: 'Jl. Merdeka No. 17, RT 02/05...',
              prefixIcon: Icons.location_on_outlined,
              maxLines: 3,
              validator: (v) => (v?.isEmpty ?? true) ? 'Alamat wajib diisi' : null,
            ),
            const SizedBox(height: 14),

            // ── Kota & Kode Pos (2 kolom) ────────────────────────
            Row(children: [
              Expanded(
                child: CustomTextField(
                  controller: _city,
                  label: 'Kota/Kab.',
                  hint: 'Bandung',
                  prefixIcon: Icons.location_city_outlined,
                  validator: (v) => (v?.isEmpty ?? true) ? 'Kota wajib diisi' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  controller: _zip,
                  label: 'Kode Pos',
                  hint: '40234',
                  prefixIcon: Icons.markunread_mailbox_outlined,
                  keyboardType: TextInputType.number,
                ),
              ),
            ]),
            const SizedBox(height: 14),

            // ── Provinsi ─────────────────────────────────────────
            DropdownButtonFormField<String>(
              initialValue: _province,
              decoration: const InputDecoration(
                labelText: 'Provinsi',
                prefixIcon: Icon(Icons.map_outlined, color: AppTheme.primary, size: 20),
              ),
              isExpanded: true,
              items: _provinces
                  .map((p) => DropdownMenuItem(
                        value: p,
                        child: Text(p, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _province = v!),
            ),
            const SizedBox(height: 14),

            // ── Jadikan Alamat Utama ─────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              decoration: BoxDecoration(
                color: _isPrimary ? AppTheme.surface2 : AppTheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _isPrimary ? AppTheme.primary : AppTheme.border,
                  width: _isPrimary ? 1.5 : 1,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => setState(() => _isPrimary = !_isPrimary),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    children: [
                      Icon(
                        _isPrimary ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: _isPrimary ? AppTheme.primary : AppTheme.textHint,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Jadikan Alamat Utama',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                        ),
                      ),
                      if (_isPrimary)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Utama',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Simpan ───────────────────────────────────────────
            CustomButton(
              label: _isEdit ? '✓ Perbarui Alamat' : '✓ Simpan Alamat',
              isLoading: _isSaving,
              onPressed: _save,
            ),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    ),
  );
}
