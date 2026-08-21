import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart'; // Tambahan wajib untuk kIsWeb
import 'package:url_strategy/url_strategy.dart';

import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';
import 'screens/umkm/umkm_layout.dart';
import 'utils/app_theme.dart';
import 'utils/app_router_go.dart';
import 'services/notification_service.dart';
// Baris import 'firebase_options.dart' sengaja KITA HAPUS karena filenya belum ada

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const fallbackFirebaseOptions = FirebaseOptions(
    apiKey: "dummy_key_agar_tidak_crash",
    appId: "1:dummy:web:dummy",
    messagingSenderId: "12345",
    projectId: "dummy-project",
  );

  // Firebase init dibuat toleran agar Android tetap bisa berjalan
  // walaupun google-services.json belum tersedia.
  if (kIsWeb) {
    await Firebase.initializeApp(options: fallbackFirebaseOptions);
  } else {
    try {
      await Firebase.initializeApp();
    } catch (_) {
      await Firebase.initializeApp(options: fallbackFirebaseOptions);
    }
  }

  // Lock portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Local notifications init (Hanya untuk HP, di Web otomatis dilewati)
  if (!kIsWeb) {
    await NotificationService.initialize(flutterLocalNotificationsPlugin);
  }

  // Use path URL strategy on web to have clean URLs (no #)
  if (kIsWeb) setPathUrlStrategy();

  // Initialize AuthProvider early so routes loaded directly (e.g. /profile)
  // will have auth state available even when the app is reloaded.
  final authProvider = AuthProvider();
  await authProvider.init();

  runApp(EkonomiLokalApp(initialAuth: authProvider));
}

// Note: GoRouter handles initial location using Uri.base in `AppRouterGo`.

class EkonomiLokalApp extends StatelessWidget {
  final AuthProvider? initialAuth;
  const EkonomiLokalApp({super.key, this.initialAuth});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        if (initialAuth != null)
          ChangeNotifierProvider.value(value: initialAuth!),
        if (initialAuth == null)
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => UmkmProvider()),
      ],
      child: MaterialApp.router(
        title: 'EkonomiLokal',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouterGo.router,
      ),
    );
  }
}
