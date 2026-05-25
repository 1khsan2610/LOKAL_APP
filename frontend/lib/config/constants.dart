/// Configuration constants for Platform LOKAL
class AppConstants {
  // API Configuration
  // Laravel local: http://127.0.0.1:8000/api/v1
  // Android emulator: http://10.0.2.2:8000/api/v1
  // iOS simulator: http://localhost:8000/api/v1
  // Physical device: http://192.168.x.x:8000/api/v1 (gunakan IP lokal machine)
  static const String apiBaseUrl = 'http://127.0.0.1:8000/api/v1';
  static const String apiBaseUrlProduction = 'https://api.lokal.id/api/v1';
  static const String apiTimeout = '30000'; // milliseconds
  
  // App Info
  static const String appName = 'LOKAL';
  static const String appVersion = '1.1.0';
  
  // Location
  static const double defaultSearchRadius = 5.0; // km
  static const double minSearchRadius = 0.5; // km
  static const double maxSearchRadius = 10.0; // km
  
  // Pagination
  static const int productsPerPage = 20;
  static const int ordersPerPage = 15;
  
  // Lokal Coin
  static const double maxCoinPercentage = 0.20; // 20%
  static const double coinRewardPercentage = 0.02; // 2%
  static const int coinExpiryDays = 180; // 6 months
  static const int reviewCoinReward = 5;
  static const int newUserCoinBonus = 50;
  
  // OTP
  static const int otpDurationSeconds = 300; // 5 minutes
  static const int otpResendDelay = 60; // 1 minute
  static const int maxOtpAttempts = 5;
  static const int otpBlockDuration = 900; // 15 minutes
  
  // Product
  static const int maxProductImages = 5;
  static const int maxImageSizeMB = 2;
  static const int lowStockThreshold = 10;
  
  // Checkout
  static const int paymentLinkExpiryMinutes = 30;
  
  // Photos
  static const String placeholderImageUrl =
      'https://via.placeholder.com/400x300?text=LOKAL';
}

class AppStrings {
  // App Titles
  static const String appName = 'LOKAL';
  static const String appTagline = 'Ekonomi Lokal Dimulai di Sini';
  
  // Navigation
  static const String navHome = 'Beranda';
  static const String navMarketMap = 'Peta Pasar';
  static const String navCart = 'Keranjang';
  static const String navWallet = 'Dompet';
  static const String navProfile = 'Profil';
  
  // Authentication
  static const String loginTitle = 'Masuk ke LOKAL';
  static const String loginSubtitle = 'Masukkan nomor telepon Anda';
  static const String phoneHint = '08xxxxxxxxxx';
  static const String otpTitle = 'Verifikasi OTP';
  static const String otpSubtitle = 'Kami telah mengirim kode 6 digit ke nomor Anda';
  static const String otpHint = '000000';
  static const String verifyOtp = 'Verifikasi';
  static const String resendOtp = 'Kirim Ulang';
  static const String otpExpiredIn = 'Kode berlaku dalam';
  
  // Roles
  static const String roleConsumer = 'Konsumen';
  static const String roleUmkm = 'UMKM';
  static const String roleProducer = 'Produsen';
  
  // Buttons
  static const String btnLogin = 'Masuk';
  static const String btnRegister = 'Daftar';
  static const String btnContinue = 'Lanjutkan';
  static const String btnSubmit = 'Kirim';
  static const String btnCancel = 'Batal';
  static const String btnSave = 'Simpan';
  static const String btnDelete = 'Hapus';
  static const String btnEdit = 'Edit';
  static const String btnLogout = 'Keluar';
  static const String btnAddToCart = 'Tambah ke Keranjang';
  static const String btnCheckout = 'Checkout';
  static const String btnViewDetails = 'Lihat Detail';
  static const String btnAddProduct = 'Tambah Produk';
  
  // Validation
  static const String errorInvalidPhone = 'Nomor telepon tidak valid';
  static const String errorInvalidOtp = 'Kode OTP tidak valid';
  static const String errorOtpExpired = 'Kode OTP sudah kadaluwarsa';
  static const String errorMaxOtpAttempts = 'Terlalu banyak percobaan. Coba lagi nanti';
  static const String errorNetworkError = 'Kesalahan jaringan. Silakan coba lagi';
  static const String errorServerError = 'Kesalahan server. Silakan coba lagi nanti';
  static const String errorUnauthorized = 'Sesi Anda telah berakhir. Silakan login kembali';
  
  // Success Messages
  static const String successOtpSent = 'Kode OTP telah dikirim ke nomor Anda';
  static const String successLoginSuccess = 'Login berhasil';
  static const String successProductAdded = 'Produk berhasil ditambahkan';
  static const String successProfileUpdated = 'Profil berhasil diperbarui';
  
  // General
  static const String search = 'Cari';
  static const String filter = 'Filter';
  static const String sort = 'Urutkan';
  static const String noResults = 'Tidak ada hasil';
  static const String noData = 'Tidak ada data';
  static const String loading = 'Memuat...';
  static const String error = 'Terjadi kesalahan';
  static const String retry = 'Coba Lagi';
}

class AppRegex {
  static const String phoneRegex = r'^(?:[+0]9)?[0-9]{10,15}$';
  static const String emailRegex =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String urlRegex =
      r'^https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&//=]*)$';
}

class AppDurations {
  static const Duration shortDuration = Duration(milliseconds: 300);
  static const Duration mediumDuration = Duration(milliseconds: 500);
  static const Duration longDuration = Duration(seconds: 1);
  
  static const int snackbarDuration = 2; // seconds
  static const int toastDuration = 3; // seconds
}

class AppNumbers {
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;
  
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;
}
