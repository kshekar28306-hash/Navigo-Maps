import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteData {
  final List<LatLng> path;
  final double distanceMeters;
  final double durationSeconds;
  RouteData({required this.path, required this.distanceMeters, required this.durationSeconds});
}

class RealStreetRoutingService {

  // 1. STANDARD ENGINE (Point A to Point B)
  Future<RouteData?> getRealRoadDirections(LatLng start, LatLng destination, {String profile = 'driving'}) async {
    final url = 'https://router.project-osrm.org/route/v1/$profile/${start.longitude},${start.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List coordinates = data['routes'][0]['geometry']['coordinates'];
        final double distance = data['routes'][0]['distance'].toDouble();
        final double duration = data['routes'][0]['duration'].toDouble();

        List<LatLng> path = coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
        return RouteData(path: path, distanceMeters: distance, durationSeconds: duration);
      }
    } catch (e) {
      debugPrint("Street Routing Error: $e");
    }
    return null;
  }

  // 2. MULTI-STOP ENGINE (Point A -> B -> C -> D)
  Future<RouteData?> getMultiStopRoute(List<LatLng> waypoints, {String profile = 'driving'}) async {
    if (waypoints.length < 2) return null; // Requires at least a start and end

    // Dynamically chains all coordinates together for the OSRM server
    String coords = waypoints.map((w) => '${w.longitude},${w.latitude}').join(';');
    final url = 'https://router.project-osrm.org/route/v1/$profile/$coords?overview=full&geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final List coordinates = data['routes'][0]['geometry']['coordinates'];
          final double distance = data['routes'][0]['distance'].toDouble();
          final double duration = data['routes'][0]['duration'].toDouble();

          List<LatLng> path = coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
          return RouteData(path: path, distanceMeters: distance, durationSeconds: duration);
        }
      }
    } catch (e) {
      debugPrint("Multi-Stop Error: $e");
    }
    return null;
  }

  // 3. SEARCH ENGINE
  Future<List<Map<String, dynamic>>> getSearchSuggestions(String query, double userLat, double userLon) async {
    if (query.isEmpty) return [];
    double offset = 0.5;
    String viewbox = '${userLon - offset},${userLat - offset},${userLon + offset},${userLat + offset}';
    final url = 'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=10&addressdetails=1&viewbox=$viewbox&bounded=0';

    try {
      final response = await http.get(Uri.parse(url), headers: {'User-Agent': 'NavigoApp'}).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        const distanceCalc = Distance();
        List<Map<String, dynamic>> results = data.map((item) {
          double lat = double.parse(item['lat']);
          double lon = double.parse(item['lon']);
          double distMeters = distanceCalc.as(LengthUnit.Meter, LatLng(userLat, userLon), LatLng(lat, lon));
          return { 'display_name': item['display_name'], 'lat': lat, 'lon': lon, 'distance_meters': distMeters };
        }).toList();

        results.sort((a, b) => a['distance_meters'].compareTo(b['distance_meters']));
        return results.take(5).toList();
      }
    } catch (e) {
      debugPrint("Suggestions Error: $e");
    }
    return [];
  }
}