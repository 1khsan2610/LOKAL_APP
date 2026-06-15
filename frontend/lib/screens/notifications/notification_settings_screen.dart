import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/common/custom_widgets.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(notificationPreferencesProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Pengaturan Notifikasi',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: const Icon(
                        Icons.notifications_active,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kelola Notifikasi Anda',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Aktifkan atau nonaktifkan notifikasi sesuai preferensi',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Master Toggle
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            Icons.power_settings_new,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Semua Notifikasi',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Aktifkan semua notifikasi',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    trailing: Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: preferences.allNotifications,
                        onChanged: (value) {
                          ref
                              .read(notificationPreferencesProvider.notifier)
                              .state = preferences.copyWith(
                            allNotifications: value,
                            orderNotifications: value,
                            promotionNotifications: value,
                            coinRewardNotifications: value,
                            stockAlertNotifications: value,
                          );
                        },
                        activeColor: AppTheme.primaryColor,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Text(
                          'Dengan mengaktifkan opsi ini, semua kategori notifikasi akan diaktifkan',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Notification Categories
              Text(
                'Kategori Notifikasi',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              // Order Notifications
              _buildNotificationCategory(
                context,
                icon: Icons.shopping_bag,
                iconColor: const Color(0xFF4CAF50),
                title: 'Notifikasi Pesanan',
                subtitle: 'Pesanan baru, pengiriman, dan pengiriman dikonfirmasi',
                value: preferences.orderNotifications,
                onChanged: (value) {
                  ref.read(notificationPreferencesProvider.notifier).state =
                      preferences.copyWith(orderNotifications: value);
                },
              ),
              const SizedBox(height: 12),

              // Promotion Notifications
              _buildNotificationCategory(
                context,
                icon: Icons.local_offer,
                iconColor: const Color(0xFFFF9800),
                title: 'Promosi & Penawaran',
                subtitle: 'Diskon, penawaran khusus, dan promo terbatas',
                value: preferences.promotionNotifications,
                onChanged: (value) {
                  ref.read(notificationPreferencesProvider.notifier).state =
                      preferences.copyWith(promotionNotifications: value);
                },
              ),
              const SizedBox(height: 12),

              // Coin Reward Notifications
              _buildNotificationCategory(
                context,
                icon: Icons.monetization_on,
                iconColor: const Color(0xFFFFD700),
                title: 'Reward Lokal Coin',
                subtitle: 'Poin reward, bonus, dan peningkatan saldo',
                value: preferences.coinRewardNotifications,
                onChanged: (value) {
                  ref.read(notificationPreferencesProvider.notifier).state =
                      preferences.copyWith(coinRewardNotifications: value);
                },
              ),
              const SizedBox(height: 12),

              // Stock Alert Notifications
              _buildNotificationCategory(
                context,
                icon: Icons.inventory_2,
                iconColor: const Color(0xFF2196F3),
                title: 'Peringatan Stok',
                subtitle: 'Notifikasi produk stok terbatas atau habis',
                value: preferences.stockAlertNotifications,
                onChanged: (value) {
                  ref.read(notificationPreferencesProvider.notifier).state =
                      preferences.copyWith(stockAlertNotifications: value);
                },
              ),
              const SizedBox(height: 32),

              // Info Section
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.infoColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.infoColor.withOpacity(0.2),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info,
                      color: AppTheme.infoColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Anda dapat mengubah pengaturan ini kapan saja. Notifikasi penting seperti konfirmasi pembayaran akan selalu dikirim.',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppTheme.infoColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCategory(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: value,
                onChanged: onChanged,
                activeColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
