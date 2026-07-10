import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  final String initialQuery;
  const SearchScreen({super.key, this.initialQuery = ''});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _ctrl;
  final List<String> _recent = ['Bakso Aci', 'Kopi Lokal', 'Beras Organik', 'Batik Modern'];

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialQuery);
    if (widget.initialQuery.isNotEmpty) _search(widget.initialQuery);
  }

  void _search(String q) {
    if (q.trim().isEmpty) return;
    context.read<ProductProvider>().search(q.trim());
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final prod = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.pop(context)),
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
                Wrap(spacing: 8, runSpacing: 8,
                  children: ['🍜 Makanan', '☕ Minuman', '👗 Fashion', '🧺 Kerajinan', '🌾 Bahan Pokok']
                    .map((c) => ActionChip(
                      label: Text(c, style: const TextStyle(fontSize: 12)),
                      onPressed: () { _ctrl.text = c.substring(2); _search(c.substring(2)); setState(() {}); },
                    )).toList(),
                ),
              ]),
            )
          : prod.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
              : prod.searchResults.isEmpty
                  ? const EmptyState(emoji: '🔍', title: 'Produk tidak ditemukan',
                      subtitle: 'Coba kata kunci yang berbeda')
                  : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Text('${prod.searchResults.length} hasil untuk "${_ctrl.text}"',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textHint)),
                      ),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, childAspectRatio: 0.68,
                            crossAxisSpacing: 12, mainAxisSpacing: 12,
                          ),
                          itemCount: prod.searchResults.length,
                          itemBuilder: (_, i) => ProductCard(product: prod.searchResults[i]),
                        ),
                      ),
                    ]),
    );
  }
}

