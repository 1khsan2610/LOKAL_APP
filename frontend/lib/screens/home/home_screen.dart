import 'package:flutter/material.dart';
import '../../config/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late double _selectedRadius;
  String _selectedTab = 'katalog';

  @override
  void initState() {
    super.initState();
    _selectedRadius = 5.0; // Initialize as double within valid range
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: _buildAppBar(),
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          _buildTabs(),
          Expanded(child: _buildProductGrid()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor,
            ),
            child: const Icon(Icons.shopping_basket, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Platform LOKAL',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              Text(
                'Dukung UMKM Lokal',
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
        ),
        IconButton(
          icon: const Icon(Icons.account_circle_outlined, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pushNamed(context, '/profile'),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: _buildNavigationBar(),
      ),
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.dividerColor)),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _navItem(Icons.location_on, 'Beranda', () {}),
          _navItem(Icons.shopping_cart, 'Keranjang', () => Navigator.pushNamed(context, '/cart')),
          _navItem(Icons.receipt, 'Pesanan', () => Navigator.pushNamed(context, '/orders')),
          _navItem(Icons.favorite_border, 'Wishlist', () {}),
          _navItem(Icons.payments, 'Lokal Coin', () => Navigator.pushNamed(context, '/wallet')),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppTheme.textSecondary),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Cari produk atau kategori...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.dividerColor),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.location_on, color: AppTheme.textSecondary, size: 18),
              const SizedBox(width: 8),
              const Text('Radius:', style: TextStyle(fontWeight: FontWeight.w500)),
              Expanded(
                child: Slider(
                  value: _selectedRadius.clamp(0.5, 10.0),
                  min: 0.5,
                  max: 10.0,
                  divisions: 19,
                  label: '${_selectedRadius.toStringAsFixed(1)} km',
                  onChanged: (value) {
                    setState(() => _selectedRadius = value);
                  },
                ),
              ),
              Text('${_selectedRadius.toStringAsFixed(1)} km', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.dividerColor))),
      child: Row(
        children: [
          _tabItem('Peta UMKM', 'peta'),
          _tabItem('Katalog Produk', 'katalog'),
        ],
      ),
    );
  }

  Widget _tabItem(String label, String tabId) {
    final isSelected = _selectedTab == tabId;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = tabId),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 8),
                height: 2,
                width: 40,
                color: AppTheme.primaryColor,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    if (_selectedTab == 'peta') {
      return const Center(child: Text('Map View Coming Soon'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => _buildProductCard(),
    );
  }

  Widget _buildProductCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: const Icon(Icons.image, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Warung Bu Siti', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('Makanan & Minuman', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_half, size: 12, color: Colors.orange),
                      const SizedBox(width: 2),
                      const Text('4.5', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('Jl. Merdeka No. 45', style: TextStyle(fontSize: 9, color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
