import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart' as auth_service;
import '../services/storage_service.dart';

// Service providers
final apiServiceProvider = Provider((ref) => ApiService());

final authServiceProvider = Provider((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return auth_service.AuthService(
    apiService: apiService,
    secureStorage: const FlutterSecureStorage(),
  );
});

final storageServiceProvider = Provider((ref) => StorageService());

// Auth state notifier
class AuthNotifier extends StateNotifier<AsyncValue<auth_service.AuthResponse?>> {
  final auth_service.AuthService authService;
  final StorageService storage;

  AuthNotifier({
    required this.authService,
    required this.storage,
  }) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      // Load token from secure storage at app startup
      final token = await authService.loadStoredToken();
      
      if (token != null) {
        // Token loaded, try to get user info with timeout
        try {
          final user = await authService.getCurrentUser().timeout(
            const Duration(seconds: 5),
            onTimeout: () => null,
          );
          if (user != null) {
            state = AsyncValue.data(auth_service.AuthResponse(
              accessToken: token,
              user: user,
            ));
          } else {
            // Token exists but user fetch failed, clear it
            state = const AsyncValue.data(null);
          }
        } catch (e) {
          // API error, go to login
          state = const AsyncValue.data(null);
        }
      } else {
        // No token found
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> requestOtp(String phoneNumber) async {
    state = const AsyncValue.loading();
    try {
      await authService.requestOtp(phoneNumber);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<auth_service.AuthResponse> verifyOtp({
    required String phoneNumber,
    required String otp,
    required String role,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await authService.verifyOtp(
        phoneNumber: phoneNumber,
        otp: otp,
        role: role,
      );
      state = AsyncValue.data(response);
      return response;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await authService.logout();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      return await authService.getCurrentUser();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<User> updateProfile({
    String? name,
    String? email,
    String? address,
    String? city,
    double? latitude,
    double? longitude,
    String? avatar,
  }) async {
    try {
      final user = await authService.updateProfile(
        name: name,
        email: email,
        address: address,
        city: city,
        latitude: latitude,
        longitude: longitude,
        avatar: avatar,
      );
      return user;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<String> uploadAvatar(String filePath) async {
    try {
      return await authService.uploadAvatar(filePath);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      return await authService.isLoggedIn();
    } catch (e) {
      return false;
    }
  }
}

// Auth provider
final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<auth_service.AuthResponse?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  final storage = ref.watch(storageServiceProvider);
  return AuthNotifier(
    authService: authService,
    storage: storage,
  );
});

// Current user provider
final currentUserProvider = FutureProvider<User?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getCurrentUser();
});

// Check if logged in provider
final isLoggedInProvider = FutureProvider<bool>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.isLoggedIn();
});

// OTP state provider
final otpStateProvider = StateProvider<Map<String, dynamic>>((ref) {
  return {
    'phone': '',
    'otpSent': false,
    'timeRemaining': 0,
    'attempts': 0,
  };
});
