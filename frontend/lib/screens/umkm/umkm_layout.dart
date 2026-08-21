import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/responsive_helper.dart';

/// Provider state untuk UMKM Merchant Center
class UmkmProvider extends ChangeNotifier {
  int _unreadChats = 0;
  int _newOrders = 0;
  String _storeName = 'Toko UMKM';
  String _storeLevel = 'Silver Merchant';
  String? _storeLogo;
  double _cashBalance = 0;
  double _coinBalance = 0;

  int get unreadChats => _unreadChats;
  int get newOrders => _newOrders;
  String get storeName => _storeName;
  String get storeLevel => _storeLevel;
  String? get storeLogo => _storeLogo;
  double get cashBalance => _cashBalance;
  double get coinBalance => _coinBalance;

  void updateBadges({int? unreadChats, int? newOrders}) {
    if (unreadChats != null) _unreadChats = unreadChats;
    if (newOrders != null) _newOrders = newOrders;
    notifyListeners();
  }

  void updateStoreInfo({String? name, String? level, String? logo}) {
    if (name != null) _storeName = name;
    if (level != null) _storeLevel = level;
    if (logo != null) _storeLogo = logo;
    notifyListeners();
  }

  void updateBalances({double? cash, double? coin}) {
    if (cash != null) _cashBalance = cash;
    if (coin != null) _coinBalance = coin;
    notifyListeners();
  }

  Future<void> refreshAll() async {
    try {
      final api = ApiService();
      // Load store info
      final storeResp = await api.getMyStore();
      final store = storeResp.data['data'];
      _storeName = store['name'] ?? 'Toko UMKM';
      notifyListeners();

      // Load wallet
      final walletResp = await api.getWallet();
      final wallet = walletResp.data['data'];
      _cashBalance = (wallet['cash_balance'] ?? 0).toDouble();
      _coinBalance = (wallet['coin_balance'] ?? 0).toDouble();
      notifyListeners();

      // Load badges
      final ordersResp = await api.getUmkmOrders(status: 'pending');
      final pendingOrders = (ordersResp.data['data']['data'] as List?) ?? [];
      _newOrders = pendingOrders.length;
      notifyListeners();
    } catch (_) {}
  }
}

/// Layout Utama Merchant Center dengan Sidebar Navigasi & Dropdown Profil
class UmkmLayout extends StatefulWidget {
  final Widget child;
  final String currentRoute;

  const UmkmLayout({
    super.key,
    required this.child,
    this.currentRoute = '/umkm/dashboard',
  });

  @override
  State<UmkmLayout> createState() => _UmkmLayoutState();
}

