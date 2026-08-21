// ═══════════════════════════════════════════════════════════════════
//  NotificationScreen  —  lib/screens/notification/notification_screen.dart
//  UX/UI Refactor: Filter pill tabs, order/promo notification cards,
//  "Lihat Detail Pesanan" → order list, "Klaim Promo" buttons.
// ═══════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/product_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/product_card.dart';
import '../../widgets/app_card.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _selectedFilter = 'Semua';

  final _filters = ['Semua', 'Pesanan', 'Promo', 'Update'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<NotificationProvider>().load());
  }

  List<NotificationModel> _filteredNotifications(NotificationProvider notif) {
    return notif.notifications.where((n) {
      switch (_selectedFilter) {
        case 'Pesanan':
          return n.type == 'order' || n.type == 'payment';
        case 'Promo':
          return n.type == 'promo' || n.type == 'coin';
        case 'Update':
          return n.type == 'system' || n.type == 'update';
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final notif = context.watch<NotificationProvider>();
    final filtered = _filteredNotifications(notif);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Notifikasi'),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          TextButton(
            onPressed: () => context.read<NotificationProvider>().markAllRead(),
            child: const Text('Tandai Semua Dibaca', style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Filter Pill Tabs ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppTheme.surface,
            child: Row(
              children: _filters.map((filter) {
                final selected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected ? AppTheme.primary : AppTheme.surface2,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? AppTheme.primary : AppTheme.border,
                        ),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          // ── Notification List ──
          Expanded(
            child: notif.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : filtered.isEmpty
                    ? const EmptyState(
                        emoji: '🔔',
                        title: 'Belum Ada Notifikasi',
                        subtitle: 'Notifikasi pesanan dan promo akan muncul di sini')
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final n = filtered[i];
                          final orderNumber = n.data?['order_number'] as String? ?? '';

                          return _buildNotificationCard(
                            notification: n,
                            orderNumber: orderNumber,
                            onTap: () {
                              context.read<NotificationProvider>().markRead(n.id);
                              if (n.type == 'order' || n.type == 'payment') {
                                context.push('/orders');
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required NotificationModel notification,
    String orderNumber = '',
    required VoidCallback onTap,
  }) {
    final (icon, bgColor) = switch (notification.type) {
      'order' || 'payment' => ('📦', const Color(0xFFDCFCE7)),
      'promo'              => ('🏷️', const Color(0xFFFEF3C7)),
      'coin'               => ('🪙', const Color(0xFFD1FAE5)),
      _                    => ('🔔', const Color(0xFFDBEAFE)),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        color: notification.isRead ? AppTheme.surface : AppTheme.surface2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
                  child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            notification.createdAt,
                            style: const TextStyle(fontSize: 10, color: AppTheme.textHint),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (!notification.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            // ── Action Button ──
            if (notification.type == 'order' || notification.type == 'payment')
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.receipt_long_outlined, size: 14),
                  label: Text(
                    'Lihat Detail Pesanan #$orderNumber',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            if (notification.type == 'promo' || notification.type == 'coin')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.local_offer_outlined, size: 14),
                  label: const Text(
                    'Klaim Promo Sekarang',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}