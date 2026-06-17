import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/order.dart';
import '../../widgets/common/custom_widgets.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  String? _snapUrl;
  Order? _order;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePayment();
    });
  }

  void _initializePayment() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Order) {
      setState(() => _order = args);
      _initWebView();
    }
  }

  void _initWebView() {
    // Initialize WebView controller
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${error.description}'),
                backgroundColor: Colors.red,
              ),
            );
          },
        ),
      );

    // Load Midtrans SNAP token (simulated)
    // In production, get real SNAP token from backend
    _loadMidtransSnap();
  }

  void _loadMidtransSnap() {
    // Simulated Midtrans SNAP URL - in production, replace with real API
    final snapUrl = _generateMidtransSnapUrl(_order);
    if (snapUrl.isNotEmpty) {
      _webViewController.loadRequest(Uri.parse(snapUrl));
    } else if (_order?.paymentMethod == PaymentMethod.qris) {
      _showQRPayment();
    }
  }

  String _generateMidtransSnapUrl(Order? order) {
    if (order == null) return '';
    
    // In production, call backend API to get SNAP token
    // This is just a simulated example
    const baseUrl = 'https://app.sandbox.midtrans.com/snap/v1/pay/';
    
    // Replace with actual SNAP token from your backend
    const snapToken = 'SNAP_TOKEN_HERE'; // Get from backend
    
    if (snapToken == 'SNAP_TOKEN_HERE') {
      // Fallback to mock payment page
      return 'data:text/html,<html><body><h1>Simulasi Pembayaran</h1><p>Order ID: ${order.id}</p><p>Total: Rp ${order.totalPrice}</p></body></html>';
    }
    
    return '$baseUrl$snapToken';
  }

  void _showQRPayment() {
    showModalBottomSheet(
      context: context,
      builder: (context) => QRPaymentSheet(order: _order),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Pembayaran',
        showBackButton: false,
      ),
      body: _order == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                if (_order?.paymentMethod == PaymentMethod.qris)
                  _buildQRPaymentUI()
                else
                  WebViewWidget(controller: _webViewController),
                if (_isLoading && _order?.paymentMethod != PaymentMethod.qris)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
    );
  }

  Widget _buildQRPaymentUI() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          // Payment Info Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Metode Pembayaran',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('📱', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'QRIS',
                              style: Theme.of(context)
                                  .textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Scan kode QR dengan aplikasi pembayaran',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // QR Code Display (Placeholder)
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // QR Code placeholder
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      color: AppTheme.dividerColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.qr_code_2,
                      size: 120,
                      color: AppTheme.textHint,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tunjukkan kode QR ini ke kasir',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Amount Info
          Card(
            elevation: 2,
            color: AppTheme.primaryColor.withAlpha((255 * 0.05).round()),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Total Pembayaran',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${(_order!.totalPrice / 1000).toStringAsFixed(1)}k',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Order Details
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail Pesanan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nomor Pesanan',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '#${_order!.id.substring(0, 8).toUpperCase()}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Status',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withAlpha((255 * 0.2).round()),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Menunggu Pembayaran',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Action Buttons
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/order-status',
                (route) => route.isFirst,
                arguments: _order,
              );
            },
            child: const Text('Pesanan Berhasil dibuat'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kembali'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class QRPaymentSheet extends StatelessWidget {
  final Order? order;

  const QRPaymentSheet({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Scan QRIS',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          // QR Code
          Container(
            width: 200,
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 50),
            decoration: BoxDecoration(
              color: AppTheme.dividerColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.qr_code_2,
              size: 100,
              color: AppTheme.textHint,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Rp ${(order?.totalPrice ?? 0 / 1000).toStringAsFixed(1)}k',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pembayaran berhasil diproses'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Pembayaran Selesai'),
          ),
        ],
      ),
    );
  }
}
