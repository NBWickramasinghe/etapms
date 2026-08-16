import 'package:equatable/equatable.dart';

enum LocationStatus { loading, ready, denied, disabled, error }

class LocationState extends Equatable {
  final LocationStatus status;
  final double? latitude;
  final double? longitude;
  final String? placeName;

  const LocationState({
    this.status = LocationStatus.loading,
    this.latitude,
    this.longitude,
    this.placeName,
  });

  LocationState copyWith({
    LocationStatus? status,
    double? latitude,
    double? longitude,
    String? placeName,
  }) =>
      LocationState(
        status: status ?? this.status,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        placeName: placeName ?? this.placeName,
      );

  @override
  List<Object?> get props => [status, latitude, longitude, placeName];
}
