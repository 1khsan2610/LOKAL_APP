// ═══════════════════════════════════════════════════════════════════
//  MyReviewsScreen  —  lib/screens/profile/my_reviews_screen.dart
//  Prinsip desain: AppCard menggantikan Card/ListTile bawaan agar
//  konsisten dgn kartu produk di Beranda. bg #F8FAFC. Komentar ulasan
//  & tanggal dibungkus Expanded/Flexible agar tidak overflow.
// ═══════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/product_card.dart';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  final _api = ApiService();
  bool _loading = true;
  final List<ReviewModel> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _loading = true);
    try {
      final response = await _api.getMyReviews();
      final data = response.data['data'] as List;
      _reviews
        ..clear()
        ..addAll(data.map((e) => ReviewModel.fromJson(e)).toList());
    } catch (_) {
      _reviews.clear();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).viewPadding.bottom;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Ulasan Saya'),
        leading: const BackButton(),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _reviews.isEmpty
              ? const EmptyState(
                  emoji: '⭐',
                  title: 'Belum ada ulasan',
                  subtitle: 'Beri ulasan setelah menerima pesanan agar bisa dilihat di sini.',
                )
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, bottomSafe + 16),
                  itemCount: _reviews.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final review = _reviews[index];
                    return AppCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // ── Hierarki 1: nama/id produk ──
                              Expanded(
                                child: Text(
                                  'Produk #${review.productId}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // ── Hierarki 3: tanggal ── Flexible cegah
                              // overflow saat nama produk cukup panjang.
                              Flexible(
                                child: Text(
                                  review.createdAt,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textHint),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // ── Hierarki 2: rating bintang ──
                          Row(
                            children: List.generate(5, (i) => Icon(
                              i < review.rating ? Icons.star_rounded : Icons.star_border_rounded,
                              size: 17,
                              color: AppTheme.accent,
                            )),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            review.comment ?? 'Tanpa komentar',
                            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
