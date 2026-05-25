import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_widgets.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState
    extends ConsumerState<OtpVerificationScreen> {
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  late Timer _timer;
  int _timeRemaining = AppConstants.otpDurationSeconds;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedRole = 'consumer';

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String _getOtpCode() {
    return _otpControllers.map((c) => c.text).join();
  }

  void _handleVerifyOtp() async {
    final otp = _getOtpCode();
    if (otp.length != 6) {
      setState(() => _errorMessage = 'Kode OTP harus 6 digit');
      return;
    }

    final phone = (ref.read(otpStateProvider)['phone'] ?? '').toString();
    print('DEBUG: Phone type = ${phone.runtimeType}, Phone value = $phone');

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      print('DEBUG: Calling verifyOtp with phone=$phone, otp=$otp, role=$_selectedRole');
      await ref.read(authProvider.notifier).verifyOtp(
        phoneNumber: phone,
        otp: otp,
        role: _selectedRole,
      );

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/main',
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _errorMessage = 'Kode OTP tidak valid: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleResendOtp() async {
    final phone = (ref.read(otpStateProvider)['phone'] ?? '').toString();
    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).requestOtp(phone);
      setState(() {
        _timeRemaining = AppConstants.otpDurationSeconds;
        _errorMessage = null;
      });
      _startTimer();

      for (var controller in _otpControllers) {
        controller.clear();
      }
    } catch (e) {
      setState(() => _errorMessage = 'Gagal mengirim ulang OTP: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final phone = ref.watch(otpStateProvider)['phone'] ?? '';

    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.otpTitle,
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppNumbers.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subtitle
                Text(
                  AppStrings.otpSubtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: AppNumbers.paddingLarge),

                // Phone Display
                Container(
                  padding: const EdgeInsets.all(AppNumbers.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withOpacity(0.1),
                    border: Border.all(color: AppTheme.primaryLight),
                    borderRadius:
                        BorderRadius.circular(AppNumbers.smallBorderRadius),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.phone,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        phone,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppNumbers.paddingXLarge),

                // OTP Input
                Text(
                  'Kode Verifikasi',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    6,
                    (index) => SizedBox(
                      width: 50,
                      child: TextField(
                        controller: _otpControllers[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppNumbers.smallBorderRadius),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            FocusScope.of(context).nextFocus();
                          }
                        },
                      ),
                    ),
                  ),
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

                const SizedBox(height: AppNumbers.paddingLarge),

                // Timer
                Center(
                  child: Column(
                    children: [
                      Text(
                        '${AppStrings.otpExpiredIn}:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(_timeRemaining),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: _timeRemaining < 60
                              ? AppTheme.warningColor
                              : AppTheme.primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppNumbers.paddingXLarge),

                // Role Selection
                Text(
                  'Saya adalah',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('Konsumen'),
                      value: 'consumer',
                      groupValue: _selectedRole,
                      onChanged: (value) =>
                          setState(() => _selectedRole = value ?? 'consumer'),
                    ),
                    RadioListTile<String>(
                      title: const Text('UMKM/Penjual'),
                      value: 'umkm',
                      groupValue: _selectedRole,
                      onChanged: (value) =>
                          setState(() => _selectedRole = value ?? 'consumer'),
                    ),
                    RadioListTile<String>(
                      title: const Text('Produsen'),
                      value: 'producer',
                      groupValue: _selectedRole,
                      onChanged: (value) =>
                          setState(() => _selectedRole = value ?? 'consumer'),
                    ),
                  ],
                ),

                const SizedBox(height: AppNumbers.paddingXLarge),

                // Verify Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleVerifyOtp,
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
                        : Text(AppStrings.verifyOtp),
                  ),
                ),

                const SizedBox(height: 12),

                // Resend OTP
                Center(
                  child: GestureDetector(
                    onTap: _timeRemaining <= 0 ? _handleResendOtp : null,
                    child: Text(
                      AppStrings.resendOtp,
                      style: TextStyle(
                        color: _timeRemaining <= 0
                            ? AppTheme.primaryColor
                            : AppTheme.textHint,
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
}
