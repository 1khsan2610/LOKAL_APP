import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/constants.dart';

class ApiService {
  late final Dio _dio;
  String? _accessToken;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        contentType: 'application/json',
        headers: {
          'Accept': 'application/json',
          'X-Client': 'flutter-mobile',
        },
      ),
    );

    // Add interceptor untuk logging dan error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  // Setter untuk tokens
  void setTokens(String accessToken, {String? refreshToken}) {
    _accessToken = accessToken;
  }

  void clearTokens() {
    _accessToken = null;
  }

  String? get accessToken => _accessToken;

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_accessToken != null) {
      options.headers['Authorization'] = 'Bearer $_accessToken';
    }
    if (kDebugMode) {
      print('🚀 API Request: ${options.method} ${options.path}');
      print('Headers: ${options.headers}');
      if (options.data != null) {
        print('Body: ${options.data}');
      }
    }
    handler.next(options);
  }

  Future<void> _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    if (kDebugMode) {
      print('✅ API Response: ${response.statusCode} ${response.requestOptions.path}');
      print('Response: ${response.data}');
    }
    handler.next(response);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    if (kDebugMode) {
      print('❌ API Error: ${error.message}');
      print('Error Response: ${error.response?.data}');
    }

    // Handle specific error codes
    if (error.response?.statusCode == 401) {
      // Token expired or unauthorized
      // Trigger re-login
    }

    handler.next(error);
  }

  // GET request
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) responseDecoder,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return responseDecoder(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) responseDecoder,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return responseDecoder(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH request
  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) responseDecoder,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return responseDecoder(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) responseDecoder,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return responseDecoder(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) responseDecoder,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return responseDecoder(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Upload file
  Future<T> uploadFile<T>(
    String path, {
    required String filePath,
    String fileKey = 'file',
    Map<String, dynamic>? additionalData,
    required T Function(dynamic) responseDecoder,
  }) async {
    try {
      final formData = FormData.fromMap({
        fileKey: await MultipartFile.fromFile(filePath),
        ...?additionalData,
      });

      final response = await _dio.post(
        path,
        data: formData,
      );
      return responseDecoder(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Handle errors
  ApiException _handleError(DioException error) {
    String message = 'Terjadi kesalahan';
    int statusCode = error.response?.statusCode ?? 0;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Koneksi timeout. Periksa jaringan Anda';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Server tidak merespons. Coba lagi nanti';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Gagal mengirim data. Periksa jaringan Anda';
        break;
      case DioExceptionType.badResponse:
        if (statusCode == 400) {
          final errorData = error.response?.data;
          if (errorData is Map && errorData['message'] != null) {
            message = errorData['message'];
          } else {
            message = 'Request tidak valid. Format data salah';
          }
        } else if (statusCode == 401) {
          message = 'Sesi Anda telah berakhir';
        } else if (statusCode == 403) {
          message = 'Anda tidak memiliki akses';
        } else if (statusCode == 404) {
          message = 'Endpoint tidak ditemukan. Backend tidak responsive';
        } else if (statusCode == 500) {
          final errorData = error.response?.data;
          if (errorData is Map && errorData['message'] != null) {
            message = 'Server error: ${errorData['message']}';
          } else {
            message = 'Kesalahan server. Hubungi support';
          }
        } else {
          message =
              error.response?.data['message'] ?? 'Terjadi kesalahan server (HTTP $statusCode)';
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request dibatalkan';
        break;
      case DioExceptionType.unknown:
        message = 'Kesalahan jaringan. Periksa koneksi internet Anda';
        break;
      default:
        message = 'Terjadi kesalahan yang tidak diketahui';
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      originalError: error,
    );
  }

  // ======================== AUTH ENDPOINTS ========================
  
  /// Request OTP untuk login
  Future<Map<String, dynamic>> requestOtp(String phone) async {
    try {
      return await post(
        '/auth/request-otp',
        data: {'phone_number': phone},
        responseDecoder: (data) {
          if (data is Map) {
            return Map<String, dynamic>.from(data);
          } else if (data is String) {
            return {'message': data};
          }
          return {};
        },
      );
    } on ApiException catch (e) {
      if (kDebugMode) {
        print('🔴 OTP Request Error: ${e.message}');
        print('Status Code: ${e.statusCode}');
      }
      rethrow;
    }
  }

  /// Verify OTP dan dapatkan token
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    final response = await post(
      '/auth/verify-otp',
      data: {
        'phone_number': phone,  // FIXED: Laravel expects phone_number
        'code': otp,             // FIXED: Laravel expects code (not otp)
        'name': 'User',          // Add name for new users
        'role': 'consumer',      // Default role
      },
      responseDecoder: (data) => data is Map ? Map<String, dynamic>.from(data) : {},
    );
    
    // Save token jika ada
    if (response['token'] != null) {
      setTokens(response['token']);
    }
    
    return Map<String, dynamic>.from(response);
  }

  /// Refresh token
  Future<Map<String, dynamic>> refreshToken() async {
    return post(
      '/auth/refresh',
      responseDecoder: (data) => data is Map ? Map<String, dynamic>.from(data) : {},
    );
  }

  /// Logout
  Future<void> logout() async {
    try {
      await post(
        '/auth/logout',
        responseDecoder: (data) => null,
      );
    } finally {
      clearTokens();
    }
  }

  // ======================== PRODUCT ENDPOINTS ========================
  
  /// Get all products (public)
  Future<List<dynamic>> getProducts({
    int page = 1,
    String? category,
    String? search,
  }) async {
    return get(
      '/products',
      queryParameters: {
        'page': page,
        if (category != null) 'category': category,
        if (search != null) 'search': search,
      },
      responseDecoder: (data) {
        if (data is Map && data['data'] is List) {
          return data['data'];
        }
        return [];
      },
    );
  }

  /// Get single product (public)
  Future<Map<String, dynamic>> getProduct(int productId) async {
    return get(
      '/products/$productId',
      responseDecoder: (data) => data is Map ? Map<String, dynamic>.from(data) : {},
    );
  }

  /// Get products by category (public)
  Future<List<dynamic>> getProductsByCategory(String category) async {
    return get(
      '/products/category/$category',
      responseDecoder: (data) {
        if (data is Map && data['data'] is List) {
          return data['data'];
        }
        return [];
      },
    );
  }

  /// Get products by UMKM (public)
  Future<List<dynamic>> getProductsByUmkm(int umkmId) async {
    return get(
      '/umkm/$umkmId/products',
      responseDecoder: (data) {
        if (data is Map && data['data'] is List) {
          return data['data'];
        }
        return [];
      },
    );
  }

  /// Create product (protected - UMKM only)
  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data) async {
    return post(
      '/products',
      data: data,
      responseDecoder: (response) => response is Map ? Map<String, dynamic>.from(response) : {},
    );
  }

  /// Update product (protected - UMKM only)
  Future<Map<String, dynamic>> updateProduct(int productId, Map<String, dynamic> data) async {
    return patch(
      '/products/$productId',
      data: data,
      responseDecoder: (response) => response is Map ? Map<String, dynamic>.from(response) : {},
    );
  }

  /// Delete product (protected - UMKM only)
  Future<void> deleteProduct(int productId) async {
    await delete(
      '/products/$productId',
      responseDecoder: (data) => null,
    );
  }

  // ======================== ORDER ENDPOINTS ========================
  
  /// Get all orders (protected)
  Future<List<dynamic>> getOrders() async {
    return get(
      '/orders',
      responseDecoder: (data) {
        if (data is Map && data['data'] is List) {
          return data['data'];
        }
        return [];
      },
    );
  }

  /// Get single order (protected)
  Future<Map<String, dynamic>> getOrder(int orderId) async {
    return get(
      '/orders/$orderId',
      responseDecoder: (data) => data is Map ? Map<String, dynamic>.from(data) : {},
    );
  }

  /// Create order (protected)
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> data) async {
    return post(
      '/orders',
      data: data,
      responseDecoder: (response) => response is Map ? Map<String, dynamic>.from(response) : {},
    );
  }

  /// Update order status (protected)
  Future<Map<String, dynamic>> updateOrderStatus(int orderId, String status) async {
    return patch(
      '/orders/$orderId/status',
      data: {'status': status},
      responseDecoder: (response) => response is Map ? Map<String, dynamic>.from(response) : {},
    );
  }

  /// Get UMKM orders (protected - UMKM only)
  Future<List<dynamic>> getUmkmOrders() async {
    return get(
      '/umkm/orders',
      responseDecoder: (data) {
        if (data is Map && data['data'] is List) {
          return data['data'];
        }
        return [];
      },
    );
  }

  // ======================== UMKM ENDPOINTS ========================
  
  /// Get all UMKMs (public)
  Future<List<dynamic>> getUmkms() async {
    return get(
      '/umkm',
      responseDecoder: (data) {
        if (data is Map && data['data'] is List) {
          return data['data'];
        }
        return [];
      },
    );
  }

  /// Get single UMKM (public)
  Future<Map<String, dynamic>> getUmkm(int umkmId) async {
    return get(
      '/umkm/$umkmId',
      responseDecoder: (data) => data is Map ? Map<String, dynamic>.from(data) : {},
    );
  }

  /// Get nearby UMKMs (public)
  Future<List<dynamic>> getNearbyUmkms({
    required double latitude,
    required double longitude,
    double radius = 5.0,
  }) async {
    return get(
      '/umkm/nearby',
      queryParameters: {
        'lat': latitude,
        'lng': longitude,
        'radius': radius,
      },
      responseDecoder: (data) {
        if (data is Map && data['data'] is List) {
          return data['data'];
        }
        return [];
      },
    );
  }

  /// Get UMKM analytics (protected - UMKM only)
  Future<Map<String, dynamic>> getUmkmAnalytics() async {
    return get(
      '/umkm/analytics/summary',
      responseDecoder: (data) => data is Map ? Map<String, dynamic>.from(data) : {},
    );
  }

  // ======================== REVIEW ENDPOINTS ========================
  
  /// Get product reviews (public)
  Future<List<dynamic>> getProductReviews(int productId) async {
    return get(
      '/products/$productId/reviews',
      responseDecoder: (data) {
        if (data is Map && data['data'] is List) {
          return data['data'];
        }
        return [];
      },
    );
  }

  /// Get UMKM reviews (public)
  Future<List<dynamic>> getUmkmReviews(int umkmId) async {
    return get(
      '/umkm/$umkmId/reviews',
      responseDecoder: (data) {
        if (data is Map && data['data'] is List) {
          return data['data'];
        }
        return [];
      },
    );
  }

  /// Create review (protected)
  Future<Map<String, dynamic>> createReview(Map<String, dynamic> data) async {
    return post(
      '/reviews',
      data: data,
      responseDecoder: (response) => response is Map ? Map<String, dynamic>.from(response) : {},
    );
  }

  // ======================== WALLET ENDPOINTS ========================
  
  /// Get wallet balance (protected)
  Future<Map<String, dynamic>> getWalletBalance() async {
    return get(
      '/wallet/balance',
      responseDecoder: (data) => data is Map ? Map<String, dynamic>.from(data) : {},
    );
  }

  /// Get wallet history (protected)
  Future<List<dynamic>> getWalletHistory() async {
    return get(
      '/wallet/history',
      responseDecoder: (data) {
        if (data is Map && data['data'] is List) {
          return data['data'];
        }
        return [];
      },
    );
  }

  /// Get expiring coins (protected)
  Future<List<dynamic>> getExpiringCoins() async {
    return get(
      '/wallet/expiring-coins',
      responseDecoder: (data) {
        if (data is Map && data['data'] is List) {
          return data['data'];
        }
        return [];
      },
    );
  }

  // ======================== PAYMENT ENDPOINTS ========================
  
  /// Get payment status (protected)
  Future<Map<String, dynamic>> getPaymentStatus(String paymentId) async {
    return get(
      '/payments/status',
      queryParameters: {'payment_id': paymentId},
      responseDecoder: (data) => data is Map ? Map<String, dynamic>.from(data) : {},
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final DioException? originalError;

  ApiException({
    required this.message,
    required this.statusCode,
    this.originalError,
  });

  @override
  String toString() => message;
}
