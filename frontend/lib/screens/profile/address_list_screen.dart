import '../../widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../models/product_model.dart';
import '../../utils/app_theme.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});
  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  final _api = ApiService();
  List<AddressModel> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final resp = await _api.getAddresses();
      setState(() { _addresses = (resp.data['data'] as List).map((e) => AddressModel.fromJson(e)).toList(); });
    } catch (_) {} finally { setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Alamat Pengiriman'),
      leading: BackButton(onPressed: () => Navigator.pop(context)),
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => context.push('/profile/addresses/form').then((_) => _load()),
      backgroundColor: AppTheme.primary,
      icon: const Icon(Icons.add),
      label: const Text('Tambah Alamat'),
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
        : _addresses.isEmpty
            ? EmptyState(emoji: '📍', title: 'Belum Ada Alamat',
                subtitle: 'Tambahkan alamat pengiriman kamu',
                buttonLabel: 'Tambah Alamat',
                onButton: () => context.push('/profile/addresses/form').then((_) => _load()))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _addresses.length,
                itemBuilder: (_, i) {
                  final a = _addresses[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.surface, borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: a.isDefault ? AppTheme.primary : AppTheme.border, width: a.isDefault ? 2 : 1),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text(a.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        if (a.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(color: AppTheme.surface2, borderRadius: BorderRadius.circular(5), border: Border.all(color: AppTheme.primary)),
                            child: const Text('Utama', style: TextStyle(fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.w700)),
                          ),
                        ],
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.textHint),
                          onPressed: () => context.push('/profile/addresses/form?id=${a.id}').then((_) => _load()),
                          padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.danger),
                          onPressed: () async { await _api.deleteAddress(a.id); _load(); },
                          padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                        ),
                      ]),
                      const SizedBox(height: 4),
                      Text('${a.recipientName} · ${a.phone}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 3),
                      Text(a.fullAddress, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      if (!a.isDefault) ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () async { await _api.setDefaultAddress(a.id); _load(); },
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                          child: const Text('Jadikan Utama', style: TextStyle(fontSize: 12, color: AppTheme.primary)),
                        ),
                      ],
                    ]),
                  );
                },
              ),
  );
}

