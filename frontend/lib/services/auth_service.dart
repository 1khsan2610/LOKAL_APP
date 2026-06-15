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
    final data = json['data'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['data'] as Map)
        : Map<String, dynamic>.from(json);

    final tokens = data['tokens'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(data['tokens'] as Map)
        : <String, dynamic>{};

    final accessToken = (data['access_token'] ?? data['token'] ?? tokens['access_token'] ?? '')
        .toString();
    final refreshToken = (data['refresh_token'] ?? tokens['refresh_token'])?.toString();
    final userData = data['user'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(data['user'] as Map)
        : <String, dynamic>{};

    return AuthResponse(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: userData.isNotEmpty ? User.fromJson(userData) : null,
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


  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiService.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
        responseDecoder: (data) => data is Map ? Map<String, dynamic>.from(data) : {},
      );

      final authResponse = AuthResponse.fromJson(response as Map<String, dynamic>);
      if (authResponse.accessToken.isEmpty) {
        throw Exception('Token tidak ditemukan dari respons login');
      }

      if (authResponse.refreshToken != null) {
        await _saveTokens(authResponse.accessToken, authResponse.refreshToken!);
      } else {
        await _saveTokens(authResponse.accessToken, authResponse.accessToken);
      }
      apiService.setTokens(authResponse.accessToken, refreshToken: authResponse.refreshToken);

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phoneNumber,
    required String role,
  }) async {
    try {
      final response = await apiService.post(
        '/auth/register-account',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'phone_number': phoneNumber,
          'role': role,
        },
        responseDecoder: (data) => data is Map ? Map<String, dynamic>.from(data) : {},
      );

      return response as Map<String, dynamic>;
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
