import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import '../../../bloc/location/location_cubit.dart';
import '../../../bloc/location/location_state.dart';

const _kMapBg = Color(0xFF2A3D38);
const _kRed = Color(0xFFBF3847);

/// Small live map thumbnail showing the device's current GPS location —
/// the marker recenters smoothly as the device moves. Reads its position
/// from the shared [LocationCubit] (provided above the "Current Location"
/// card) so the marker and the place-name text next to it always reflect
/// the exact same fix.
///
/// Rendered with `flutter_map` on OpenStreetMap tiles — a pure Flutter
/// widget with no platform channel of its own, so it renders identically
/// on iOS once that build target is added.
class LiveLocationMap extends StatefulWidget {
  const LiveLocationMap({super.key});

  @override
  State<LiveLocationMap> createState() => _LiveLocationMapState();
}

class _LiveLocationMapState extends State<LiveLocationMap> {
  final _mapController = MapController();
  ll.LatLng? _lastCentered;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, state) {
        final lat = state.latitude;
        final lng = state.longitude;
        if (state.status != LocationStatus.ready ||
            lat == null ||
            lng == null) {
          return _MapPlaceholder(status: state.status);
        }

        final position = ll.LatLng(lat, lng);

        // The very first fix is rendered via MapOptions.initialCenter on
        // build — the map isn't attached yet at that point, so only call
        // .move() for the recenters that happen after it's already on
        // screen (i.e. once _lastCentered has a previous value).
        if (_lastCentered != null && _lastCentered != position) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _mapController.move(position, _mapController.camera.zoom);
            }
          });
        }
        _lastCentered = position;

        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: position,
              initialZoom: 16,
              // Decorative thumbnail, not a navigable map — keep it from
              // fighting the page's own scroll/drag gestures.
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.none,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.etapms',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: position,
                    width: 26,
                    height: 26,
                    child: const Icon(
                      Icons.location_on,
                      color: _kRed,
                      size: 26,
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
}

class _MapPlaceholder extends StatelessWidget {
  final LocationStatus status;

  const _MapPlaceholder({required this.status});

  @override
  Widget build(BuildContext context) {
    final icon = switch (status) {
      LocationStatus.denied => Icons.location_disabled,
      LocationStatus.disabled => Icons.location_off,
      LocationStatus.error => Icons.error_outline,
      LocationStatus.loading || LocationStatus.ready => Icons.my_location,
    };

    return Container(
      decoration: BoxDecoration(
        color: _kMapBg,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: status == LocationStatus.loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white70,
              ),
            )
          : Icon(icon, color: Colors.white38, size: 20),
    );
  }
}
