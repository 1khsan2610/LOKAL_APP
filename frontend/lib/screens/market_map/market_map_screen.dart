import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../models/umkm.dart';
import '../../providers/umkm_provider.dart';
import '../../services/location_service.dart';
import '../../widgets/common/custom_widgets.dart';

class MarketMapScreen extends ConsumerStatefulWidget {
  const MarketMapScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MarketMapScreen> createState() => _MarketMapScreenState();
}

class _MarketMapScreenState extends ConsumerState<MarketMapScreen> {
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();
  final Completer<GoogleMapController> _mapController = Completer();

  Position? _currentPosition;
  bool _isLoadingLocation = true;
  String? _locationError;
  double _selectedRadius = AppConstants.defaultSearchRadius;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMap();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    try {
      final position = await _locationService.getCurrentLocation();
      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
        _locationError = null;
      });
      await _fetchNearbyUmkm();
    } catch (e) {
      setState(() {
        _locationError = e.toString();
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _fetchNearbyUmkm() async {
    if (_currentPosition == null) return;
    await ref.read(umkmProvider.notifier).fetchNearbyUMKM(
          latitude: _currentPosition!.latitude,
          longitude: _currentPosition!.longitude,
          radius: _selectedRadius,
        );
  }

  void _onSearchChanged() {
    setState(() {});
  }

  Future<void> _moveCameraToCurrentLocation() async {
    if (_currentPosition == null || !_mapController.isCompleted) return;
    final controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(
      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      14,
    ));
  }

  String _formatDistance(double distanceKm) {
    return _locationService.formatDistance(distanceKm);
  }

  List<UMKM> _filterUmkm(List<UMKM> umkmList) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return umkmList;

    return umkmList.where((umkm) {
      final name = umkm.name.toLowerCase();
      final category = umkm.category.toLowerCase();
      return name.contains(query) || category.contains(query);
    }).toList();
  }

  Set<Marker> _buildMarkers(List<UMKM> umkmList) {
    if (_currentPosition == null) return {};

    return umkmList.map((umkm) {
      final distanceKm = _locationService.calculateDistance(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        umkm.latitude,
        umkm.longitude,
      );
      final markerId = MarkerId(umkm.id);
      return Marker(
        markerId: markerId,
        position: LatLng(umkm.latitude, umkm.longitude),
        infoWindow: InfoWindow(
          title: umkm.name,
          snippet:
              '${umkm.category} • ${_formatDistance(distanceKm)} • ${umkm.rating.toStringAsFixed(1)} ⭐',
          onTap: () => _showUmkmBottomSheet(umkm, distanceKm),
        ),
        onTap: () => _showUmkmBottomSheet(umkm, distanceKm),
      );
    }).toSet();
  }

  void _showUmkmBottomSheet(UMKM umkm, double distanceKm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppNumbers.paddingMedium),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.dividerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                umkm.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                umkm.category,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${umkm.rating.toStringAsFixed(1)} • ${umkm.reviewCount} ulasan',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on,
                      color: AppTheme.primaryColor, size: 18),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      umkm.address ?? '- alamat tidak tersedia -',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.timer,
                      color: AppTheme.textSecondary, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    _formatDistance(distanceKm),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Tutup'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchSection(AsyncValue<List<UMKM>> umkmState) {
    final foundCount = umkmState.maybeWhen(
      data: (list) => _filterUmkm(list).length,
      orElse: () => 0,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppNumbers.paddingMedium,
        vertical: AppNumbers.paddingSmall,
      ),
      child: Material(
        color: AppTheme.surfaceColor,
        elevation: AppNumbers.elevationMedium,
        borderRadius: BorderRadius.circular(AppNumbers.largeBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppNumbers.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Peta UMKM Lokal',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Temukan UMKM terbaik di sekitar Anda dengan cepat.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _searchController,
                onChanged: (_) => _onSearchChanged(),
                hint: 'Cari UMKM atau produk...',
                prefixIcon:
                    const Icon(Icons.search, color: AppTheme.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? const Icon(Icons.close, color: AppTheme.textSecondary)
                    : null,
                onSuffixTap: () {
                  _searchController.clear();
                  _onSearchChanged();
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.location_searching,
                      color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Radius pencarian ${_selectedRadius.toStringAsFixed(1)} km',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _selectedRadius,
                min: AppConstants.minSearchRadius,
                max: AppConstants.maxSearchRadius,
                divisions: 19,
                activeColor: AppTheme.primaryColor,
                inactiveColor: AppTheme.primaryLight,
                label: '${_selectedRadius.toStringAsFixed(1)} km',
                onChanged: (value) {
                  setState(() {
                    _selectedRadius = value;
                  });
                },
                onChangeEnd: (_) async {
                  await _fetchNearbyUmkm();
                },
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  Chip(
                    backgroundColor:
                        AppTheme.primaryLight.withOpacity(0.16),
                    label: Text(
                      '${foundCount} UMKM ditemukan',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Chip(
                    backgroundColor:
                        AppTheme.accentColor.withOpacity(0.16),
                    label: Text(
                      'Radius ${_selectedRadius.toStringAsFixed(1)} km',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppTheme.accentColor,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMap(List<UMKM> nearbyUmkm) {
    if (_currentPosition == null) {
      return Center(
        child: Text(
          'Lokasi pengguna belum tersedia.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final filteredUmkm = _filterUmkm(nearbyUmkm);
    final markers = _buildMarkers(filteredUmkm);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppNumbers.paddingMedium,
        vertical: AppNumbers.paddingSmall,
      ),
      child: Material(
        elevation: AppNumbers.elevationMedium,
        borderRadius: BorderRadius.circular(AppNumbers.largeBorderRadius),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                ),
                zoom: 14,
              ),
              onMapCreated: (controller) {
                if (!_mapController.isCompleted) {
                  _mapController.complete(controller);
                }
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: markers,
              circles: {
                Circle(
                  circleId: const CircleId('radiusCircle'),
                  center: LatLng(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                  ),
                  radius: _selectedRadius * 1000,
                  fillColor: AppTheme.primaryColor.withOpacity(0.08),
                  strokeColor: AppTheme.primaryColor.withOpacity(0.35),
                  strokeWidth: 2,
                ),
              },
              zoomControlsEnabled: false,
              mapType: MapType.normal,
            ),
            Positioned(
              top: 14,
              right: 14,
              child: FloatingActionButton.small(
                onPressed: _moveCameraToCurrentLocation,
                backgroundColor: AppTheme.surfaceColor,
                child: const Icon(Icons.my_location,
                    color: AppTheme.primaryColor),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppNumbers.paddingMedium,
                  vertical: AppNumbers.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowColor,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.map_outlined,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${filteredUmkm.length} lokasi terdekat',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              'Tempat UMKM di dalam radius Anda',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Chip(
                      backgroundColor:
                          AppTheme.primaryLight.withOpacity(0.16),
                      label: Text(
                        '${_selectedRadius.toStringAsFixed(1)} km',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
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

  @override
  Widget build(BuildContext context) {
    final umkmState = ref.watch(umkmProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.navMarketMap,
      ),
      body: Column(
        children: [
          _buildSearchSection(umkmState),
          Expanded(
            child: _isLoadingLocation
                ? const Center(child: CircularProgressIndicator())
                : _locationError != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppNumbers.paddingLarge),
                          child: Text(
                            _locationError!,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : umkmState.when(
                        data: (umkmList) {
                          if (umkmList.isEmpty) {
                            return Center(
                              child: Text(
                                'Tidak ditemukan UMKM di radius ini.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            );
                          }
                          return _buildMap(umkmList);
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppNumbers.paddingLarge),
                            child: Text(
                              'Gagal memuat data UMKM. Silakan coba lagi.',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
