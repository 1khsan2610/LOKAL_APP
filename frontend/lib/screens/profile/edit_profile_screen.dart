import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/product_card.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name, _phone;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _name  = TextEditingController(text: user?.name ?? '');
    _phone = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() { _name.dispose(); _phone.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final ok = await context.read<AuthProvider>().updateProfile({'name': _name.text.trim(), 'phone': _phone.text.trim()});
    if (!mounted) return;
    if (ok) { AppSnackBar.show(context, '✓ Profil berhasil diperbarui'); context.pop(); }
    else {
      AppSnackBar.show(context, 'Gagal memperbarui profil', isError: true);
    }
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Edit Profil'),
        leading: BackButton(onPressed: () => context.pop()),
    ),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Form(key: _formKey, child: Column(children: [
        CustomTextField(controller: _name, label: 'Nama Lengkap', prefixIcon: Icons.person_outlined,
          validator: (v) => (v?.isEmpty ?? true) ? 'Nama wajib diisi' : null),
        const SizedBox(height: 14),
        CustomTextField(controller: _phone, label: 'No. HP', prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone),
        const SizedBox(height: 24),
        CustomButton(label: '✓ Simpan Perubahan', isLoading: _isSaving, onPressed: _save),
      ])),
    ),
  );
}

