import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../widgets/common/custom_widgets.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (email.isEmpty) {
        setState(() => _errorMessage = 'Email tidak boleh kosong');
        return;
      }

      if (!RegExp(AppRegex.emailRegex).hasMatch(email)) {
        setState(() => _errorMessage = AppStrings.errorInvalidEmail);
        return;
      }

      if (password.isEmpty) {
        setState(() => _errorMessage = 'Password tidak boleh kosong');
        return;
      }

      final authResponse = await ref.read(authProvider.notifier).login(
            email: email,
            password: password,
          );

      if (mounted) {
        _navigateToHome(authResponse.user?.role);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Gagal masuk: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToHome(UserRole? role) {
    if (!mounted) return;

    final routeName = role == UserRole.umkm || role == UserRole.producer
        ? '/producer-home'
        : '/consumer-home';

    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppNumbers.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppNumbers.paddingXLarge),
                Text(
                  AppStrings.loginTitle,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.loginSubtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: AppNumbers.paddingXLarge),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: AppStrings.emailHint,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppNumbers.paddingLarge),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: AppStrings.passwordHint,
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onSuffixTap: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  textInputAction: TextInputAction.done,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(AppNumbers.paddingSmall),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withOpacity(0.1),
                      border: Border.all(color: AppTheme.errorColor),
                      borderRadius:
                          BorderRadius.circular(AppNumbers.smallBorderRadius),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppNumbers.paddingXLarge),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Text(AppStrings.btnLogin),
                  ),
                ),
                const SizedBox(height: AppNumbers.paddingLarge),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Belum punya akun? ',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/signup');
                      },
                      child: const Text('Daftar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
