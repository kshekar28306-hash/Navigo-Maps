import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import '../services/location_service.dart';
import '../services/routing_engine.dart';
import '../models/waypoint.dart';
import 'map_screen.dart';

class NavigoLogo extends StatelessWidget {
  const NavigoLogo({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42, height: 42,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))]),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: Padding(padding: const EdgeInsets.all(5.0), child: CustomPaint(painter: NavigoVectorPainter()))),
          Container(width: 18, height: 18, decoration: const BoxDecoration(color: Color(0xFF4364F7), shape: BoxShape.circle), child: const Center(child: Icon(Icons.navigation, color: Colors.white, size: 11))),
        ],
      ),
    );
  }
}

class NavigoVectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 4.5;
    const double gap = 0.25;
    const double sweepAngle = (math.pi / 2) - gap;
    final basePaint = Paint()..style = PaintingStyle.stroke..strokeWidth = strokeWidth..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius - 2.25), -math.pi + (gap / 2), sweepAngle, false, basePaint..color = const Color(0xFFFF2A54));
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius - 2.25), -math.pi / 2 + (gap / 2), sweepAngle, false, basePaint..color = const Color(0xFF007AFF));
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius - 2.25), 0 + (gap / 2), sweepAngle, false, basePaint..color = const Color(0xFF34A853));
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius - 2.25), math.pi / 2 + (gap / 2), sweepAngle, false, basePaint..color = const Color(0xFFFFCC00));
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TelemetryLogo extends StatefulWidget {
  const TelemetryLogo({super.key});
  @override
  State<TelemetryLogo> createState() => _TelemetryLogoState();
}

class _TelemetryLogoState extends State<TelemetryLogo> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))..repeat();
  }
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76, height: 76,
      decoration: const BoxDecoration(color: Color(0xFFF4F7FF), shape: BoxShape.circle),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) => CustomPaint(painter: TelemetryAnimatedPainter(animationValue: _animationController.value)),
      ),
    );
  }
}

class TelemetryAnimatedPainter extends CustomPainter {
  final double animationValue;
  TelemetryAnimatedPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const Color primaryBlue = Color(0xFF4364F7);
    const Color neonCyan = Color(0xFF00E5FF);

    final gridPaint = Paint()..color = primaryBlue.withValues(alpha: 0.08)..style = PaintingStyle.stroke..strokeWidth = 1.5;
    canvas.drawCircle(center, radius - 4, gridPaint);
    canvas.drawCircle(center, radius - 16, gridPaint);

    final double pulseRadius = (radius - 4) * animationValue;
    if (pulseRadius > 4) {
      canvas.drawCircle(center, pulseRadius, Paint()..color = neonCyan.withValues(alpha: 0.45 * (1.0 - animationValue))..style = PaintingStyle.stroke..strokeWidth = 2.0);
    }

    final sweepPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        colors: [neonCyan.withValues(alpha: 0.0), primaryBlue.withValues(alpha: 0.15), primaryBlue],
        stops: const [0.0, 0.75, 1.0],
        transform: GradientRotation((animationValue * 2 * math.pi) - math.pi),
      ).createShader(Rect.fromCircle(center: center, radius: radius - 4))
      ..style = PaintingStyle.stroke..strokeWidth = 4.0;

    canvas.drawCircle(center, radius - 4, sweepPaint);
    canvas.drawCircle(center, 4.5, Paint()..color = primaryBlue..style = PaintingStyle.fill);
  }
  @override
  bool shouldRepaint(covariant TelemetryAnimatedPainter oldDelegate) => oldDelegate.animationValue != animationValue;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RoutingEngine _routingEngine = RoutingEngine();
  String _coordinatesMessage = "Click the button to scan coordinates";
  String _closestNodeMessage = "";
  bool _isLoading = false;
  double? _latitude; double? _longitude;
  Waypoint? _startNode; String? _selectedDestinationId;
  List<Waypoint> _calculatedPath = [];

  Future<void> _fetchGPSCoordinates() async {
    setState(() { _isLoading = true; _calculatedPath = []; });
    try {
      Position position = (await LocationService.getCurrentLocation())!;
      Waypoint? closestLandmark = _routingEngine.findClosestNode(position.latitude, position.longitude);
      setState(() {
        _latitude = position.latitude; _longitude = position.longitude;
        _coordinatesMessage = "Latitude: $_latitude\nLongitude: $_longitude";
        if (closestLandmark != null) {
          _startNode = closestLandmark;
          _closestNodeMessage = "📍 Current Node: ${closestLandmark.name}";
        }
        _isLoading = false;
      });
    } catch (error) {
      setState(() { _coordinatesMessage = "Error: $error"; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Waypoint> destinationOptions = _routingEngine.getAllVertices().where((v) => _startNode == null || v.id != _startNode!.id).toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true, elevation: 6, shadowColor: Colors.black45, backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF0052D4), Color(0xFF4364F7), Color(0xFF00E5FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
        ),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(24))),
        title: const Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [NavigoLogo(), SizedBox(width: 14), Text('NAVIGO', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 4.0))]),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Card(
                elevation: 6, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const TelemetryLogo(),
                      const SizedBox(height: 20),
                      const Text('Live Telemetry Stream', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4364F7))),
                      const SizedBox(height: 12),
                      _isLoading ? const CircularProgressIndicator() : Text(_coordinatesMessage, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: Colors.black87)),
                      if (_closestNodeMessage.isNotEmpty) ...[const Divider(height: 32), Text(_closestNodeMessage, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF005B8C)))],
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _fetchGPSCoordinates,
                        icon: const Icon(Icons.my_location), label: const Text('Scan Current Location'),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4364F7), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                      ),
                    ],
                  ),
                ),
              ),
              if (_startNode != null) ...[
                const SizedBox(height: 20),
                Card(
                  elevation: 6, color: Colors.blue.shade50, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Configure Pathfinding Target', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF005B8C)), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedDestinationId, hint: const Text('Select Target Destination'),
                          decoration: InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                          items: destinationOptions.map((v) => DropdownMenuItem<String>(value: v.id, child: Text(v.name, style: const TextStyle(fontSize: 14)))).toList(),
                          onChanged: (val) => setState(() { _selectedDestinationId = val; _calculatedPath = []; }),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _selectedDestinationId == null ? null : () => setState(() { _calculatedPath = _routingEngine.findShortestPath(_startNode!.id, _selectedDestinationId!); }),
                          icon: const Icon(Icons.alt_route), label: const Text('Calculate Fastest Path'),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4364F7), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (_calculatedPath.isNotEmpty) ...[
                const SizedBox(height: 20),
                Card(
                  elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Text('Optimal Path Sequence Found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: _calculatedPath.length,
                          itemBuilder: (context, index) {
                            bool isLast = index == _calculatedPath.length - 1;
                            return Column(
                              children: [
                                ListTile(
                                  leading: CircleAvatar(backgroundColor: isLast ? Colors.green : const Color(0xFF4364F7), foregroundColor: Colors.white, child: Text('${index + 1}')),
                                  title: Text(_calculatedPath[index].name, style: TextStyle(fontWeight: isLast ? FontWeight.bold : FontWeight.normal)),
                                  subtitle: Text('Node ID: ${_calculatedPath[index].id}'),
                                ),
                                if (!isLast) const Icon(Icons.arrow_downward, color: Colors.grey, size: 20),
                              ],
                            );
                          },
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Divider()),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MapScreen(latitude: _latitude!, longitude: _longitude!, routingPath: _calculatedPath))),
                          icon: const Icon(Icons.map), label: const Text('View Route on Live Map'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), textStyle: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}