import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String? token;

  const ResetPasswordScreen({Key? key, this.token}) : super(key: key);

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  late TextEditingController _tokenController;
  late TextEditingController _passwordController;
  late TextEditingController _passwordConfirmController;
  bool _isPasswordVisible = false;
  bool _isPasswordConfirmVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController(text: widget.token ?? '');
    _passwordController = TextEditingController();
    _passwordConfirmController = TextEditingController();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  void _handleResetPassword() async {
    final token = _tokenController.text.trim();
    final password = _passwordController.text;
    final passwordConfirm = _passwordConfirmController.text;

    // Validation
    if (token.isEmpty) {
      _showError('Kode reset tidak boleh kosong');
      return;
    }

    if (password.isEmpty) {
      _showError('Password tidak boleh kosong');
      return;
    }

    if (password.length < 6) {
      _showError('Password minimal 6 karakter');
      return;
    }

    if (passwordConfirm.isEmpty) {
      _showError('Konfirmasi password tidak boleh kosong');
      return;
    }

    if (password != passwordConfirm) {
      _showError('Password tidak cocok');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authProvider.notifier).resetPassword(
            token: token,
            password: password,
            passwordConfirmation: passwordConfirm,
          );

      if (mounted) {
        // Show success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password berhasil direset. Silakan login kembali.'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to login
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          }
        });
      }
    } catch (e) {
      _showError(_getErrorMessage(e.toString()));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getErrorMessage(String error) {
    if (error.contains('expired') || error.contains('invalid')) {
      return 'Kode reset sudah kadaluwarsa atau tidak valid';
    } else if (error.contains('network')) {
      return 'Gagal terhubung ke server';
    } else if (error.contains('not cocok')) {
      return 'Password tidak cocok';
    }
    return 'Gagal mereset password. Silakan coba lagi.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Illustration
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '🔑',
                        style: TextStyle(fontSize: 48),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Header
                Text(
                  'Reset Password',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Masukkan kode reset dari email dan password baru Anda',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                ),

                const SizedBox(height: 36),

                // Token/Code Input
                if (widget.token == null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kode Reset',
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _tokenController,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          hintText: 'Masukkan kode dari email Anda',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          prefixIcon: Icon(
                            Icons.vpn_key,
                            color: AppTheme.primaryColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppTheme.primaryColor,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),

                // Password Input
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Password Baru',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: AppTheme.primaryColor,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () {
                            setState(
                              () =>
                                  _isPasswordVisible = !_isPasswordVisible,
                            );
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.primaryColor,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Password Confirmation Input
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Konfirmasi Password',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordConfirmController,
                      obscureText: !_isPasswordConfirmVisible,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: AppTheme.primaryColor,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordConfirmVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () {
                            setState(
                              () => _isPasswordConfirmVisible =
                                  !_isPasswordConfirmVisible,
                            );
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.primaryColor,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Password Strength Indicator
                _buildPasswordStrength(_passwordController.text),

                const SizedBox(height: 32),

                // Reset Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleResetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Reset Password',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // Back to Login Link
                Center(
                  child: TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: Text(
                      'Kembali',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordStrength(String password) {
    int strength = 0;
    if (password.length >= 6) strength++;
    if (password.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;

    Color strengthColor = Colors.red;
    String strengthText = 'Lemah';

    if (strength >= 5) {
      strengthColor = Colors.green;
      strengthText = 'Kuat';
    } else if (strength >= 3) {
      strengthColor = Colors.orange;
      strengthText = 'Sedang';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: strengthColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: strengthColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Kekuatan Password: $strengthText',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: strengthColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(
            width: 80,
            height: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: strength / 6,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
