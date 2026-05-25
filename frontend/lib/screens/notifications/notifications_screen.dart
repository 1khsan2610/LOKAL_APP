import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../widgets/common/custom_widgets.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notifikasi',
        showBackButton: true,
      ),
      body: ListView(
        children: [
          // Notification items
          ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.info,
                color: AppTheme.infoColor,
              ),
            ),
            title: const Text('Pesanan Dikonfirmasi'),
            subtitle: const Text('Pesanan #12345 telah dikonfirmasi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(indent: 70),
          ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppTheme.successColor,
              ),
            ),
            title: const Text('Pembayaran Berhasil'),
            subtitle: const Text('Pembayaran untuk pesanan #12345 berhasil'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(indent: 70),
          ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.star,
                color: AppTheme.primaryColor,
              ),
            ),
            title: const Text('Reward Lokal Coin'),
            subtitle: const Text('Anda mendapatkan 50 Lokal Coin'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
