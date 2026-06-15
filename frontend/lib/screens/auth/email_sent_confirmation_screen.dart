import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'reset_password_screen.dart';

class EmailSentConfirmationScreen extends StatefulWidget {
  final String email;

  const EmailSentConfirmationScreen({
    super.key,
    required this.email,
  });

  @override
  State<EmailSentConfirmationScreen> createState() =>
      _EmailSentConfirmationScreenState();
}

class _EmailSentConfirmationScreenState extends State<EmailSentConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final name = parts[0];
    final domain = parts[1];

    final visibleChars = (name.length / 2).ceil();
    final masked = '${name.substring(0, visibleChars)}${'*' * (name.length - visibleChars)}@$domain';

    return masked;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // Animated Success Icon
                  Center(
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.check_circle,
                            size: 80,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Header
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Email Terkirim!',
                          style:
                              Theme.of(context).textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Kami telah mengirimkan link reset password ke email Anda',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Email Display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.shade200,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.mail_outline,
                          size: 32,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _maskEmail(widget.email),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Steps
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Langkah berikutnya:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _buildStep(
                        context,
                        number: '1',
                        title: 'Buka Email Anda',
                        description:
                            'Periksa inbox atau folder spam untuk email dari kami',
                      ),
                      const SizedBox(height: 16),
                      _buildStep(
                        context,
                        number: '2',
                        title: 'Klik Link Reset',
                        description: 'Klik link di email untuk reset password',
                      ),
                      const SizedBox(height: 16),
                      _buildStep(
                        context,
                        number: '3',
                        title: 'Buat Password Baru',
                        description:
                            'Masukkan password baru yang kuat dan aman',
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Open Email Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement open email app
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Membuka aplikasi email...'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.mail_outline, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'Buka Aplikasi Email',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // I Have Reset Code Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ResetPasswordScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Saya Sudah Punya Kode Reset',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Back to Login Link
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      },
                      child: Text(
                        'Kembali ke Login',
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
      ),
    );
  }

  Widget _buildStep(
    BuildContext context, {
    required String number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
