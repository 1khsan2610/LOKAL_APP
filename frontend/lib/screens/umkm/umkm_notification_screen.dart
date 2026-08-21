import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/product_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_card.dart';

class UmkmNotificationScreen extends StatefulWidget {
  const UmkmNotificationScreen({super.key});

  @override
  State<UmkmNotificationScreen> createState() => _UmkmNotificationScreenState();
}

class _UmkmNotificationScreenState extends State<UmkmNotificationScreen> {
  String _selectedFilter = 'Semua';
  final _filters = ['Semua', 'Pesanan', 'Keuangan', 'Sistem'];

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
        case 'Keuangan':
          return n.type == 'coin' || n.type == 'withdrawal';
        case 'Sistem':
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
    final unreadCount = notif.notifications.where((n) => !n.isRead).length;
    final newOrders = notif.notifications.where((n) => n.type == 'order' && !n.isRead).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 768;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Main Notification List ──
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppTheme.cardBorder)),
                    ),
                    child: Row(
                      children: [
                        const Text('Notifikasi',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                        const Spacer(),
                        TextButton(
                          onPressed: () => context.read<NotificationProvider>().markAllRead(),
                          child: const Text('Tandai semua telah dibaca',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  // Filter Tabs
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: _filters.map((filter) {
                        final selected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedFilter = filter),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                              decoration: BoxDecoration(
                                color: selected ? AppTheme.primary : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected ? AppTheme.primary : AppTheme.cardBorder,
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
                  // Notification List
                  Expanded(
                    child: notif.isLoading
                        ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                        : filtered.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.notifications_none, size: 64, color: AppTheme.textHint),
                                    const SizedBox(height: 12),
                                    const Text('Belum Ada Notifikasi',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
                                    const SizedBox(height: 4),
                                    const Text('Notifikasi akan muncul di sini',
                                      style: TextStyle(fontSize: 13, color: AppTheme.textHint)),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
                                        context.push('/umkm/orders');
                                      }
                                    },
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
            // ── Sidebar Kanan (Desktop) ──
            if (isWide)
              Container(
                width: 300,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: AppTheme.cardBorder)),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ringkasan Hari Ini
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0A2540), Color(0xFF1966D2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Ringkasan Hari Ini',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('$unreadCount',
                                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                                    const Text('Belum Dibaca',
                                      style: TextStyle(fontSize: 11, color: Colors.white70)),
                                  ],
                                ),
                              ),
                              Container(width: 1, height: 40, color: Colors.white24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('$newOrders',
                                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFFFFD54F))),
                                    const Text('Pesanan Baru',
                                      style: TextStyle(fontSize: 11, color: Colors.white70)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Nusantara AI Prompt
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F5FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFDBEAFE)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text('Nusantara AI',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Bantu Saya memprioritaskan pesanan yang perlu segera diproses hari ini.',
                            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => context.push('/umkm/ai-assistant'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primary,
                                side: const BorderSide(color: AppTheme.primary),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Tanya AI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Tips Edukasi
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFEF3C7)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.lightbulb_outline, color: Colors.white, size: 18),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text('Tips: Atur Notifikasi',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF92400E))),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Aktifkan notifikasi prioritas untuk pesanan dan pembayaran agar tidak ketinggalan info penting.',
                            style: TextStyle(fontSize: 12, color: Color(0xFFA16207), height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationCard({
    required NotificationModel notification,
    String orderNumber = '',
    required VoidCallback onTap,
  }) {
    final (icon, bgColor, label) = switch (notification.type) {
      'order' || 'payment' => ('📦', const Color(0xFFDCFCE7), 'Pesanan Baru'),
      'coin' || 'withdrawal' => ('🪙', const Color(0xFFD1FAE5), 'Pencairan Dana'),
      'system' || 'update' => ('🤖', const Color(0xFFDBEAFE), 'Pembaruan Sistem'),
      'promo' => ('🏷️', const Color(0xFFFEF3C7), 'Promo Diskon Lokal'),
      _ => ('🔔', const Color(0xFFF1F5F9), 'Info'),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        color: notification.isRead ? Colors.white : const Color(0xFFF8FAFC),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42, height: 42,
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
                          // Badge kategori
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(label,
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: bgColor == const Color(0xFFDCFCE7) ? const Color(0xFF15803D) : bgColor == const Color(0xFFD1FAE5) ? const Color(0xFF065F46) : bgColor == const Color(0xFFDBEAFE) ? const Color(0xFF1E40AF) : const Color(0xFF92400E))),
                          ),
                          const Spacer(),
                          Text(notification.createdAt,
                            style: const TextStyle(fontSize: 10, color: AppTheme.textHint)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
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
                    width: 8, height: 8,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            if (orderNumber.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.receipt_long_outlined, size: 14),
                  label: Text('Lihat Pesanan #$orderNumber',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}