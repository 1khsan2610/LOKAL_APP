import 'package:flutter/material.dart';
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
  late final _name     = TextEditingController(text: widget.address?.recipientName ?? '');
  late final _phone    = TextEditingController(text: widget.address?.phone ?? '');
  late final _detail   = TextEditingController(text: widget.address?.detail ?? '');
  late final _city     = TextEditingController(text: widget.address?.city ?? '');
  late final _zip      = TextEditingController(text: widget.address?.zip ?? '');
  late String _province = widget.address?.province ?? 'Jawa Barat';
  bool _isSaving  = false;
  final _api      = ApiService();

  bool get _isEdit => widget.address != null;

  final _provinces = ['Jawa Barat', 'Jawa Tengah', 'Jawa Timur', 'DKI Jakarta', 'Banten', 'DI Yogyakarta', 'Sumatera Utara', 'Lainnya'];

  @override
  void dispose() { _name.dispose(); _phone.dispose(); _detail.dispose(); _city.dispose(); _zip.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final data = {
      'recipient_name': _name.text.trim(), 'phone': _phone.text.trim(),
      'detail': _detail.text.trim(), 'city': _city.text.trim(),
      'zip': _zip.text.trim(), 'province': _province,
    };
    try {
      if (_isEdit) {
        await _api.updateAddress(widget.address!.id, data);
      } else {
        await _api.createAddress(data);
      }
      if (!mounted) return;
      
      AppSnackBar.show(context, _isEdit ? '✓ Alamat berhasil diperbarui!' : '✓ Alamat berhasil disimpan!');
      
      // PERBAIKAN DI SINI: Dibungkus post frame agar navigasi pop tidak mengunci (lock) engine Flutter
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    } catch (_) {
      AppSnackBar.show(context, 'Gagal menyimpan alamat', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(_isEdit ? 'Edit Alamat' : 'Tambah Alamat Baru'),
      leading: BackButton(onPressed: () => Navigator.pop(context)),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(children: [
          CustomTextField(controller: _name, label: 'Nama Penerima', hint: 'Nama lengkap', prefixIcon: Icons.person_outlined,
            validator: (v) => (v?.isEmpty ?? true) ? 'Nama wajib diisi' : null),
          const SizedBox(height: 14),
          CustomTextField(controller: _phone, label: 'No. HP', hint: '08xxxxxxxxx', prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone,
            validator: (v) => (v?.isEmpty ?? true) ? 'No. HP wajib diisi' : null),
          const SizedBox(height: 14),
          CustomTextField(controller: _detail, label: 'Alamat Lengkap', hint: 'Jl. Merdeka No. 17, RT 02/05...', prefixIcon: Icons.location_on_outlined, maxLines: 3,
            validator: (v) => (v?.isEmpty ?? true) ? 'Alamat wajib diisi' : null),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: CustomTextField(controller: _city, label: 'Kota/Kab.', hint: 'Bandung', prefixIcon: Icons.location_city_outlined,
              validator: (v) => (v?.isEmpty ?? true) ? 'Kota wajib diisi' : null)),
            const SizedBox(width: 12),
            Expanded(child: CustomTextField(controller: _zip, label: 'Kode Pos', hint: '40234', prefixIcon: Icons.markunread_mailbox_outlined, keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _province,
            decoration: const InputDecoration(labelText: 'Provinsi', prefixIcon: Icon(Icons.map_outlined, color: AppTheme.primary, size: 20)),
            items: _provinces.map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 13)))).toList(),
            onChanged: (v) => setState(() => _province = v!),
          ),
          const SizedBox(height: 24),
          CustomButton(label: _isEdit ? '✓ Perbarui Alamat' : '✓ Simpan Alamat', isLoading: _isSaving, onPressed: _save),
          const SizedBox(height: 24),
        ]),
      ),
    ),
  );
}