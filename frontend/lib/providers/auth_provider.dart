import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
import '../models/product_model.dart';

class AuthProvider extends ChangeNotifier {
  final _api     = ApiService();
  final _storage = const FlutterSecureStorage();

  UserModel? _user;
  bool _isLoading  = false;
  bool _isLoggedIn = false;
  String? _errorMessage;

  UserModel? get user         => _user;
  bool       get isLoading    => _isLoading;
  bool       get isLoggedIn   => _isLoggedIn;
  String?    get errorMessage => _errorMessage;

  // ─── Init (check stored token) ───────────────────────────────────
  Future<void> init() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return;

    try {
      final resp = await _api.getMe();
      if (resp.data['success'] == true) {
        _user      = UserModel.fromJson(resp.data['data']);
        _isLoggedIn = true;
        notifyListeners();
      }
    } catch (e) {
      // On 401, try refreshing the token first before clearing
      try {
        final status = (e as dynamic).response?.statusCode as int?;
        if (status == 401 || status == 403) {
          // Try to refresh the token
          try {
            final refreshResp = await _api.refreshToken();
            if (refreshResp.data['token'] != null) {
              await _storage.write(key: 'jwt_token', value: refreshResp.data['token']);
              // Retry getMe with new token
              final resp = await _api.getMe();
              if (resp.data['success'] == true) {
                _user      = UserModel.fromJson(resp.data['data']);
                _isLoggedIn = true;
                notifyListeners();
                return;
              }
            }
          } catch (_) {
            // Refresh failed, clear tokens
          }
          await _storage.deleteAll();
        }
      } catch (_) {
        // ignore parsing errors and keep existing tokens
      }
    }
  }

  // ─── Login ───────────────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final resp = await _api.login(email, password);
      final data = resp.data['data'];
      await _saveTokens(data['token'], data['token']);
      _user       = UserModel.fromJson(data['user']);
      _isLoggedIn = true;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Register ────────────────────────────────────────────────────
  Future<bool> register(Map<String, dynamic> data) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final resp   = await _api.register(data);
      final rData  = resp.data['data'];
      await _saveTokens(rData['token'], rData['token']);
      _user       = UserModel.fromJson(rData['user']);
      _isLoggedIn = true;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Logout ──────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {}
    await _storage.deleteAll();
    _user       = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  // ─── Update profile ──────────────────────────────────────────────
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final resp = await _api.updateProfile(data);
      _user = UserModel.fromJson(resp.data['data']);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Forgot Password ──────────────────────────────────────────────
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _api.forgotPassword(email);
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Reset Password ──────────────────────────────────────────────
  Future<bool> resetPassword(String email, String token, String password, String passwordConfirmation) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _api.resetPassword(
        token: token,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Refresh user data ───────────────────────────────────────────
  Future<void> refreshUser() async {
    try {
      final resp = await _api.getMe();
      if (resp.data['success'] == true) {
        _user = UserModel.fromJson(resp.data['data']);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _saveTokens(String token, String refresh) async {
    await _storage.write(key: 'jwt_token',     value: token);
    await _storage.write(key: 'refresh_token', value: refresh);
  }

  void _setLoading(bool v) { _isLoading = v; notifyListeners(); }

  String _parseError(dynamic e) {
    try {
      final resp = (e as dynamic).response;
      if (resp?.data?['message'] != null) return resp.data['message'];
      if (resp?.data?['errors']  != null) {
        final errors = resp.data['errors'] as Map;
        return errors.values.first[0];
      }
    } catch (_) {}
    return 'Terjadi kesalahan. Coba lagi.';
  }
}
