import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'location_state.dart';

/// Fetches the device's current GPS position and reverse-geocodes it into
/// a human-readable place name — shared by the "Current Location" card's
/// text and its live map so both always reflect the exact same fix.
///
/// Built on `geolocator` + `geocoding`, both pure-Dart plugins with
/// first-class iOS implementations (geolocator_apple, geocoding_darwin)
/// already resolved — no extra native wiring needed when iOS is added.
class LocationCubit extends Cubit<LocationState> {
  // Constructed lazily (not as a field initializer) so a platform without
  // the geocoding plugin registered can't crash the cubit at construction
  // time — it's only touched inside the try/catch in _onPosition.
  Geocoding? _geocoding;
  StreamSubscription<Position>? _positionSub;

  LocationCubit() : super(const LocationState()) {
    _start();
  }

  Future<void> _start() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(state.copyWith(status: LocationStatus.disabled));
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        emit(state.copyWith(status: LocationStatus.denied));
        return;
      }

      final initial = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      await _onPosition(initial);

      _positionSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          // Only push an update once the device has moved ~10m, so the
          // marker/place name don't jitter from GPS noise while still.
          distanceFilter: 10,
        ),
      ).listen(_onPosition, onError: (_) {
        if (!isClosed) emit(state.copyWith(status: LocationStatus.error));
      });
    } catch (_) {
      if (!isClosed) emit(state.copyWith(status: LocationStatus.error));
    }
  }

  Future<void> _onPosition(Position position) async {
    if (isClosed) return;
    emit(state.copyWith(
      status: LocationStatus.ready,
      latitude: position.latitude,
      longitude: position.longitude,
    ));

    try {
      final geocoding = _geocoding ??= Geocoding();
      final placemarks = await geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (isClosed || placemarks.isEmpty) return;

      final p = placemarks.first;
      final name = _firstNonEmpty([
        p.locality,
        p.subAdministrativeArea,
        p.administrativeArea,
        p.country,
      ]);
      if (name != null) emit(state.copyWith(placeName: name));
    } catch (_) {
      // Keep the coordinates/marker even if the reverse-geocode lookup
      // fails (e.g. no network) — the place name simply stays unset.
    }
  }

  String? _firstNonEmpty(List<String?> values) {
    for (final v in values) {
      if (v != null && v.isNotEmpty) return v;
    }
    return null;
  }

  @override
  Future<void> close() {
    _positionSub?.cancel();
    return super.close();
  }
}
