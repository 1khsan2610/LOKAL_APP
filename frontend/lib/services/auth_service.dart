import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthResponse {
  final String accessToken;
  final String? refreshToken;
  final User? user;

  AuthResponse({
    required this.accessToken,
    this.refreshToken,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Handle both 'token' and 'access_token' fields from backend
    final token = json['token'] ?? json['access_token'] ?? '';
    return AuthResponse(
      accessToken: token.toString(),
      refreshToken: json['refresh_token'] != null ? json['refresh_token'].toString() : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class AuthService {
  final ApiService apiService;
  final FlutterSecureStorage secureStorage;

  AuthService({
    required this.apiService,
    required this.secureStorage,
  });

  // Request OTP
  Future<void> requestOtp(String phoneNumber) async {
    try {
      // Validate phone format
      if (phoneNumber.isEmpty) {
        throw Exception('Nomor telepon tidak boleh kosong');
      }
      
      // Format phone: remove spaces and validate
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '');
      if (cleanPhone.length < 10) {
        throw Exception('Nomor telepon minimal 10 digit');
      }
      
      // Add debug log
      if (kDebugMode) {
        print('📱 Requesting OTP for phone: $cleanPhone');
      }
      
      await apiService.requestOtp(cleanPhone);
      
      if (kDebugMode) {
        print('✅ OTP Request Success');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ OTP Request Failed: $e');
      }
      rethrow;
    }
  }

  // Verify OTP dan login
  Future<AuthResponse> verifyOtp({
    required String phoneNumber,
    required String otp,
    required String role,
  }) async {
    try {
      final response = await apiService.post(
        '/auth/verify-otp',
        data: {
          'phone_number': phoneNumber,  // FIXED: Laravel expects phone_number
          'code': otp,                   // FIXED: Laravel expects code (not otp)
          'role': role,
          'name': 'User',                // Default name
        },
        responseDecoder: (data) => data is Map ? Map<String, dynamic>.from(data) : {},
      );

      final authResponse = AuthResponse.fromJson(response as Map<String, dynamic>);

      // Simpan tokens
      if (authResponse.refreshToken != null) {
        await _saveTokens(authResponse.accessToken, authResponse.refreshToken!);
      } else {
        await _saveTokens(authResponse.accessToken, authResponse.accessToken);
      }

      // Set tokens ke API service
      apiService.setTokens(authResponse.accessToken, refreshToken: authResponse.refreshToken);

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  // Save tokens
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await secureStorage.write(key: 'access_token', value: accessToken);
    await secureStorage.write(key: 'refresh_token', value: refreshToken);
  }

  // Refresh token
  Future<void> refreshAccessToken() async {
    try {
      final refreshToken = await _getRefreshToken();
      if (refreshToken == null) {
        throw Exception('Refresh token tidak ditemukan');
      }

      final response = await apiService.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
        responseDecoder: (data) => data is Map ? Map<String, dynamic>.from(data) : {},
      );

      final authResponse = AuthResponse.fromJson(response as Map<String, dynamic>);

      // Perbarui tokens
      if (authResponse.refreshToken != null) {
        await _saveTokens(authResponse.accessToken, authResponse.refreshToken!);
      } else {
        await _saveTokens(authResponse.accessToken, authResponse.accessToken);
      }
      apiService.setTokens(authResponse.accessToken,
          refreshToken: authResponse.refreshToken);
    } catch (e) {
      // Jika refresh gagal, hapus tokens
      await logout();
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await apiService.delete(
        '/auth/logout',
        responseDecoder: (data) => data,
      );
    } catch (e) {
      // Continue logout even if API call fails
    } finally {
      await _clearTokens();
      apiService.clearTokens();
    }
  }

  // Get current session
  Future<User?> getCurrentUser() async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        return null;
      }

      // Set token ke API service jika belum
      if (apiService.accessToken == null) {
        final refreshToken = await _getRefreshToken();
        apiService.setTokens(accessToken, refreshToken: refreshToken);
      }

      final user = await apiService.get(
        '/users/me',
        responseDecoder: (data) => User.fromJson(data),
      );

      return user;
    } catch (e) {
      // Token invalid, clear storage
      await _clearTokens();
      apiService.clearTokens();
      return null;
    }
  }

  // Update profile
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
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (address != null) data['address'] = address;
      if (city != null) data['city'] = city;
      if (latitude != null) data['latitude'] = latitude;
      if (longitude != null) data['longitude'] = longitude;
      if (avatar != null) data['avatar'] = avatar;

      final user = await apiService.patch(
        '/users/me',
        data: data,
        responseDecoder: (data) => User.fromJson(data),
      );

      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Upload avatar
  Future<String> uploadAvatar(String filePath) async {
    try {
      final url = await apiService.uploadFile(
        '/users/upload-avatar',
        filePath: filePath,
        fileKey: 'avatar',
        responseDecoder: (data) => data['url'] ?? '',
      );

      return url;
    } catch (e) {
      rethrow;
    }
  }

  // Token management
  Future<String?> _getAccessToken() async {
    return await secureStorage.read(key: 'access_token');
  }

  Future<String?> _getRefreshToken() async {
    return await secureStorage.read(key: 'refresh_token');
  }

  Future<void> _clearTokens() async {
    await Future.wait([
      secureStorage.delete(key: 'access_token'),
      secureStorage.delete(key: 'refresh_token'),
    ]);
  }

  Future<bool> isLoggedIn() async {
    final token = await _getAccessToken();
    return token != null;
  }

  // Load token at app startup
  Future<String?> loadStoredToken() async {
    try {
      final accessToken = await _getAccessToken();
      final refreshToken = await _getRefreshToken();
      
      if (accessToken != null) {
        // Restore token to ApiService
        apiService.setTokens(accessToken, refreshToken: refreshToken);
        return accessToken;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
