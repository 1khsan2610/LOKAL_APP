import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/api_service.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ulasan Saya'),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _reviews.isEmpty
              ? const EmptyState(
                  emoji: '⭐',
                  title: 'Belum ada ulasan',
                  subtitle: 'Beri ulasan setelah menerima pesanan agar bisa dilihat di sini.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reviews.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final review = _reviews[index];
                    return Card(
                      child: ListTile(
                        title: Text('Produk #${review.productId}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Row(
                              children: List.generate(5, (i) => Icon(
                                i < review.rating ? Icons.star_rounded : Icons.star_border_rounded,
                                size: 16,
                                color: Colors.amber,
                              )),
                            ),
                            const SizedBox(height: 6),
                            Text(review.comment ?? 'Tanpa komentar'),
                          ],
                        ),
                        trailing: Text(review.createdAt, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ),
                    );
                  },
                ),
    );
  }
}
