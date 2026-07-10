import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../models/product_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/image_helper.dart';
import '../../widgets/product_card.dart';
import 'tracking_page.dart'; // Tambahkan import ini

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
    appBar: AppBar(
      title: const Text('Pesanan Saya'),
      bottom: TabBar(
        controller: _tabCtrl,
        isScrollable: true,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        indicatorColor: AppTheme.accent,
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
      ),
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
        : _orders.isEmpty
            ? EmptyState(emoji: '📦', title: 'Belum Ada Pesanan', subtitle: 'Yuk mulai belanja produk UMKM lokal!',
                buttonLabel: 'Mulai Belanja', onButton: () => context.go('/main'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _orders.length,
                itemBuilder: (_, i) => _OrderCard(order: _orders[i]),
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
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: AppTheme.surface2,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
          ),
          child: Row(children: [
            Text('#${order.orderNumber}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primary)),
            const Spacer(),
            StatusBadge(status: order.status),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            ...order.items.take(3).map((item) => Container(
              margin: const EdgeInsets.only(right: 6),
              width: 52, height: 52,
              decoration: BoxDecoration(color: AppTheme.surface2, borderRadius: BorderRadius.circular(8)),
              child: item.product?.primaryImage != null
                  ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(resolveImageUrl(item.product!.primaryImage), fit: BoxFit.cover))
                  : const Icon(Icons.image_outlined, color: AppTheme.textHint),
            )),
            if (order.items.length > 3)
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(color: AppTheme.surface2, borderRadius: BorderRadius.circular(8)),
                child: Center(child: Text('+${order.items.length - 3}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
              ),
            const Spacer(),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const Text('Total', style: TextStyle(fontSize: 11, color: AppTheme.textHint)),
              Text(currency.format(order.total), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.primary)),
            ]),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            if (order.status == 'delivered')
              TextButton(
                onPressed: () => context.push('/orders/detail/${order.id}'),
                child: const Text('Beri Ulasan', style: TextStyle(color: AppTheme.primary, fontSize: 12)),
              ),
            if (order.status == 'shipped')
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrackingPage(orderId: order.id, orderCode: order.orderNumber))),
                child: const Text('Lacak Paket', style: TextStyle(color: AppTheme.primary, fontSize: 12)),
              ),
            OutlinedButton(
              onPressed: () async {
                final changed = await context.push('/orders/detail/${order.id}');
                if (changed == true && context.mounted) {
                  (context.findAncestorStateOfType<_OrderListScreenState>())?._load(null);
                }
              },
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), textStyle: const TextStyle(fontSize: 12), minimumSize: Size.zero),
              child: const Text('Detail'),
            ),
          ]),
        ),
      ]),
    );
  }
}