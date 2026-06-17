import 'dart:math' as math;
import '../models/waypoint.dart';

class RoutingEngine {
  // ==========================================================
  // PRE-LOADED DATA: A connected 5-node test network in Bangalore
  // ==========================================================
  final List<Waypoint> _vertices = [
    Waypoint(
        id: '1',
        name: 'Alpha Hub (Start)',
        latitude: 12.9770,
        longitude: 77.5946,
        connections: {'2': 110.0, '5': 150.0}
    ),
    Waypoint(
        id: '2',
        name: 'Beta Core',
        latitude: 12.9780,
        longitude: 77.5950,
        connections: {'1': 110.0, '3': 120.0, '4': 140.0}
    ),
    Waypoint(
        id: '3',
        name: 'Gamma Labs',
        latitude: 12.9790,
        longitude: 77.5940,
        connections: {'2': 120.0}
    ),
    Waypoint(
        id: '4',
        name: 'Delta Server Room',
        latitude: 12.9785,
        longitude: 77.5960,
        connections: {'2': 140.0}
    ),
    Waypoint(
        id: '5',
        name: 'Omega Exit',
        latitude: 12.9760,
        longitude: 77.5930,
        connections: {'1': 150.0}
    ),
  ];

  List<Waypoint> getAllVertices() => _vertices;

  /// Uses the Haversine formula to calculate true Earth-surface distance
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371000;
    final double dLat = (lat2 - lat1) * math.pi / 180.0;
    final double dLon = (lon2 - lon1) * math.pi / 180.0;

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180.0) * math.cos(lat2 * math.pi / 180.0) *
            math.sin(dLon / 2) * math.sin(dLon / 2);

    return R * (2 * math.atan2(math.sqrt(a), math.sqrt(1 - a)));
  }

  /// Finds the physical node closest to the user's raw GPS coordinates
  Waypoint? findClosestNode(double currentLat, double currentLng) {
    if (_vertices.isEmpty) return null;

    Waypoint? closestNode;
    double minDistance = double.infinity;

    for (var node in _vertices) {
      double distance = calculateDistance(currentLat, currentLng, node.latitude, node.longitude);
      if (distance < minDistance) {
        minDistance = distance;
        closestNode = node;
      }
    }
    return closestNode;
  }

  // Safe fallback to replace the `.firstOrNull` syntax
  Waypoint? _getNodeById(String id) {
    var matches = _vertices.where((v) => v.id == id);
    return matches.isNotEmpty ? matches.first : null;
  }

  /// ==========================================
  /// CORE ALGORITHM: A* (A-Star) PATHFINDING
  /// ==========================================
  List<Waypoint> findShortestPath(String startId, String targetId) {
    Waypoint? startNode = _getNodeById(startId);
    Waypoint? targetNode = _getNodeById(targetId);

    if (startNode == null || targetNode == null) return [];

    Map<String, double> gScore = { for (var v in _vertices) v.id : double.infinity };
    gScore[startId] = 0.0;

    Map<String, double> fScore = { for (var v in _vertices) v.id : double.infinity };
    fScore[startId] = calculateDistance(startNode.latitude, startNode.longitude, targetNode.latitude, targetNode.longitude);

    List<Waypoint> openSet = [startNode];
    Map<String, String> cameFrom = {};

    while (openSet.isNotEmpty) {
      openSet.sort((a, b) => fScore[a.id]!.compareTo(fScore[b.id]!));
      Waypoint current = openSet.removeAt(0);

      if (current.id == targetId) {
        List<Waypoint> totalPath = [current];
        String currId = current.id;
        while (cameFrom.containsKey(currId)) {
          currId = cameFrom[currId]!;
          Waypoint prevNode = _getNodeById(currId)!;
          totalPath.insert(0, prevNode);
        }
        return totalPath;
      }

      current.connections.forEach((neighborId, weight) {
        double tentativeGScore = gScore[current.id]! + weight;

        if (tentativeGScore < (gScore[neighborId] ?? double.infinity)) {
          cameFrom[neighborId] = current.id;
          gScore[neighborId] = tentativeGScore;

          Waypoint neighborNode = _getNodeById(neighborId)!;
          double hScore = calculateDistance(neighborNode.latitude, neighborNode.longitude, targetNode.latitude, targetNode.longitude);
          fScore[neighborId] = tentativeGScore + hScore;

          if (!openSet.any((node) => node.id == neighborId)) {
            openSet.add(neighborNode);
          }
        }
      });
    }

    return [];
  }
}