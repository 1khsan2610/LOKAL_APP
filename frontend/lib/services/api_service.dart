import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiService {
  // Read API base from compile-time environment. Support both
  // `API_BASE_URL` (preferred) and `BASE_URL` (legacy/typo) for
  // compatibility with existing run scripts.
  static final String baseUrl = (() {
    const apiEnv = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    const altEnv = String.fromEnvironment('BASE_URL', defaultValue: '');
    // Default ke localhost:8000 agar kompatibel dengan php artisan serve --port=8000
    // Override dengan --dart-define=API_BASE_URL=http://domain-anda.test/api saat build
    final resolved = apiEnv.isNotEmpty ? apiEnv : (altEnv.isNotEmpty ? altEnv : 'http://127.0.0.1:8000/api');
    // Ensure no trailing slash to keep endpoint concatenation consistent
    return resolved.endsWith('/') ? resolved.substring(0, resolved.length - 1) : resolved;
  })();

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
        // Removed 'Content-Type': 'application/json' - Dio handles it intelligently
      },
    ));

    _dio.interceptors.addAll([
      _AuthInterceptor(_storage, _dio),
      PrettyDioLogger(
        requestHeader: false,
        requestBody: true,
        responseBody: true,
        error: true,
        compact: true,
      ),
    ]);
  }

  Dio get dio => _dio;

  // ── Auth ────────────────────────────────────────────────────────
  Future<Response> login(String email, String password) =>
      _dio.post('/auth/login', data: {'email': email, 'password': password});

  Future<Response> register(Map<String, dynamic> data) =>
      _dio.post('/auth/register-account', data: data);

  Future<Response> logout() => _dio.post('/auth/logout');

  Future<Response> forgotPassword(String email) =>
      _dio.post('/auth/forgot-password', data: {'email': email});

  Future<Response> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) =>
      _dio.post('/auth/reset-password', data: {
        'token': token,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

  Future<Response> verifyEmail({required int id, required String hash}) =>
      _dio.post('/auth/verify-email', data: {'id': id, 'hash': hash});

  Future<Response> getMe() => _dio.get('/auth/me');

  Future<Response> refreshToken() => _dio.post('/auth/refresh');

  // ── My Products (UMKM own) ─────────────────────────────────────
  Future<Response> getMyProducts({int page = 1, int perPage = 50}) =>
      _dio.get('/umkm/products', queryParameters: {
        'page': page,
        'per_page': perPage,
      });

  // ── Products ────────────────────────────────────────────────────
  Future<Response> getProducts({
    String? category,
    String? sort,
    int? minPrice,
    int? maxPrice,
    int page = 1,
    int perPage = 20,
  }) => _dio.get('/products', queryParameters: {
    if (category != null) 'category': category,
    if (sort != null) 'sort': sort,
    if (minPrice != null) 'min_price': minPrice,
    if (maxPrice != null) 'max_price': maxPrice,
    'page': page,
    'per_page': perPage,
  });

  Future<Response> searchProducts(String q, {int page = 1, int? umkmId}) =>
      _dio.get('/products/search', queryParameters: {
        'q': q,
        'page': page,
        if (umkmId != null) 'umkm_id': umkmId,
      });

  Future<Response> getFlashSale() => _dio.get('/products/flash-sale');

  Future<Response> getProductDetail(int id) => _dio.get('/products/$id');

  Future<Response> getProductReviews(int id, {int page = 1}) =>
      _dio.get('/products/$id/reviews', queryParameters: {'page': page});

  // ── UMKM ────────────────────────────────────────────────────────
  Future<Response> getUmkmList({int page = 1}) =>
      _dio.get('/umkm', queryParameters: {'page': page});

  Future<Response> getNearbyUmkm(double lat, double lng, {double radius = 5}) =>
      _dio.get('/umkm/nearby', queryParameters: {'lat': lat, 'lng': lng, 'radius': radius});

  Future<Response> getUmkmDetail(int id) => _dio.get('/umkm/$id');

  Future<Response> getMyStore() => _dio.get('/umkm/my-store');
  Future<Response> getUmkmAnalytics() => _dio.get('/umkm/analytics/summary');
  Future<Response> getUmkmOrders({String? status}) => _dio.get('/umkm/orders', queryParameters: status != null ? {'status': status} : null);
  Future<Response> updateUmkmOrderStatus(int id, Map<String, dynamic> data) => _dio.patch('/umkm/orders/$id/status', data: data);
  Future<Response> updateMyStore(Map<String, dynamic> data) => _dio.put('/umkm/my-store', data: data);

  // ── Cart ────────────────────────────────────────────────────────
  Future<Response> getCart() => _dio.get('/cart');

  Future<Response> addToCart(int productId, int quantity, {int? variantId}) =>
      _dio.post('/cart', data: {
        'product_id': productId,
        'quantity': quantity,
        if (variantId != null) 'variant_id': variantId,
      });

  Future<Response> updateCartItem(int itemId, int quantity) =>
      _dio.put('/cart/$itemId', data: {'quantity': quantity});

  Future<Response> removeCartItem(int itemId) => _dio.delete('/cart/$itemId');

  Future<Response> clearCart() => _dio.delete('/cart');

  // ── Orders ──────────────────────────────────────────────────────
  Future<Response> getOrders({String? status, int page = 1}) =>
      _dio.get('/orders', queryParameters: {
        if (status != null) 'status': status,
        'page': page,
      });

  Future<Response> createOrder(Map<String, dynamic> data) =>
      _dio.post('/orders', data: data);

  Future<Response> getOrderDetail(int id) => _dio.get('/orders/$id');

  Future<Response> cancelOrder(int id) => _dio.patch('/orders/$id/cancel');

  Future<Response> confirmReceived(int id) =>
      _dio.patch('/orders/$id/confirm-received');

  // ✨ TAMBAHAN UNTUK LANGKAH 4: Mengambil riwayat tracking log dari backend
  Future<Response> getOrderTracking(int orderId) =>
      _dio.get('/orders/$orderId/tracking');

  // ── Payment ─────────────────────────────────────────────────────
  Future<Response> createPayment(int orderId, {required String paymentMethod}) =>
      _dio.post('/payment/create',
          data: jsonEncode({
            'order_id': orderId,
            'payment_method': paymentMethod,
            'payment_type': paymentMethod,
          }),
          options: Options(headers: {'Content-Type': 'application/json'}),
          queryParameters: {
            'order_id': orderId,
            'payment_method': paymentMethod,
            'payment_type': paymentMethod,
          });

  Future<Response> getPaymentStatus(int orderId) =>
      _dio.get('/payment/status/$orderId');

  // ── Wallet ──────────────────────────────────────────────────────
  Future<Response> getWallet() => _dio.get('/wallet');

  Future<Response> getCoinTransactions({int page = 1}) =>
      _dio.get('/wallet/transactions', queryParameters: {'page': page});

  Future<Response> redeemCoin(int amount) =>
      _dio.post('/wallet/redeem', data: {'amount': amount});

  // ── Addresses ───────────────────────────────────────────────────
  Future<Response> getAddresses() => _dio.get('/addresses');

  Future<Response> createAddress(Map<String, dynamic> data) =>
      _dio.post('/addresses', data: data);

  Future<Response> updateAddress(int id, Map<String, dynamic> data) =>
      _dio.put('/addresses/$id', data: data);

  Future<Response> deleteAddress(int id) => _dio.delete('/addresses/$id');

  Future<Response> setDefaultAddress(int id) =>
      _dio.patch('/addresses/$id/set-default');

  // ── Profile ─────────────────────────────────────────────────────
  Future<Response> getProfile() => _dio.get('/profile');

  Future<Response> updateProfile(Map<String, dynamic> data) =>
      _dio.put('/profile', data: data);

  Future<Response> uploadAvatar(XFile file) async {
    final bytes = await file.readAsBytes();
    final formData = FormData.fromMap({
      'avatar': MultipartFile.fromBytes(bytes, filename: file.name),
    });
    return _dio.post('/profile/avatar', data: formData);
  }

  Future<Response> changePassword(String oldPass, String newPass) =>
      _dio.put('/profile/change-password', data: {
        'current_password': oldPass,
        'password': newPass,
        'password_confirmation': newPass,
      });

  // ── Notifications ───────────────────────────────────────────────
  Future<Response> getNotifications({int page = 1}) =>
      _dio.get('/notifications', queryParameters: {'page': page});

  Future<Response> markNotificationRead(int id) =>
      _dio.patch('/notifications/$id/read');

  Future<Response> markAllNotificationsRead() =>
      _dio.patch('/notifications/read-all');

  Future<Response> registerDeviceToken(String token, String platform) =>
      _dio.post('/notifications/register-device', data: {
        'token': token,
        'platform': platform,
      });

  // ── AI Chat ─────────────────────────────────────────────────────
  Future<Response> aiChat(String message, {List<Map<String, dynamic>>? history}) =>
      _dio.post('/ai/chat', data: {
        'message': message,
        if (history != null) 'history': history,
      });

  // ── Reviews ─────────────────────────────────────────────────────
  Future<Response> getMyReviews() => _dio.get('/reviews/me');

  Future<Response> createReview(Map<String, dynamic> data) =>
      _dio.post('/reviews', data: data);

  Future<Response> updateReview(int id, Map<String, dynamic> data) =>
      _dio.put('/reviews/$id', data: data);

  Future<Response> deleteReview(int id) => _dio.delete('/reviews/$id');

  // 1. PERBAIKAN UNTUK TAMBAH PRODUK (Teks + Gambar sekaligus)
  Future<Response> createProduct(Map<String, dynamic> data) async {
    if (data.containsKey('images') && data['images'] is List) {
      final List<XFile> files = List<XFile>.from(data['images']);
      final formData = FormData.fromMap({
        ...data..remove('images'), 
      });

      for (final file in files) {
        final bytes = await file.readAsBytes();
        formData.files.add(MapEntry(
          'images[]', // Gunakan array key biar terbaca Laravel
          MultipartFile.fromBytes(bytes, filename: file.name),
        ));
      }
      return _dio.post('/umkm/products', data: formData);
    }
    return _dio.post('/umkm/products', data: data);
  }

  // 2. PERBAIKAN UNTUK UPDATE PRODUK (Metode POST + Spoofing PUT)
  Future<Response> updateProduct(int id, Map<String, dynamic> data) async {
    if (data.containsKey('images') && data['images'] is List) {
      final List<XFile> files = List<XFile>.from(data['images']);
      final formData = FormData.fromMap({
        ...data..remove('images'),
        '_method': 'PUT', // Wajib untuk upload multipart via PUT di Laravel
      });

      for (final file in files) {
        final bytes = await file.readAsBytes();
        formData.files.add(MapEntry(
          'images[]',
          MultipartFile.fromBytes(bytes, filename: file.name),
        ));
      }
      return _dio.post('/umkm/products/$id', data: formData);
    }
    return _dio.put('/umkm/products/$id', data: data);
  }

  Future<Response> deleteProduct(int id) => _dio.delete('/umkm/products/$id');
  Future<Response> getMyProductDetail(int id) => _dio.get('/umkm/products/$id');
  Future<Response> deleteProductImage(int productId, int imageId) => _dio.delete('/umkm/products/$productId/images/$imageId');

  // ── Bank Account (UMKM) ──────────────────────────────────────────
  Future<Response> getBankAccount() => _dio.get('/umkm/bank-account');

  Future<Response> saveBankAccount(Map<String, dynamic> data) =>
      _dio.post('/umkm/bank-account', data: data);

  // 3. PERBAIKAN UNTUK UPLOAD GAMBAR TERPISAH
  Future<Response> uploadProductImages(int productId, List<XFile> files) async {
    final formData = FormData();
    for (final file in files) {
      final bytes = await file.readAsBytes();
      formData.files.add(MapEntry(
        'images[]', // Diubah menjadi images[]
        MultipartFile.fromBytes(bytes, filename: file.name),
      ));
    }
    return _dio.post('/umkm/products/$productId/images', data: formData);
  }

  // ── Admin ───────────────────────────────────────────────────────
  Future<Response> getAdminDashboard() => _dio.get('/admin/dashboard');

  Future<Response> getAdminUsers({int page = 1}) =>
      _dio.get('/admin/users', queryParameters: {'page': page});

  Future<Response> toggleUserStatus(int id) =>
      _dio.patch('/admin/users/$id/status');

  Future<Response> getAdminUmkm({int page = 1}) =>
      _dio.get('/admin/umkm', queryParameters: {'page': page});

  Future<Response> verifyUmkm(int id) => _dio.patch('/admin/umkm/$id/verify');

  Future<Response> getAdminOrders({int page = 1}) =>
      _dio.get('/admin/orders', queryParameters: {'page': page});

  Future<Response> getAdminTransactions({int page = 1}) =>
      _dio.get('/admin/transactions', queryParameters: {'page': page});

  Future<Response> getAdminAnalytics() => _dio.get('/admin/analytics');

  Future<Response> approveProduct(int id) =>
      _dio.post('/admin/products/$id/approve');

  Future<Response> deleteProductAdmin(int id) =>
      _dio.delete('/admin/products/$id');

  Future<Response> broadcastNotification({
    required String title,
    required String body,
    String? role,
  }) =>
      _dio.post('/admin/notifications/broadcast', data: {
        'title': title,
        'body': body,
        if (role != null) 'role': role,
      });
}

// ─── Auth Interceptor ──────────────────────────────────────────────
class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final Dio _dio;
  bool _isRefreshing = false;

  _AuthInterceptor(this._storage, this._dio);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = await _storage.read(key: 'refresh_token');
        if (refreshToken != null) {
          // Use a clean Dio instance without interceptors to avoid infinite loop
          final cleanDio = Dio(BaseOptions(
            baseUrl: _dio.options.baseUrl,
            headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
          ));
          cleanDio.options.headers['Authorization'] = 'Bearer $refreshToken';
          final resp = await cleanDio.post('/auth/refresh');
          final newToken = resp.data['token'] as String?;
          if (newToken != null) {
            await _storage.write(key: 'jwt_token', value: newToken);

            err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            final retryResp = await _dio.fetch(err.requestOptions);
            return handler.resolve(retryResp);
          }
        }
      } catch (_) {
        // refresh failed
      } finally {
        _isRefreshing = false;
      }
      await _storage.deleteAll();
    }
    return handler.next(err);
  }
}