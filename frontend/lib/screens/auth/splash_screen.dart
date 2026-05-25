import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateBasedOnAuth();
  }

  Future<void> _navigateBasedOnAuth() async {
    // Minimal delay for smooth transition
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    try {
      // Check if user is already logged in by reading stored token
      final hasToken = await _checkStoredToken();

      if (!mounted) return;

      if (hasToken) {
        // User has a stored token, let the auth provider load the full user info
        // and navigate based on role
        _navigateWithAuth();
      } else {
        // No token found, go to login
        Navigator.pushReplacementNamed(context, '/phone-entry');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/phone-entry');
      }
    }
  }

  Future<bool> _checkStoredToken() async {
    try {
      // Quick check if token exists in storage
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey('access_token');
    } catch (e) {
      return false;
    }
  }

  void _navigateWithAuth() {
    try {
      final authState = ref.read(authProvider);

      authState.when(
        loading: () {
          // Still loading, wait a bit more
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted && !Navigator.canPop(context)) {
              Navigator.pushReplacementNamed(context, '/phone-entry');
            }
          });
        },
        data: (auth) {
          if (auth != null && mounted) {
            // User is logged in, navigate based on role
            final role = auth.user?.role.toString() ?? '';
            if (role.contains('admin')) {
              Navigator.pushReplacementNamed(context, '/admin-dashboard');
            } else if (role.contains('umkm') || role.contains('producer')) {
              Navigator.pushReplacementNamed(context, '/producer-home');
            } else {
              Navigator.pushReplacementNamed(context, '/consumer-home');
            }
          } else if (mounted) {
            Navigator.pushReplacementNamed(context, '/phone-entry');
          }
        },
        error: (error, stack) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/phone-entry');
          }
        },
      );
    } catch (e) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/phone-entry');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Icon(
                Icons.shopping_basket,
                size: 64,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'LOKAL',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ekonomi Lokal Dimulai di Sini',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
