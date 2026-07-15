// ═══════════════════════════════════════════════════════════════════
//  Widget kartu produk untuk layar "Kelola Produk" (seller/UMKM side).
//  Dipisah dari ManageProductScreen supaya:
//   1) bisa dipakai baik dalam ListView (HP, satu kolom, horizontal card)
//      maupun GridView (tablet/desktop, kartu vertikal) tanpa duplikasi,
//   2) styling kartu (radius 16, border shade200) konsisten dengan
//      dashboard & Beranda yang sudah dipoles,
//   3) setiap bagian teks sudah dijaga dari overflow secara terpisah.
// ═══════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../utils/app_theme.dart';
import '../utils/image_helper.dart';
import 'app_card.dart';
import 'product_card.dart'; // PriceText

/// Kartu baris horizontal — dipakai di layar sempit (HP).
class ProductManageTile extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductManageTile({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final p = product;
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 58, height: 58,
            child: p.primaryImage != null
                ? Image.network(resolveImageUrl(p.primaryImage), fit: BoxFit.cover)
                : Container(color: AppTheme.surface2, child: const Icon(Icons.image_outlined, color: AppTheme.textHint)),
          ),
        ),
        const SizedBox(width: 12),
        // Expanded memastikan kolom teks mengambil sisa ruang yang ada dan
        // tidak mendorong PopupMenuButton keluar dari batas kartu.
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            // Wrap, bukan Row biasa: kalau harga panjang + label stok tidak
            // muat dalam satu baris di layar sempit, item stok akan turun
            // ke baris berikutnya alih-alih overflow ke kanan.
            Wrap(
              spacing: 10,
              runSpacing: 2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                PriceText(p.price, fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w700),
                Text('Stok: ${p.stock}', style: TextStyle(fontSize: 11, color: p.stock < 5 ? AppTheme.danger : AppTheme.textHint)),
              ],
            ),
            const SizedBox(height: 2),
            Text('${p.soldCount} terjual · ⭐${p.avgRating.toStringAsFixed(1)}',
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
          ]),
        ),
        _MenuButton(onEdit: onEdit, onDelete: onDelete),
      ]),
    );
  }
}

/// Kartu vertikal — dipakai di GridView pada layar lebar (tablet/desktop),
/// supaya "Kelola Produk" tidak terlihat kaku sebagai satu kolom panjang
/// saat lebar layar sebenarnya cukup untuk beberapa kolom.
class ProductManageGridTile extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductManageGridTile({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final p = product;
    return AppCard(
      padding: const EdgeInsets.all(10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Stack(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: 1.3,
              child: p.primaryImage != null
                  ? Image.network(resolveImageUrl(p.primaryImage), fit: BoxFit.cover, width: double.infinity)
                  : Container(color: AppTheme.surface2, child: const Icon(Icons.image_outlined, color: AppTheme.textHint)),
            ),
          ),
          Positioned(
            top: 2, right: 2,
            child: _MenuButton(onEdit: onEdit, onDelete: onDelete, dark: true),
          ),
        ]),
        const SizedBox(height: 8),
        Text(p.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        PriceText(p.price, fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.w700),
        const SizedBox(height: 2),
        Row(children: [
          Flexible(
            child: Text('Stok: ${p.stock}', maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: p.stock < 5 ? AppTheme.danger : AppTheme.textHint)),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text('${p.soldCount} terjual', maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
          ),
        ]),
      ]),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool dark;
  const _MenuButton({required this.onEdit, required this.onDelete, this.dark = false});

  @override
  Widget build(BuildContext context) {
    final button = PopupMenuButton<String>(
      onSelected: (v) {
        if (v == 'edit') onEdit();
        if (v == 'delete') onDelete();
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'edit', child: Text('✏️ Edit')),
        PopupMenuItem(value: 'delete', child: Text('🗑️ Hapus', style: TextStyle(color: AppTheme.danger))),
      ],
      icon: Icon(Icons.more_vert, size: 20, color: dark ? Colors.white : AppTheme.textSecondary),
    );
    if (!dark) return button;
    return Container(
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.35), shape: BoxShape.circle),
      child: button,
    );
  }
}
