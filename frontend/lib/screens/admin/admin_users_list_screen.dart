import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/product_card.dart';

class AdminUsersListScreen extends StatefulWidget {
  const AdminUsersListScreen({super.key});
  @override
  State<AdminUsersListScreen> createState() => _AdminUsersListScreenState();
}

class _AdminUsersListScreenState extends State<AdminUsersListScreen> {
  final _api = ApiService();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  String? _filterRole;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final resp = await _api.dio.get('/admin/users', queryParameters: {
        if (_filterRole != null) 'role': _filterRole,
      });
      if (mounted) {
        setState(() {
          _users = (resp.data['data']['data'] as List).cast<Map<String, dynamic>>();
        });
      }
    } catch (_) {
      if (mounted) AppSnackBar.show(context, 'Gagal memuat data pengguna', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleUserStatus(int userId) async {
    try {
      await _api.dio.patch('/admin/users/$userId/status');
      if (!mounted) return;
      AppSnackBar.show(context, '✓ Status pengguna diperbarui');
      _loadUsers();
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(context, 'Gagal mengubah status pengguna', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pengguna'),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<String?>(
                    segments: const [
                      ButtonSegment(value: null, label: Text('Semua')),
                      ButtonSegment(value: 'admin', label: Text('Admin')),
                      ButtonSegment(value: 'umkm', label: Text('UMKM')),
                      ButtonSegment(value: 'konsumen', label: Text('Pembeli')),
                    ],
                    selected: {_filterRole},
                    onSelectionChanged: (v) {
                      setState(() => _filterRole = v.first);
                      _loadUsers();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : _users.isEmpty
                    ? const Center(child: Text('Tidak ada pengguna'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _users.length,
                        itemBuilder: (_, i) {
                          final user = _users[i];
                          final role = user['role'] as String;
                          final isActive = user['is_active'] as bool? ?? true;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(user['name'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                      const SizedBox(height: 4),
                                      Text(user['email'], style: const TextStyle(fontSize: 12, color: AppTheme.textHint)),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: role == 'admin' ? const Color(0xFFFEE2E2) : role == 'umkm' ? const Color(0xFFEDE9FE) : const Color(0xFFDCFCE7),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          role == 'admin' ? 'Admin' : role == 'umkm' ? 'UMKM' : 'Pembeli',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: role == 'admin' ? const Color(0xFFB91C1C) : role == 'umkm' ? const Color(0xFF6D28D9) : const Color(0xFF15803D),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Switch(
                                      value: isActive,
                                      onChanged: (_) => _toggleUserStatus(user['id']),
                                      activeThumbColor: AppTheme.primary,
                                    ),
                                    Text(
                                      isActive ? 'Aktif' : 'Nonaktif',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isActive ? AppTheme.primary : AppTheme.danger,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
