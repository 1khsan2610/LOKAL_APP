import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../widgets/common/custom_widgets.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleRequestOtp() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final phone = _phoneController.text.trim();
      if (phone.isEmpty) {
        setState(() => _errorMessage = 'Nomor telepon tidak boleh kosong');
        return;
      }

      if (!RegExp(AppRegex.phoneRegex).hasMatch(phone)) {
        setState(() => _errorMessage = AppStrings.errorInvalidPhone);
        return;
      }

      await ref.read(authProvider.notifier).requestOtp(phone);

      // Update OTP state
      ref.read(otpStateProvider.notifier).state = {
        'phone': phone.toString(),
        'otpSent': true,
        'timeRemaining': 300,
      };

      if (mounted) {
        Navigator.pushNamed(
          context,
          '/otp-verification',
          arguments: {'phone': phone},
        );
      }
    } catch (e) {
      setState(() => _errorMessage = 'Gagal mengirim OTP: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                // Header
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

                // Phone Input
                CustomTextField(
                  controller: _phoneController,
                  label: AppStrings.loginSubtitle,
                  hint: AppStrings.phoneHint,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone),
                  textInputAction: TextInputAction.done,
                ),

                // Error Message
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

                // Request OTP Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRequestOtp,
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                        : Text(AppStrings.btnContinue),
                  ),
                ),

                const SizedBox(height: AppNumbers.paddingLarge),

                // Info Box
                Container(
                  padding: const EdgeInsets.all(AppNumbers.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withOpacity(0.1),
                    border: Border.all(color: AppTheme.primaryLight),
                    borderRadius:
                        BorderRadius.circular(AppNumbers.smallBorderRadius),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tips Keamanan',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Gunakan nomor HP yang aktif\n'
                        '• Jangan bagikan kode OTP ke siapapun\n'
                        '• LOKAL tidak akan pernah meminta password',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
