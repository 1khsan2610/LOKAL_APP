import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_theme.dart';
import '../../widgets/product_card.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  final List<Map<String, dynamic>> _umkms = [
    {'name': 'Warung Bu Sari',   'cat': 'Makanan',    'rating': 4.8, 'verified': true,  'lat': -6.9175, 'lng': 107.6191, 'address': 'Jl. Nagrog No.815, Pasirwangi, Kec. Ujung Berung, Kota Bandung'},
    {'name': 'Kopi Nusantara',   'cat': 'Minuman',    'rating': 4.9, 'verified': true,  'lat': -6.9100, 'lng': 107.6250, 'address': 'Jl. Dipatiukur No.112, Bandung'},
    {'name': 'Batik Garuda',     'cat': 'Fashion',    'rating': 4.9, 'verified': true,  'lat': -6.9300, 'lng': 107.6350, 'address': 'Jl. Cihampelas No.45, Bandung'},
    {'name': 'Kerajinan Jaya',   'cat': 'Kerajinan',  'rating': 4.7, 'verified': false, 'lat': -6.9050, 'lng': 107.6150, 'address': 'Jl. Setiabudi No.200, Bandung'},
  ];

  static const LatLng _defaultCenter = LatLng(-6.9175, 107.6350);

  Position? _userPosition;
  bool _loadingLocation = false;
  String? _locationLabel = 'Bandung, Jawa Barat';

  @override
  void dispose() {
    super.dispose();
  }

  List<Map<String, dynamic>> get _sortedUmkms {
    final list = List<Map<String, dynamic>>.from(_umkms);
    if (_userPosition != null) {
      for (final u in list) {
        final meters = Geolocator.distanceBetween(
          _userPosition!.latitude, _userPosition!.longitude,
          u['lat'], u['lng'],
        );
        u['distMeters'] = meters;
      }
      list.sort((a, b) => (a['distMeters'] as double).compareTo(b['distMeters'] as double));
    }
    return list;
  }

  String _fmtDist(Map<String, dynamic> u) {
    if (u['distMeters'] == null) return '-';
    final m = u['distMeters'] as double;
    return m < 1000 ? '${m.toStringAsFixed(0)} m' : '${(m / 1000).toStringAsFixed(1)} km';
  }

  Future<void> _activateLocation() async {
    setState(() => _loadingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!mounted) return;
      if (!serviceEnabled) {
        AppSnackBar.show(context, '⚠️ Aktifkan layanan lokasi (GPS) di perangkatmu');
        setState(() => _loadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (!mounted) return;
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (!mounted) return;
        if (permission == LocationPermission.denied) {
          AppSnackBar.show(context, '⚠️ Izin lokasi ditolak');
          setState(() => _loadingLocation = false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        AppSnackBar.show(context, '⚠️ Izin lokasi diblokir permanen. Aktifkan lewat pengaturan aplikasi.');
        setState(() => _loadingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (!mounted) return;
      setState(() {
        _userPosition = position;
        _locationLabel = 'Lokasi kamu saat ini';
        _loadingLocation = false;
      });

      _mapController.move(LatLng(position.latitude, position.longitude), 14);
      AppSnackBar.show(context, '📍 Lokasi berhasil diaktifkan');
    } catch (e) {
      setState(() => _loadingLocation = false);
      AppSnackBar.show(context, '⚠️ Gagal mengambil lokasi: $e');
    }
  }

  Future<void> _openNavigation(double lat, double lng, String name) async {
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    final canLaunch = await canLaunchUrl(uri);
    if (!mounted) return;
    if (canLaunch) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      AppSnackBar.show(context, '⚠️ Tidak bisa membuka aplikasi peta');
    }
  }

  Future<void> _openNavigationAddress(String address, String name) async {
    final encoded = Uri.encodeComponent(address);
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$encoded');
    final canLaunch = await canLaunchUrl(uri);
    if (!mounted) return;
    if (canLaunch) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      AppSnackBar.show(context, '⚠️ Tidak bisa membuka aplikasi peta');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sorted = _sortedUmkms;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Peta UMKM Terdekat'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.my_location,
              color: _userPosition != null ? AppTheme.accent : Colors.white,
            ),
            onPressed: _activateLocation,
            tooltip: 'Aktifkan lokasi',
          ),
        ],
      ),
      body: Column(children: [
        // ── Peta ─────────────────────────────────────────────────────
        SizedBox(
          height: 300,
          child: Stack(children: [
            FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: _defaultCenter,
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.ekonomilokal.app',
                ),
                MarkerLayer(
                  markers: [
                    for (final u in _umkms)
                      Marker(
                        point: LatLng(u['lat'], u['lng']),
                        width: 80,
                        height: 80,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Custom marker bubble
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                u['name'].toString().length > 12
                                    ? '${u['name'].toString().substring(0, 12)}..'
                                    : u['name'].toString(),
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Icon(Icons.location_on, size: 32, color: Colors.redAccent),
                          ],
                        ),
                      ),
                    if (_userPosition != null)
                      Marker(
                        point: LatLng(_userPosition!.latitude, _userPosition!.longitude),
                        width: 24,
                        height: 24,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (_userPosition == null)
              Positioned(
                left: 0, right: 0, bottom: 12,
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: _loadingLocation ? null : _activateLocation,
                    icon: _loadingLocation
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.my_location, size: 16),
                    label: Text(_loadingLocation ? 'Mengambil lokasi...' : 'Aktifkan Lokasi'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
              ),
          ]),
        ),
        // ── Info bar ─────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: AppTheme.surface,
          child: Row(children: [
            Icon(Icons.location_on, size: 16, color: AppTheme.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _locationLabel ?? '-',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.radar, size: 14, color: AppTheme.textHint),
            const SizedBox(width: 4),
            const Text('Radius: 5 km', style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_umkms.length} UMKM',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primary),
              ),
            ),
          ]),
        ),
        const Divider(height: 1),
        // ── Daftar UMKM ──────────────────────────────────────────────
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(14),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final u = sorted[i];
              final initial = u['name'].toString().substring(0, 1).toUpperCase();
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      // Avatar with initial
                      Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1966D2), Color(0xFF4285F4)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(child: Text(initial,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Flexible(child: Text(u['name'],
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          )),
                          if (u['verified'] == true) ...[
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.verified, size: 10, color: Color(0xFF15803D)),
                                SizedBox(width: 2),
                                Text('Terverifikasi', style: TextStyle(fontSize: 8, color: Color(0xFF15803D), fontWeight: FontWeight.w600)),
                              ]),
                            ),
                          ],
                        ]),
                        const SizedBox(height: 4),
                        Row(children: [
                          Icon(Icons.star_rounded, size: 13, color: AppTheme.warning),
                          const SizedBox(width: 2),
                          Text(u['rating'].toString(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          Container(width: 1, height: 10, color: AppTheme.border),
                          const SizedBox(width: 8),
                          Icon(Icons.category_outlined, size: 11, color: AppTheme.textHint),
                          const SizedBox(width: 2),
                          Text(u['cat'], style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
                          const SizedBox(width: 8),
                          Container(width: 1, height: 10, color: AppTheme.border),
                          const SizedBox(width: 8),
                          Icon(Icons.location_on, size: 11, color: AppTheme.textHint),
                          const SizedBox(width: 2),
                          Text(_fmtDist(u), style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
                        ]),
                      ])),
                    ]),
                    const SizedBox(height: 10),
                    // Address info + navigation button
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.surface2.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textHint),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    u['address'] ?? 'Alamat tidak tersedia',
                                    style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 36,
                          child: ElevatedButton.icon(
                            onPressed: u['address'] != null
                                ? () => _openNavigationAddress(u['address'], u['name'])
                                : () => _openNavigation(u['lat'], u['lng'], u['name']),
                            icon: const Icon(Icons.navigation_outlined, size: 16),
                            label: const Text('Navigasi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}