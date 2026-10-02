import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/app_models.dart';
import '../../services/bus_repository.dart';
import '../../services/location_service.dart';

class NearbyStopsScreen extends StatefulWidget {
  const NearbyStopsScreen({super.key});

  @override
  State<NearbyStopsScreen> createState() => _NearbyStopsScreenState();
}

class _NearbyStopsScreenState extends State<NearbyStopsScreen> {
  LatLng? me;
  List<Map<String, dynamic>> rows = [];
  bool busy = true;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final p = await LocationService().currentPosition();
      final stops = await BusRepository().getActiveStops();

      final list = stops.map((BusStop s) {
        final km = LocationService().distanceKm(
          p.latitude,
          p.longitude,
          s.latitude,
          s.longitude,
        );

        return {
          'stop': s,
          'km': km,
        };
      }).toList()
        ..sort(
              (a, b) => (a['km'] as double).compareTo(
            b['km'] as double,
          ),
        );

      if (!mounted) return;

      setState(() {
        me = LatLng(
          p.latitude,
          p.longitude,
        );
        rows = list;
        busy = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Bus Stops'),
      ),
      body: busy
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 50,
              ),
              const SizedBox(height: 16),
              Text(
                error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  setState(() {
                    busy = true;
                    error = null;
                  });

                  load();
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      )
          : Column(
        children: [
          SizedBox(
            height: 300,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: me!,
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName:
                  'com.example.sakhi_pravas',
                ),

                MarkerLayer(
                  markers: [
                    Marker(
                      point: me!,
                      width: 60,
                      height: 60,
                      child: const Tooltip(
                        message: 'Your Location',
                        child: Icon(
                          Icons.my_location,
                          size: 34,
                          color: Colors.blue,
                        ),
                      ),
                    ),

                    ...rows.map(
                          (r) {
                        final s = r['stop'] as BusStop;

                        return Marker(
                          point: LatLng(
                            s.latitude,
                            s.longitude,
                          ),
                          width: 60,
                          height: 60,
                          child: Tooltip(
                            message:
                            '${s.stopName}\n${s.village}',
                            child: const Icon(
                              Icons.location_on,
                              size: 40,
                              color: Colors.red,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: rows.map((r) {
                final s = r['stop'] as BusStop;
                final km = r['km'] as double;

                final walk =
                ((km / 4.5) * 60).round();

                return Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.location_on_outlined,
                    ),
                    title: Text(
                      s.stopName,
                    ),
                    subtitle: Text(
                      '${s.village} • '
                          '${km.toStringAsFixed(2)} km • '
                          'approx. $walk min walk',
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}