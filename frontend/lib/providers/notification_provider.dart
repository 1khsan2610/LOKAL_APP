import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

// Notifications list provider
class NotificationsNotifier extends StateNotifier<AsyncValue<List<AppNotification>>> {
  final ApiService apiService;

  NotificationsNotifier({required this.apiService})
      : super(const AsyncValue.loading());

  Future<void> fetchNotifications({int page = 1}) async {
    state = const AsyncValue.loading();
    try {
      // This would need to be implemented in ApiService
      state = AsyncValue.data(<AppNotification>[]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      // This would need to be implemented in ApiService
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
      // This would need to be implemented in ApiService
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
      // This would need to be implemented in ApiService
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
