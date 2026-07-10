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
    {'name': 'Warung Bu Sari',   'cat': 'Makanan',    'rating': 4.8, 'verified': true,  'lat': -6.9175, 'lng': 107.6191},
    {'name': 'Kopi Nusantara',   'cat': 'Minuman',    'rating': 4.9, 'verified': true,  'lat': -6.9100, 'lng': 107.6250},
    {'name': 'Batik Garuda',     'cat': 'Fashion',    'rating': 4.9, 'verified': true,  'lat': -6.9300, 'lng': 107.6350},
    {'name': 'Kerajinan Jaya',   'cat': 'Kerajinan',  'rating': 4.7, 'verified': false, 'lat': -6.9050, 'lng': 107.6150},
  ];

  // Default center (Bandung) sebelum lokasi user didapat
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

  @override
  Widget build(BuildContext context) {
    final sorted = _sortedUmkms;

    return Scaffold(
      appBar: AppBar(title: const Text('Peta UMKM Terdekat')),
      body: Column(children: [
        // Peta sungguhan (OpenStreetMap via flutter_map)
        SizedBox(
          height: 280,
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
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () => AppSnackBar.show(
                            context,
                            '🏪 ${u['name']} — ${_fmtDist(u).replaceAll('-', 'aktifkan lokasi dulu')}',
                          ),
                          child: const Icon(Icons.location_on, size: 36, color: Colors.redAccent),
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
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                  ),
                ),
              ),
          ]),
        ),
        // Info bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppTheme.surface,
          child: Row(children: [
            const Icon(Icons.location_on, size: 14, color: AppTheme.primary),
            const SizedBox(width: 4),
            Text(_locationLabel ?? '-', style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 12),
            const Icon(Icons.radar, size: 14, color: AppTheme.textHint),
            const SizedBox(width: 4),
            const Text('Radius: 5 km', style: TextStyle(fontSize: 12)),
            const Spacer(),
            Text('${_umkms.length} UMKM', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primary)),
          ]),
        ),
        const Divider(height: 1),
        // UMKM list (terurut berdasarkan jarak jika lokasi aktif)
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(14),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final u = sorted[i];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surface, borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text(u['name'].toString().substring(0, 1),
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text(u['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      if (u['verified'] == true) ...[
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(4)),
                          child: const Text('✓', style: TextStyle(fontSize: 9, color: Color(0xFF15803D), fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ]),
                    const SizedBox(height: 3),
                    Text('📍 ${_fmtDist(u)} · ${u['cat']} · ⭐ ${u['rating']}',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
                  ])),
                  OutlinedButton.icon(
                    onPressed: () => _openNavigation(u['lat'], u['lng'], u['name']),
                    icon: const Icon(Icons.navigation_outlined, size: 14),
                    label: const Text('Navigasi', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                  ),
                ]),
              );
            },
          ),
        ),
      ]),
    );
  }
}