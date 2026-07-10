import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/product_provider.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/product_card.dart';
import '../../models/product_model.dart';

class SearchScreen extends StatefulWidget {
  final String initialQuery;
  const SearchScreen({super.key, this.initialQuery = ''});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _ctrl;
  final List<String> _recent = ['Bakso Aci', 'Kopi Lokal', 'Beras Organik', 'Batik Modern'];
  final List<Map<String, String>> _categories = [
    {'id': '', 'icon': '🏪', 'label': 'Semua'},
    {'id': 'makanan', 'icon': '🍜', 'label': 'Makanan'},
    {'id': 'minuman', 'icon': '☕', 'label': 'Minuman'},
    {'id': 'fashion', 'icon': '👗', 'label': 'Fashion'},
    {'id': 'kerajinan', 'icon': '🧺', 'label': 'Kerajinan'},
    {'id': 'bahan_pokok', 'icon': '🌾', 'label': 'Bahan Pokok'},
  ];
  final _api = ApiService();
  List<UmkmModel> _nearbyStores = [];
  UmkmModel? _selectedStore;
  String? _selectedCategory;
  bool _loadingStores = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialQuery);
    if (widget.initialQuery.isNotEmpty) _search(widget.initialQuery);
    _loadNearbyStores();
  }

  Future<void> _loadNearbyStores() async {
    setState(() => _loadingStores = true);
    try {
      // Try to get nearby stores (default to Jakarta area if no location)
      final resp = await _api.getUmkmList(page: 1);
      final data = resp.data['data']['data'] as List? ?? [];
      if (mounted) {
        setState(() {
          _nearbyStores = data.map((e) => UmkmModel.fromJson(e)).toList();
          _loadingStores = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingStores = false);
    }
  }

  void _search(String q) {
    // Allow search if: query not empty OR has active filters
    final hasFilters = _selectedStore != null || _selectedCategory != null;
    if (q.trim().isEmpty && !hasFilters) return;
    
    context.read<ProductProvider>().searchWithFilters(
      q.trim(),
      umkmId: _selectedStore?.id,
      category: _selectedCategory?.isNotEmpty == true ? _selectedCategory : null,
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final prod = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: TextField(
            controller: _ctrl,
            autofocus: true,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: 'Cari produk, UMKM...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
              filled: false,
              border: InputBorder.none,
              suffixIcon: _ctrl.text.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 18),
                      onPressed: () { _ctrl.clear(); setState(() {}); })
                  : null,
            ),
            onSubmitted: _search,
            onChanged: (v) { setState(() {}); if (v.length > 2) _search(v); },
          ),
        ),
      ),
      body: _ctrl.text.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('🕐 Pencarian Terakhir', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8,
                  children: _recent.map((r) => GestureDetector(
                    onTap: () { _ctrl.text = r; _search(r); setState(() {}); },
                    child: Chip(label: Text(r, style: const TextStyle(fontSize: 12))),
                  )).toList(),
                ),
                const SizedBox(height: 20),
                const Text('🔥 Kategori Populer', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((c) {
                      final isSelected = _selectedCategory == c['id'];
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedCategory = c['id'] == '' ? null : c['id']);
                          if (_ctrl.text.isNotEmpty) _search(_ctrl.text);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primary : AppTheme.surface,
                            border: Border.all(
                              color: isSelected ? AppTheme.primary : AppTheme.border,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(c['icon']!, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 4),
                              Text(
                                c['label']!,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                // ── Store Filter ──────────────────────────────────
                const Text('🏪 Filter Toko Terdekat', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                _loadingStores
                    ? const Center(child: Padding(
                        padding: EdgeInsets.all(8),
                        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary)),
                      ))
                    : _nearbyStores.isEmpty
                        ? const Text('Tidak ada toko tersedia', style: TextStyle(fontSize: 12, color: AppTheme.textHint))
                        : SizedBox(
                            height: 50,
                            child: ListView(scrollDirection: Axis.horizontal,
                              children: [
                                // All stores option
                                _StoreFilterChip(
                                  label: 'Semua Toko',
                                  isSelected: _selectedStore == null,
                                  onTap: () {
                                    setState(() => _selectedStore = null);
                                    if (_ctrl.text.isNotEmpty) _search(_ctrl.text);
                                  },
                                ),
                                ..._nearbyStores.map((store) => _StoreFilterChip(
                                  label: store.name,
                                  isSelected: _selectedStore?.id == store.id,
                                  onTap: () {
                                    setState(() => _selectedStore = store);
                                    if (_ctrl.text.isNotEmpty) _search(_ctrl.text);
                                  },
                                )),
                              ],
                            ),
                          ),
              ]),
            )
          : Column(children: [
              // Active filters indicator
              if (_selectedStore != null || _selectedCategory != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppTheme.primaryLight.withValues(alpha: 0.1),
                  child: Row(children: [
                    if (_selectedStore != null) ...[
                      const Icon(Icons.store, size: 16, color: AppTheme.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text('Toko: ${_selectedStore!.name}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w600)),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() => _selectedStore = null);
                          if (_ctrl.text.isNotEmpty) _search(_ctrl.text);
                        },
                        child: const Icon(Icons.close, size: 16, color: AppTheme.primary),
                      ),
                    ] else if (_selectedCategory != null) ...[
                      const Icon(Icons.category, size: 16, color: AppTheme.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text('Kategori: ${_categories.firstWhere((c) => c['id'] == _selectedCategory)['label']}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w600)),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() => _selectedCategory = null);
                          if (_ctrl.text.isNotEmpty) _search(_ctrl.text);
                        },
                        child: const Icon(Icons.close, size: 16, color: AppTheme.primary),
                      ),
                    ],
                  ]),
                ),
              Expanded(
                child: prod.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                    : prod.searchResults.isEmpty
                        ? const EmptyState(emoji: '🔍', title: 'Produk tidak ditemukan',
                            subtitle: 'Coba kata kunci yang berbeda')
                        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                              child: Text('${prod.searchResults.length} hasil untuk "${_ctrl.text}"${_selectedStore != null ? ' di ${_selectedStore!.name}' : ''}',
                                style: const TextStyle(fontSize: 12, color: AppTheme.textHint)),
                            ),
                            Expanded(
                              child: GridView.builder(
                                padding: const EdgeInsets.all(12),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: ResponsiveHelper.getGridColumns(context),
                                  childAspectRatio: ResponsiveHelper.getResponsiveChildAspectRatio(context),
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                                itemCount: prod.searchResults.length,
                                itemBuilder: (_, i) => ProductCard(product: prod.searchResults[i]),
                              ),
                            ),
                          ]),
              ),
            ]),
    );
  }
}

class _StoreFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _StoreFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primary : AppTheme.surface,
        border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.border, width: isSelected ? 2 : 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.store, size: 14, color: isSelected ? Colors.white : AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.textPrimary,
          ),
        ),
      ]),
    ),
  );
}