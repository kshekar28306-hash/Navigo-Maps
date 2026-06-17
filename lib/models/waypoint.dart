import 'package:latlong2/latlong.dart';

class Waypoint {
  final String id;
  final String name;
  final double latitude;
  final double longitude;

  // ➔ THE MISSING PIECE: Maps neighboring Waypoint IDs to their edge weights (distance)
  final Map<String, double> connections;

  Waypoint({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.connections = const {}, // Defaults to an empty map if no connections are passed
  });

  // Helper method to easily drop this point onto the Flutter Map
  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }
}