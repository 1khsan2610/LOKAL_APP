import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_widgets.dart' as custom_widgets;

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: custom_widgets.CustomAppBar(title: AppStrings.navProfile),
      body: currentUserAsync.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.login, size: 48, color: AppTheme.textHint),
                  const SizedBox(height: 16),
                  Text(
                    'Silakan login terlebih dahulu',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    ),
                    child: const Text('Login'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(AppNumbers.paddingLarge),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryDark,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            user.name?.isNotEmpty == true
                                ? user.name![0].toUpperCase()
                                : '👤',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Name
                      Text(
                        user.name ?? 'Pengguna',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Phone
                      Text(
                        user.phone,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Role badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.role.toString().split('.').last.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Profile Info Section
                Padding(
                  padding: const EdgeInsets.all(AppNumbers.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informasi Profil',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Column(
                          children: [
                            _ProfileInfoTile(
                              icon: Icons.email,
                              label: 'Email',
                              value: user.email ?? 'Belum diatur',
                            ),
                            const Divider(height: 0),
                            _ProfileInfoTile(
                              icon: Icons.location_on,
                              label: 'Alamat',
                              value: user.address ?? 'Belum diatur',
                            ),
                            const Divider(height: 0),
                            _ProfileInfoTile(
                              icon: Icons.location_city,
                              label: 'Kota',
                              value: user.city ?? 'Belum diatur',
                            ),
                            const Divider(height: 0),
                            _ProfileInfoTile(
                              icon: Icons.verified,
                              label: 'Status Verifikasi',
                              value: user.isVerified ? 'Terverifikasi ✓' : 'Belum Terverifikasi',
                              trailing: _VerificationBadge(
                                isVerified: user.isVerified,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Settings Section
                Padding(
                  padding: const EdgeInsets.all(AppNumbers.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pengaturan',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Column(
                          children: [
                            _SettingsTile(
                              icon: Icons.edit,
                              label: 'Edit Profil',
                              onTap: () {},
                            ),
                            const Divider(height: 0),
                            _SettingsTile(
                              icon: Icons.notifications,
                              label: 'Pengaturan Notifikasi',
                              onTap: () {},
                            ),
                            const Divider(height: 0),
                            _SettingsTile(
                              icon: Icons.security,
                              label: 'Keamanan',
                              onTap: () {},
                            ),
                            const Divider(height: 0),
                            _SettingsTile(
                              icon: Icons.help,
                              label: 'Bantuan & FAQ',
                              onTap: () {},
                            ),
                            const Divider(height: 0),
                            _SettingsTile(
                              icon: Icons.description,
                              label: 'Syarat & Ketentuan',
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Logout
                Padding(
                  padding: const EdgeInsets.all(AppNumbers.paddingMedium),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _handleLogout(context, ref),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                        side: const BorderSide(color: AppTheme.errorColor),
                      ),
                      child: Text(AppStrings.btnLogout),
                    ),
                  ),
                ),

                const SizedBox(height: AppNumbers.paddingLarge),
              ],
            ),
          );
        },
        loading: () => const custom_widgets.LoadingWidget(message: 'Memuat profil...'),
        error: (error, st) => custom_widgets.ErrorWidget(message: error.toString()),
      ),
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  const _ProfileInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppNumbers.paddingMedium),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _VerificationBadge extends StatelessWidget {
  final bool isVerified;

  const _VerificationBadge({required this.isVerified});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isVerified
            ? AppTheme.successColor.withOpacity(0.1)
            : AppTheme.warningColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isVerified ? '✓' : '!',
        style: TextStyle(
          color: isVerified ? AppTheme.successColor : AppTheme.warningColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
