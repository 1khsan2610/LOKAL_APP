import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../models/product_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/image_helper.dart';
import '../../widgets/product_card.dart';
import 'tracking_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});
  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _api = ApiService();
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  final _tabs = ['Semua', 'Bayar', 'Dikemas', 'Dikirim', 'Selesai', 'Batal'];
  final _statuses = [null, 'awaiting_payment', 'processing', 'shipped', 'delivered', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _tabCtrl.addListener(() { if (_tabCtrl.indexIsChanging) _load(_statuses[_tabCtrl.index]); });
    _load(null);
  }

  Future<void> _load(String? status) async {
    setState(() { _isLoading = true; _orders = []; });
    try {
      final resp = await _api.getOrders(status: status);
      setState(() {
        _orders = (resp.data['data']['data'] as List).map((e) => OrderModel.fromJson(e)).toList();
      });
    } catch (_) {} finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.bg,
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
        onPressed: () => context.go('/main'),
      ),
      title: const Text('Pesanan Saya'),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.all(4),
          child: TabBar(
            controller: _tabCtrl,
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: const Color(0xFF64748B),
            indicator: BoxDecoration(
              color: const Color(0xFF1D4ED8),
              borderRadius: BorderRadius.circular(12),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            tabs: _tabs.map((t) => Tab(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Text(t),
              ),
            )).toList(),
          ),
        ),
      ),
    ),
    body: SafeArea(
      child: _isLoading
        ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
        : _orders.isEmpty
            ? EmptyState(emoji: '📦', title: 'Belum Ada Pesanan', subtitle: 'Yuk mulai belanja produk UMKM lokal!',
                buttonLabel: 'Mulai Belanja', onButton: () => context.go('/main'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _orders.length,
                itemBuilder: (_, i) => _OrderCard(order: _orders[i]),
              ),
    ),
  );
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(children: [
        // ── HEADER CARD ────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: AppTheme.surface2,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
          ),
          child: Row(children: [
            Expanded(child: Text('#${order.orderNumber}', maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primary))),
            const SizedBox(width: 8),
            StatusBadge(status: order.status),
          ]),
        ),
        // ── BODY CARD ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            // Kiri: Thumbnail gambar (60x60, rounded)
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(color: AppTheme.surface2, borderRadius: BorderRadius.circular(10)),
              child: order.items.isNotEmpty && order.items.first.product?.primaryImage != null
                  ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(
                      resolveImageUrl(order.items.first.product!.primaryImage),
                      width: 60, height: 60, fit: BoxFit.cover,
                    ))
                  : const Icon(Icons.image_outlined, color: AppTheme.textHint, size: 28),
            ),
            const SizedBox(width: 12),
            // Tengah: Nama produk + info varian/jumlah
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  order.items.isNotEmpty
                      ? (order.items.first.product?.name ?? 'Produk')
                      : 'Produk tidak tersedia',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${order.items.length} barang',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textHint),
                ),
              ]),
            ),
            const SizedBox(width: 8),
            // Kanan: Total harga
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const Text('Total', style: TextStyle(fontSize: 11, color: AppTheme.textHint)),
              const SizedBox(height: 2),
              Text(currency.format(order.total), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1D4ED8))),
            ]),
          ]),
        ),
        // ── FOOTER CARD ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (order.status == 'delivered')
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton(
                    onPressed: () => context.push('/orders/detail/${order.id}'),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), minimumSize: Size.zero),
                    child: const Text('Beri Ulasan', style: TextStyle(color: AppTheme.primary, fontSize: 12)),
                  ),
                ),
              if (order.status == 'shipped')
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrackingScreen(orderId: order.id, orderNumber: order.orderNumber))),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), minimumSize: Size.zero),
                    child: const Text('Lacak Paket', style: TextStyle(color: AppTheme.primary, fontSize: 12)),
                  ),
                ),
              OutlinedButton(
                onPressed: () async {
                  final changed = await context.push('/orders/detail/${order.id}');
                  if (changed == true && context.mounted) {
                    (context.findAncestorStateOfType<_OrderListScreenState>())?._load(null);
                  }
                },
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), textStyle: const TextStyle(fontSize: 12), minimumSize: Size.zero),
                child: const Text('Detail >'),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}