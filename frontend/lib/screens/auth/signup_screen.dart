import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/user.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  UserRole _selectedRole = UserRole.consumer;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();

      if (name.isEmpty) {
        setState(() {
          _errorMessage = 'Nama lengkap tidak boleh kosong';
          _isLoading = false;
        });
        return;
      }

      if (phone.isEmpty) {
        setState(() {
          _errorMessage = 'Nomor telepon tidak boleh kosong';
          _isLoading = false;
        });
        return;
      }

      // Registration successful - navigate to main screen
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/main',
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal mendaftar: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Daftar Akun Baru',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Isi data dasar Anda untuk memulai pengalaman lokal.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Nama Lengkap',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _nameController,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: 'Masukkan nama lengkap',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Nomor Telepon',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 14, right: 10),
                      child: Text(
                        '+62',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 72),
                    hintText: '812-3456-7890',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                Text(
                  'Daftar Sebagai',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),
                _buildRoleOption(
                  role: UserRole.consumer,
                  icon: Icons.shopping_cart,
                  title: 'Konsumen',
                  description: 'Belanja produk lokal dalam satu aplikasi',
                ),
                const SizedBox(height: 12),
                _buildRoleOption(
                  role: UserRole.umkm,
                  icon: Icons.storefront,
                  title: 'UMKM',
                  description: 'Kelola toko dan produk lokal Anda',
                ),
                const SizedBox(height: 12),
                _buildRoleOption(
                  role: UserRole.producer,
                  icon: Icons.local_shipping,
                  title: 'Produsen',
                  description: 'Pasok produk ke UMKM dan mitra Anda',
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignup,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Daftar Sekarang'),
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Text(
                    'Setelah mendaftar, kami akan mengirimkan kode verifikasi ke nomor Anda.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 26),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.pushNamed(context, '/login');
                            },
                      child: const Text('Masuk'),
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

  Widget _buildRoleOption({
    required UserRole role,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: _isLoading ? null : () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.05) : Colors.white,
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.backgroundColor,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
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
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
