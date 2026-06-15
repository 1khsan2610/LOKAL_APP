import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

// Notifications list provider
class NotificationsNotifier extends StateNotifier<AsyncValue<List<AppNotification>>> {
  final ApiService apiService;

  NotificationsNotifier({required this.apiService})
      : super(const AsyncValue.loading()) {
    // Fetch notifications on initialization
    _init();
  }

  Future<void> _init() async {
    await fetchNotifications();
  }

  Future<void> fetchNotifications({int page = 1}) async {
    state = const AsyncValue.loading();
    try {
      // Mock data for now - replace with actual API call
      // final notifications = await apiService.fetchNotifications(page: page);
      final mockNotifications = <AppNotification>[
        AppNotification(
          id: '1',
          userId: 'user123',
          type: NotificationType.orderConfirmed,
          title: 'Pesanan Dikonfirmasi',
          message: 'Pesanan #ORD-001 telah dikonfirmasi oleh penjual',
          isRead: false,
          createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        AppNotification(
          id: '2',
          userId: 'user123',
          type: NotificationType.paymentSuccessful,
          title: 'Pembayaran Berhasil',
          message: 'Pembayaran sebesar Rp 150.000 berhasil diproses',
          isRead: false,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        AppNotification(
          id: '3',
          userId: 'user123',
          type: NotificationType.orderShipped,
          title: 'Pesanan Dalam Perjalanan',
          message: 'Pesanan #ORD-001 sedang dalam perjalanan ke alamat Anda',
          isRead: true,
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        AppNotification(
          id: '4',
          userId: 'user123',
          type: NotificationType.coinRewarded,
          title: 'Reward Lokal Coin Diterima',
          message: 'Anda mendapatkan 50 Lokal Coin dari pembelian terakhir',
          isRead: true,
          createdAt: DateTime.now().subtract(const Duration(hours: 24)),
        ),
        AppNotification(
          id: '5',
          userId: 'user123',
          type: NotificationType.promotion,
          title: 'Promo Spesial Hari Ini',
          message: 'Diskon hingga 50% untuk produk pilihan. Jangan lewatkan!',
          isRead: true,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
      state = AsyncValue.data(mockNotifications);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      // API call would go here
      // await apiService.markNotificationAsRead(notificationId);
      
      // Update local state
      if (state case AsyncValue(value: List<AppNotification> notifications)) {
        final updatedNotifications = notifications.map((notif) {
          return notif.id == notificationId
              ? notif.copyWith(isRead: true)
              : notif;
        }).toList();
        state = AsyncValue.data(updatedNotifications);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      // API call would go here
      // await apiService.markAllNotificationsAsRead();
      
      // Update local state
      if (state case AsyncValue(value: List<AppNotification> notifications)) {
        final updatedNotifications = notifications
            .map((notif) => notif.copyWith(isRead: true))
            .toList();
        state = AsyncValue.data(updatedNotifications);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      // API call would go here
      // await apiService.deleteNotification(notificationId);
      
      // Update local state
      if (state case AsyncValue(value: List<AppNotification> notifications)) {
        final updatedNotifications = notifications
            .where((notif) => notif.id != notificationId)
            .toList();
        state = AsyncValue.data(updatedNotifications);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final notificationsProvider = StateNotifierProvider<NotificationsNotifier,
    AsyncValue<List<AppNotification>>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return NotificationsNotifier(apiService: apiService);
});

// Unread notifications count
final unreadNotificationsCountProvider = FutureProvider<int>((ref) async {
  final notificationsAsync = ref.watch(notificationsProvider);
  return notificationsAsync.when(
    data: (notifications) => notifications.where((n) => !n.isRead).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

// Unread notifications stream (for badge update)
final unreadNotificationsStreamProvider =
    StreamProvider<int>((ref) async* {
  // This would typically stream from a WebSocket or polling
  // For now, we'll just yield the count periodically
  while (true) {
    await Future.delayed(const Duration(seconds: 30));
    final count = await ref.read(unreadNotificationsCountProvider.future);
    yield count;
  }
});

// Notification preferences provider
final notificationPreferencesProvider =
    StateProvider<NotificationPreferences>((ref) {
  return NotificationPreferences(
    orderNotifications: true,
    promotionNotifications: true,
    coinRewardNotifications: true,
    stockAlertNotifications: true,
    allNotifications: true,
  );
});

class NotificationPreferences {
  final bool orderNotifications;
  final bool promotionNotifications;
  final bool coinRewardNotifications;
  final bool stockAlertNotifications;
  final bool allNotifications;

  NotificationPreferences({
    required this.orderNotifications,
    required this.promotionNotifications,
    required this.coinRewardNotifications,
    required this.stockAlertNotifications,
    required this.allNotifications,
  });

  NotificationPreferences copyWith({
    bool? orderNotifications,
    bool? promotionNotifications,
    bool? coinRewardNotifications,
    bool? stockAlertNotifications,
    bool? allNotifications,
  }) {
    return NotificationPreferences(
      orderNotifications: orderNotifications ?? this.orderNotifications,
      promotionNotifications:
          promotionNotifications ?? this.promotionNotifications,
      coinRewardNotifications:
          coinRewardNotifications ?? this.coinRewardNotifications,
      stockAlertNotifications:
          stockAlertNotifications ?? this.stockAlertNotifications,
      allNotifications: allNotifications ?? this.allNotifications,
    );
  }
}