class _UmkmLayoutState extends State<UmkmLayout> {
  final _searchController = TextEditingController();
  bool _showMobileSearch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UmkmProvider>().refreshAll();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final provider = context.watch<UmkmProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      // ── Mobile: EndDrawer ───────────────────────────────────────
      endDrawer: isMobile ? _buildSidebar(context, provider, isMobile: true) : null,
      // ── Floating Action Button AI (Mobile) ─────────────────────
      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: () => context.push('/umkm/ai-assistant'),
              backgroundColor: const Color(0xFF1D4ED8),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
            )
          : null,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Desktop: Sidebar Fixed ─────────────────────────────
            if (!isMobile)
              _buildSidebar(context, provider, isMobile: false),

            // ── Main Content Area ──────────────────────────────────
            Expanded(
              child: Column(
                children: [
                  // ── Top Bar ──────────────────────────────────────
                  _buildTopBar(context, provider, isMobile),
                  // ── Page Content ─────────────────────────────────
                  Expanded(
                    child: widget.child,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ── SIDEBAR ─────────────────────────────────────────────────────────
  Widget _buildSidebar(BuildContext context, UmkmProvider provider, {required bool isMobile}) {
    final menuItems = _getMenuItems(provider);
    final width = isMobile ? null : 280.0;

    Widget sidebar = Container(
      width: width,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: AppTheme.cardBorder),
        ),
      ),
      child: Column(
        children: [
          // ── Logo & Platform Name ────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.cardBorder),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0A2540), Color(0xFF1966D2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'M',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mitra Mandiri',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Merchant Center',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Menu Items ──────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: menuItems.map((item) {
                final isActive = widget.currentRoute == item['route'];
                return _SidebarMenuItem(
                  icon: item['icon'] as IconData,
                  label: item['label'] as String,
                  route: item['route'] as String,
                  badge: item['badge'] as int?,
                  isActive: isActive,
                  isMobile: isMobile,
                  onTap: () {
                    if (isMobile) Navigator.pop(context);
                    if (item['route'] as String == '__logout__') {
                      _handleLogout(context);
                    } else {
                      context.go(item['route'] as String);
                    }
                  },
                );
              }).toList(),
            ),
          ),

          // ── Add Product Button (Sticky Bottom) ─────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (isMobile) Navigator.pop(context);
                  context.push('/umkm/products/form');
                },
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text(
                  'Tambah Produk Baru',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D4ED8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: const Color(0xFF1D4ED8).withValues(alpha: 0.3),
                ),
              ),
            ),
          ),

          // ── Profile Card (Sidebar Bawah) ────────────────────────
          PopupMenuButton<String>(
            offset: const Offset(0, -200),
            tooltip: 'Menu Profil',
            onSelected: (String value) => _handleProfileMenu(context, value),
            itemBuilder: (BuildContext ctx) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings_outlined),
                  title: Text('Pengaturan Toko'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'security',
                child: ListTile(
                  leading: Icon(Icons.lock_outline),
                  title: Text('Keamanan & Reset Password'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Keluar (Logout)', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppTheme.cardBorder),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppTheme.primary,
                    child: Text(
                      provider.storeName.isNotEmpty
                          ? provider.storeName[0].toUpperCase()
                          : 'T',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.storeName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E8FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            provider.storeLevel,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF8E24AA),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.expand_more, size: 18, color: AppTheme.textHint),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (isMobile) {
      return Drawer(
        child: SafeArea(
          child: sidebar,
        ),
      );
    }

    return sidebar;
  }

  List<Map<String, dynamic>> _getMenuItems(UmkmProvider provider) {
    return [
      {
        'icon': Icons.dashboard_outlined,
        'label': 'Dashboard',
        'route': '/umkm/dashboard',
        'badge': null,
      },
      {
        'icon': Icons.chat_bubble_outline_rounded,
        'label': 'Pesan',
        'route': '/umkm/chat',
        'badge': provider.unreadChats > 0 ? provider.unreadChats : null,
      },
      {
        'icon': Icons.receipt_long_outlined,
        'label': 'Pesanan',
        'route': '/umkm/orders',
        'badge': provider.newOrders > 0 ? provider.newOrders : null,
      },
      {
        'icon': Icons.inventory_2_outlined,
        'label': 'Produk',
        'route': '/umkm/products',
        'badge': null,
      },
      {
        'icon': Icons.analytics_outlined,
        'label': 'Analitik',
        'route': '/umkm/analytics',
        'badge': null,
      },
      {
        'icon': Icons.auto_awesome_rounded,
        'label': 'Asisten AI',
        'route': '/umkm/ai-assistant',
        'badge': null,
      },
      {
        'icon': Icons.notifications_outlined,
        'label': 'Notifikasi',
        'route': '/umkm/notifications',
        'badge': null,
      },
      {
        'icon': Icons.monetization_on_outlined,
        'label': 'Lokal Coin',
        'route': '/umkm/lokal-coin',
        'badge': null,
      },
      {
        'icon': Icons.settings_outlined,
        'label': 'Pengaturan',
        'route': '/umkm/store-settings',
        'badge': null,
      },
    ];
  }

  /// ── TOP BAR ─────────────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context, UmkmProvider provider, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 20,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppTheme.cardBorder),
        ),
      ),
      child: Row(
        children: [
          // ── Mobile: Hamburger Menu ──────────────────────────────
          if (isMobile)
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                tooltip: 'Menu',
              ),
            ),

          // ── Search Bar ──────────────────────────────────────────
          if (!isMobile)
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                decoration: BoxDecoration(
                  color: AppTheme.surface2,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Cari pesanan, produk, atau pelanggan...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textHint,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: AppTheme.textHint,
                    ),
                    border: InputBorder.none,
                    filled: true,
                    fillColor: AppTheme.surface2,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),

          const Spacer(),

          // ── Mobile: Search Icon ─────────────────────────────────
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.search_rounded, size: 22),
              onPressed: () {
                setState(() => _showMobileSearch = !_showMobileSearch);
              },
            ),

          // ── Notification Bell ───────────────────────────────────
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 22),
                onPressed: () => context.push('/umkm/notifications'),
                tooltip: 'Notifikasi',
                color: AppTheme.textSecondary,
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.danger,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),

          // ── Help Icon ───────────────────────────────────────────
          IconButton(
            icon: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppTheme.surface2,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: Text(
                  '?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
            onPressed: () {},
            tooltip: 'Bantuan',
          ),

          const SizedBox(width: 8),

          // ── Merchant Profile (Top Bar Kanan) ────────────────────
          PopupMenuButton<String>(
            offset: const Offset(0, 45),
            tooltip: 'Menu Profil',
            onSelected: (String value) => _handleProfileMenu(context, value),
            itemBuilder: (BuildContext ctx) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings_outlined),
                  title: Text('Pengaturan Toko'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'security',
                child: ListTile(
                  leading: Icon(Icons.lock_outline),
                  title: Text('Keamanan & Reset Password'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Keluar (Logout)', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        provider.storeName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          provider.storeLevel,
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF8E24AA),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.primary,
                    child: Text(
                      provider.storeName.isNotEmpty
                          ? provider.storeName[0].toUpperCase()
                          : 'T',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: AppTheme.textHint,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Handler untuk aksi menu profil
  void _handleProfileMenu(BuildContext context, String value) {
    if (value == 'settings') {
      context.push('/umkm/store-settings');
    } else if (value == 'security') {
      _showSecurityModal(context);
    } else if (value == 'logout') {
      _handleLogout(context);
    }
  }

  /// Interactive Security & Reset Password Modal
  void _showSecurityModal(BuildContext context) {
    final currentPwdCtrl = TextEditingController();
    final newPwdCtrl = TextEditingController();
    final confirmPwdCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.lock_outline, color: AppTheme.danger, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Keamanan & Reset Password',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 420,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gunakan kata sandi yang kuat dan berbeda dari akun lainnya.',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                      ),
                      const SizedBox(height: 20),

                      // Current Password
                      TextFormField(
                        controller: currentPwdCtrl,
                        obscureText: obscureCurrent,
                        decoration: InputDecoration(
                          labelText: 'Kata Sandi Saat Ini',
                          hintText: 'Masukkan kata sandi saat ini',
                          prefixIcon: const Icon(Icons.lock_outline, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(obscureCurrent ? Icons.visibility_off : Icons.visibility, size: 20),
                            onPressed: () => setDialogState(() => obscureCurrent = !obscureCurrent),
                          ),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Kata sandi saat ini wajib diisi' : null,
                      ),
                      const SizedBox(height: 14),

                      // New Password
                      TextFormField(
                        controller: newPwdCtrl,
                        obscureText: obscureNew,
                        decoration: InputDecoration(
                          labelText: 'Kata Sandi Baru',
                          hintText: 'Minimal 8 karakter',
                          prefixIcon: const Icon(Icons.lock, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility, size: 20),
                            onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Kata sandi baru wajib diisi';
                          if (v.length < 8) return 'Minimal 8 karakter';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Confirm Password
                      TextFormField(
                        controller: confirmPwdCtrl,
                        obscureText: obscureConfirm,
                        decoration: InputDecoration(
                          labelText: 'Konfirmasi Kata Sandi Baru',
                          hintText: 'Ketik ulang kata sandi baru',
                          prefixIcon: const Icon(Icons.lock, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility, size: 20),
                            onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Konfirmasi kata sandi wajib diisi';
                          if (v != newPwdCtrl.text) return 'Kata sandi tidak cocok';
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      // Password strength indicator
                      if (newPwdCtrl.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(
                                newPwdCtrl.text.length >= 8 ? Icons.check_circle : Icons.info_outline,
                                size: 14,
                                color: newPwdCtrl.text.length >= 8 ? AppTheme.success : AppTheme.warning,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                newPwdCtrl.text.length >= 8 ? 'Kekuatan kata sandi: Baik' : 'Minimal 8 karakter',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: newPwdCtrl.text.length >= 8 ? AppTheme.success : AppTheme.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                ElevatedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() => isLoading = true);
                          try {
                            final api = ApiService();
                            await api.changePassword(currentPwdCtrl.text, newPwdCtrl.text);
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: const Text('✓ Kata sandi berhasil diperbarui'),
                                backgroundColor: AppTheme.success,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                margin: const EdgeInsets.all(16),
                              ));
                            }
                          } catch (e) {
                            String msg = 'Gagal mengubah kata sandi';
                            try { final resp = (e as dynamic).response; if (resp?.data?['message'] != null) msg = resp.data['message']; } catch (_) {}
                            setDialogState(() => isLoading = false);
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                                content: Text(msg),
                                backgroundColor: AppTheme.danger,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                margin: const EdgeInsets.all(16),
                              ));
                            }
                          }
                        },
                  icon: isLoading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_outlined, size: 18),
                  label: Text(isLoading ? 'Menyimpan...' : 'Simpan Kata Sandi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final navigator = GoRouter.of(context);
    await authProvider.logout();
    navigator.go('/login');
  }
}

/// Widget item menu sidebar
class _SidebarMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final int? badge;
  final bool isActive;
  final bool isMobile;
  final VoidCallback onTap;

  const _SidebarMenuItem({
    required this.icon,
    required this.label,
    required this.route,
    this.badge,
    required this.isActive,
    required this.isMobile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.primary.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive ? AppTheme.primary : AppTheme.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? AppTheme.primary : AppTheme.textSecondary,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.danger,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$badge',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
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