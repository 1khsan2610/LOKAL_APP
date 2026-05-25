import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../widgets/common/custom_widgets.dart';

class MarketMapScreen extends StatefulWidget {
  const MarketMapScreen({Key? key}) : super(key: key);

  @override
  State<MarketMapScreen> createState() => _MarketMapScreenState();
}

class _MarketMapScreenState extends State<MarketMapScreen> {
  double _selectedRadius = 5.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.navMarketMap,
      ),
      body: Column(
        children: [
          // Search & Filter
          Padding(
            padding: const EdgeInsets.all(AppNumbers.paddingMedium),
            child: Column(
              children: [
                // Search box
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari UMKM atau produk...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Radius selector
                Row(
                  children: [
                    const Icon(Icons.my_location, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Slider(
                        value: _selectedRadius,
                        min: AppConstants.minSearchRadius,
                        max: AppConstants.maxSearchRadius,
                        divisions: 19,
                        label: '${_selectedRadius.toStringAsFixed(1)} km',
                        onChanged: (value) {
                          setState(() => _selectedRadius = value);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Map placeholder
          Expanded(
            child: Container(
              color: AppTheme.dividerColor,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 48,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Peta Google Maps\nakan ditampilkan di sini',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Radius: ${_selectedRadius.toStringAsFixed(1)} km',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
