// ═══════════════════════════════════════════════════════════════════
//  NotificationScreen  —  lib/screens/notification/notification_screen.dart
// ═══════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/product_card.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<NotificationProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    final notif = context.watch<NotificationProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        actions: [
          TextButton(
            onPressed: () => context.read<NotificationProvider>().markAllRead(),
            child: const Text('Tandai Semua', style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
      body: notif.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : notif.notifications.isEmpty
              ? const EmptyState(emoji: '🔔', title: 'Belum Ada Notifikasi', subtitle: 'Notifikasi pesanan dan promo akan muncul di sini')
              : ListView.separated(
                  itemCount: notif.notifications.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final n = notif.notifications[i];
                    final (icon, bg) = switch (n.type) {
                      'order'  => ('📦', const Color(0xFFDCFCE7)),
                      'promo'  => ('🏷️', const Color(0xFFFEF3C7)),
                      'coin'   => ('🪙', const Color(0xFFD1FAE5)),
                      _        => ('🔔', const Color(0xFFDBEAFE)),
                    };
                    return InkWell(
                      onTap: () => context.read<NotificationProvider>().markRead(n.id),
                      child: Container(
                        color: n.isRead ? null : AppTheme.surface2,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                            child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(n.title, style: TextStyle(fontSize: 13, fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700)),
                            const SizedBox(height: 3),
                            Text(n.body, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(n.createdAt, style: const TextStyle(fontSize: 10, color: AppTheme.textHint)),
                          ])),
                          if (!n.isRead)
                            Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 4),
                              decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle)),
                        ]),
                      ),
                    );
                  },
                ),
    );
  }
}

