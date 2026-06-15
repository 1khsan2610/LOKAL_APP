import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import 'product_detail_screen.dart';

// Mock data for products
final mockProducts = [
  {
    'id': '1',
    'name': 'Tahu Goreng Crispy',
    'price': 15000,
    'rating': 4.8,
    'reviews': 245,
    'image': 'https://via.placeholder.com/300x300?text=Tahu+Goreng',
    'category': 'Makanan',
    'umkm': 'Tahu Goreng Bu Siti',
    'distance': '2.3 km'
  },
  {
    'id': '2',
    'name': 'Batik Tulis Premium',
    'price': 350000,
    'rating': 4.9,
    'reviews': 128,
    'image': 'https://via.placeholder.com/300x300?text=Batik',
    'category': 'Kerajinan',
    'umkm': 'Batik Lasem Jati',
    'distance': '1.5 km'
  },
  {
    'id': '3',
    'name': 'Kopi Arabika Specialty',
    'price': 65000,
    'rating': 4.7,
    'reviews': 312,
    'image': 'https://via.placeholder.com/300x300?text=Kopi+Arabika',
    'category': 'Minuman',
    'umkm': 'Kopi Lokal Jawa',
    'distance': '3.1 km'
  },
  {
    'id': '4',
    'name': 'Jaket Denim Custom',
    'price': 180000,
    'rating': 4.6,
    'reviews': 89,
    'image': 'https://via.placeholder.com/300x300?text=Jaket+Denim',
    'category': 'Fashion',
    'umkm': 'Konveksi Muda',
    'distance': '2.8 km'
  },
  {
    'id': '5',
    'name': 'Mie Aceh Spesial',
    'price': 25000,
    'rating': 4.5,
    'reviews': 456,
    'image': 'https://via.placeholder.com/300x300?text=Mie+Aceh',
    'category': 'Makanan',
    'umkm': 'Mie Aceh Asli',
    'distance': '0.9 km'
  },
  {
    'id': '6',
    'name': 'Tas Rajutan Handmade',
    'price': 95000,
    'rating': 4.9,
    'reviews': 167,
    'image': 'https://via.placeholder.com/300x300?text=Tas+Rajutan',
    'category': 'Kerajinan',
    'umkm': 'Rajutan Ibu Desi',
    'distance': '1.2 km'
  },
];

class ProductCatalogScreen extends ConsumerStatefulWidget {
  const ProductCatalogScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProductCatalogScreen> createState() =>
      _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends ConsumerState<ProductCatalogScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'Semua';
  List<dynamic> _filteredProducts = [];

  final categories = [
    'Semua',
    'Makanan',
    'Fashion',
    'Kerajinan',
    'Minuman',
    'Lainnya'
  ];

  @override
  void initState() {
    super.initState();
    _filteredProducts = mockProducts;
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = mockProducts.where((product) {
        final nameMatch = product['name']
            .toString()
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
        final categoryMatch = _selectedCategory == 'Semua' ||
            product['category'] == _selectedCategory;
        return nameMatch && categoryMatch;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Katalog Produk',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => _filterProducts(),
                      decoration: InputDecoration(
                        hintText: 'Cari produk...',
                        hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterProducts();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Category Filter
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = category == _selectedCategory;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            selected: isSelected,
                            label: Text(
                              category,
                              style: GoogleFonts.poppins(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = category;
                                _filterProducts();
                              });
                            },
                            backgroundColor: Colors.white,
                            selectedColor: AppTheme.primaryColor,
                            side: BorderSide(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.grey[300]!,
                            ),
                            labelStyle: TextStyle(
                              color:
                                  isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Results count
                  Text(
                    '${_filteredProducts.length} produk ditemukan',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Product Grid
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = _filteredProducts[index];
                  return _buildProductCard(context, product);
                },
                childCount: _filteredProducts.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, dynamic product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(product['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Favorite Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                        )
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.favorite_border,
                        size: 18,
                        color: Colors.red,
                      ),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ),
                ),
                // Rating Badge
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black87.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 12,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${product['rating']}',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Product Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product['name'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // UMKM Name
                    Text(
                      product['umkm'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Distance
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          product['distance'],
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Price and Reviews
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rp${(product['price'] as int).toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (Match m) => '${m[1]}.')}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Text(
                          '${product['reviews']} review',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
