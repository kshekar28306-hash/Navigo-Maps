import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:geolocator/geolocator.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:google_fonts/google_fonts.dart'; // ➔ NEW: Google Fonts Import
import 'dart:async';
import 'dart:math';
import '../services/street_routing.dart';
import '../models/waypoint.dart';
import 'shortest_path_screen.dart';

class NavigoLogo extends StatelessWidget {
  const NavigoLogo({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 3))]
      ),
      child: CustomPaint(
        painter: NavigoLogoPainter(),
      ),
    );
  }
}

class NavigoLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    final Paint bezelPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFB3E5FC), Color(0xFF1565C0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, w / 2, bezelPaint);

    final Paint innerPlatePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, w * 0.42, innerPlatePaint);

    final Offset tip = Offset(w * 0.5, h * 0.15);
    final Offset bLeft = Offset(w * 0.22, h * 0.82);
    final Offset bRight = Offset(w * 0.78, h * 0.82);
    final Offset indent = Offset(w * 0.5, h * 0.65);

    final Path leftArrow = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(bLeft.dx, bLeft.dy)
      ..lineTo(indent.dx, indent.dy)
      ..close();
    final Paint leftPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF1744), Color(0xFF900000)],
        begin: Alignment.topCenter,
        end: Alignment.bottomLeft,
      ).createShader(Rect.fromLTWH(0, 0, w/2, h));
    canvas.drawPath(leftArrow, leftPaint);

    final Path rightArrow = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(bRight.dx, bRight.dy)
      ..lineTo(indent.dx, indent.dy)
      ..close();
    final Paint rightPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFB300), Color(0xFFE65100)],
        begin: Alignment.topCenter,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(w/2, 0, w/2, h));
    canvas.drawPath(rightArrow, rightPaint);

    final Path glossPath = Path()
      ..addOval(Rect.fromLTRB(w * 0.1, h * 0.02, w * 0.9, h * 0.45));
    final Paint glossPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.white.withValues(alpha: 0.6), Colors.white.withValues(alpha: 0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(glossPath, glossPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GoogleCompassIcon extends StatelessWidget {
  const GoogleCompassIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 12,
      height: 24,
      child: CustomPaint(
        painter: CompassPainter(),
      ),
    );
  }
}

class CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint redPaint = Paint()..color = const Color(0xFFD32F2F)..style = PaintingStyle.fill;
    final Paint greyPaint = Paint()..color = const Color(0xFFBDBDBD)..style = PaintingStyle.fill;

    final Path redPath = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(0, size.height / 2)
      ..close();

    final Path greyPath = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(0, size.height / 2)
      ..close();

    canvas.drawPath(redPath, redPaint);
    canvas.drawPath(greyPath, greyPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class IdleHumanMarker extends StatelessWidget {
  final double heading;
  final double pulse;
  const IdleHumanMarker({super.key, this.heading = 0, this.pulse = 0});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.rotate(
          angle: heading * pi / 180,
          child: SizedBox(
            width: 140, height: 140,
            child: CustomPaint(painter: ViewConePainter(pulse: pulse)),
          ),
        ),
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0052D4), Color(0xFF4364F7), Color(0xFF00E5FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3.5),
            boxShadow: const [
              BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 5)),
              BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: const Center(
            child: Icon(Icons.accessibility_new_rounded, color: Colors.white, size: 18),
          ),
        ),
      ],
    );
  }
}

class ViewConePainter extends CustomPainter {
  final double pulse;
  ViewConePainter({this.pulse = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00E5FF).withValues(alpha: 0.8 - (pulse * 0.4)),
          const Color(0xFF4364F7).withValues(alpha: 0.0)
        ],
      ).createShader(Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2));

    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2),
      -pi / 2 - (pi / 3),
      pi / 1.5,
      true,
      paint,
    );
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PerfectDestinationPin extends StatelessWidget {
  const PerfectDestinationPin({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -16),
      child: SizedBox(
        width: 24,
        height: 36,
        child: CustomPaint(
          painter: ExactPinPainter(),
        ),
      ),
    );
  }
}

class ExactPinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint redFill = Paint()..color = const Color(0xFFDE2A2A)..style = PaintingStyle.fill;
    final Paint whiteFill = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final Paint shadowPaint = Paint()
      ..color = Colors.black26
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    Path pinPath = Path();
    pinPath.moveTo(12, 34);

    pinPath.quadraticBezierTo(23, 23, 23, 12);

    pinPath.arcToPoint(const Offset(1, 12), radius: const Radius.circular(11), clockwise: false);

    pinPath.quadraticBezierTo(1, 23, 12, 34);
    pinPath.close();

    canvas.drawPath(pinPath.shift(const Offset(0, 2)), shadowPaint);
    canvas.drawPath(pinPath, redFill);

    canvas.drawCircle(const Offset(12, 12), 4.5, whiteFill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AnimatedFireMic extends StatefulWidget {
  final bool isListening;
  const AnimatedFireMic({super.key, this.isListening = false});
  @override
  State<AnimatedFireMic> createState() => _AnimatedFireMicState();
}

class _AnimatedFireMicState extends State<AnimatedFireMic> with SingleTickerProviderStateMixin {
  late AnimationController _fireController;
  @override
  void initState() {
    super.initState();
    _fireController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }
  @override
  void dispose() {
    _fireController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fireController,
      builder: (context, child) {
        return Container(
          decoration: widget.isListening ? BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.redAccent.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 2)]
          ) : null,
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                colors: const [Color(0xFFFF0000), Color(0xFFFFC544), Color(0xFFCC0000)],
                stops: [0.0, 0.3 + (_fireController.value * 0.4), 1.0],
                transform: const GradientRotation(338 * pi / 180),
              ).createShader(bounds);
            },
            child: const Icon(Icons.mic, color: Colors.white, size: 28),
          ),
        );
      },
    );
  }
}

class AnimatedFireModeSelector extends StatefulWidget {
  final String currentMode;
  final Function(String) onModeSelected;

  const AnimatedFireModeSelector({
    super.key,
    required this.currentMode,
    required this.onModeSelected,
  });

  @override
  State<AnimatedFireModeSelector> createState() => _AnimatedFireModeSelectorState();
}

class _AnimatedFireModeSelectorState extends State<AnimatedFireModeSelector> with SingleTickerProviderStateMixin {
  late AnimationController _fireController;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _fireController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _fireController.dispose();
    super.dispose();
  }

  IconData _getIconForMode(String mode) {
    if (mode == 'walk') return Icons.directions_walk;
    if (mode == '2w') return Icons.two_wheeler;
    if (mode == '4w') return Icons.directions_car;
    return Icons.navigation;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutBack,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withValues(alpha: _isOpen ? 0.2 : 0.4),
            blurRadius: _isOpen ? 8 : 12,
            spreadRadius: _isOpen ? 1 : 2,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: _isOpen ? 16 : 6, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_isOpen)
            GestureDetector(
              onTap: () => setState(() => _isOpen = true),
              child: AnimatedBuilder(
                animation: _fireController,
                builder: (context, child) {
                  return ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        colors: const [Color(0xFFFF0000), Color(0xFFFFC544), Color(0xFFCC0000)],
                        stops: [0.0, 0.3 + (_fireController.value * 0.4), 1.0],
                        transform: const GradientRotation(338 * pi / 180),
                      ).createShader(bounds);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: Icon(_getIconForMode(widget.currentMode), color: Colors.white, size: 28),
                    ),
                  );
                },
              ),
            ),

          if (_isOpen) ...[
            _buildOption('walk', Icons.directions_walk),
            const SizedBox(width: 16),
            _buildOption('2w', Icons.two_wheeler),
            const SizedBox(width: 16),
            _buildOption('4w', Icons.directions_car),
            const SizedBox(width: 12),
            Container(width: 1, height: 24, color: Colors.grey.shade300),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => _isOpen = false),
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(Icons.close, size: 22, color: Colors.grey),
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildOption(String mode, IconData icon) {
    bool isSelected = widget.currentMode == mode;
    return GestureDetector(
      onTap: () {
        widget.onModeSelected(mode);
        setState(() => _isOpen = false);
      },
      child: AnimatedBuilder(
        animation: _fireController,
        builder: (context, child) {
          if (isSelected) {
            return ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  colors: const [Color(0xFFFF0000), Color(0xFFFFC544), Color(0xFFCC0000)],
                  stops: [0.0, 0.3 + (_fireController.value * 0.4), 1.0],
                  transform: const GradientRotation(338 * pi / 180),
                ).createShader(bounds);
              },
              child: Icon(icon, color: Colors.white, size: 28),
            );
          } else {
            return Icon(icon, color: Colors.grey.shade400, size: 26);
          }
        },
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final List<Waypoint>? routingPath;
  const MapScreen({super.key, required this.latitude, required this.longitude, this.routingPath});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final RealStreetRoutingService _streetService = RealStreetRoutingService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  late AnimationController _pulseController, _gradientController;
  late Animation<Alignment> _gradientTop, _gradientBottom;
  StreamSubscription<Position>? _gpsStreamSubscription;
  Timer? _debounceTimer;
  late double _liveLat, _liveLng;
  LatLng? _activeDestination;
  String _destinationName = "None";
  List<LatLng> _realStreetPath = [];

  List<Map<String, dynamic>> _suggestionsList = [];
  final List<Map<String, dynamic>> _searchHistory = [];

  bool _isFetchingRoute = false, _isSearchingSuggestions = false;
  int _currentPathIndex = 0;
  String _hudInstruction = "Awaiting destination coordinates...";
  double _apiTotalDistance = 0.0, _apiTotalDuration = 0.0;
  String _distanceRemaining = "-- km", _timeRemaining = "-- min";

  String _selectedMode = 'default';
  double _currentHeading = 0.0;

  String _baseMapStyle = 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}';
  final Set<String> _activeOverlays = {};

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    debugPrint("MapScreen: Initializing state...");
    _liveLat = widget.latitude; _liveLng = widget.longitude;

    if (widget.routingPath != null && widget.routingPath!.isNotEmpty) {
      _realStreetPath = widget.routingPath!.map((w) => w.toLatLng()).toList();
      _activeDestination = _realStreetPath.last;
      _destinationName = widget.routingPath!.last.name.toUpperCase();
      _hudInstruction = "Displaying pre-calculated path sequence.";
    }

    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat();
    _gradientController = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat(reverse: true);
    _gradientTop = Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.topRight).animate(_gradientController);
    _gradientBottom = Tween<Alignment>(begin: Alignment.bottomRight, end: Alignment.bottomLeft).animate(_gradientController);

    _searchFocusNode.addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint("MapScreen: First frame rendered, starting background tasks...");
      _initializeLiveTracking();
      _initSpeech();
    });
  }

  void _initSpeech() async {
    try {
      debugPrint("MapScreen: Initializing Speech to Text...");
      _speechEnabled = await _speechToText.initialize(
        onStatus: (status) => debugPrint("Speech Status: $status"),
        onError: (error) => debugPrint("Speech Error: $error"),
      );
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("MapScreen: Speech initialization failed: $e");
    }
  }

  void _startListening() async {
    _searchController.clear();
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _searchController.text = result.recognizedWords;
    });
    _onSearchTextChanged(result.recognizedWords);
  }

  @override
  void dispose() {
    _gpsStreamSubscription?.cancel();
    _debounceTimer?.cancel();
    _pulseController.dispose();
    _gradientController.dispose();
    _mapController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _addToHistory(Map<String, dynamic> item) {
    setState(() {
      _searchHistory.removeWhere((existing) => existing['display_name'] == item['display_name']);
      _searchHistory.insert(0, item);
      if (_searchHistory.length > 5) _searchHistory.removeLast();
    });
  }

  void _setMode(String mode) {
    setState(() {
      _selectedMode = mode;
    });
    _updateMetrics();
  }

  void _onSearchTextChanged(String text) {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    if (text.trim().isEmpty) {
      setState(() {
        _suggestionsList = [];
      });
      return;
    }

    setState(() {
      _isSearchingSuggestions = true;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      List<Map<String, dynamic>> results = await _streetService.getSearchSuggestions(text.trim(), _liveLat, _liveLng);

      if (results.isNotEmpty) {
        const Distance distanceCalculator = Distance();
        LatLng currentLoc = LatLng(_liveLat, _liveLng);

        for (var item in results) {
          if (item['lat'] != null && item['lon'] != null) {
            double calculatedDist = distanceCalculator.as(
              LengthUnit.Meter,
              currentLoc,
              LatLng(item['lat'], item['lon']),
            );
            item['distance_meters'] = calculatedDist;
          }
        }

        results.sort((a, b) => (a['distance_meters'] as double).compareTo(b['distance_meters'] as double));
      }

      if (mounted) {
        setState(() {
          _suggestionsList = results;
          _isSearchingSuggestions = false;
        });
      }
    });
  }

  Future<void> _executeLiveSearch() async {
    String query = _searchController.text.trim();
    if (query.isEmpty) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _hudInstruction = "Locating closest '$query'...";
      _isFetchingRoute = true;
      _suggestionsList.clear();
    });
    List<Map<String, dynamic>> results = await _streetService.getSearchSuggestions(query, _liveLat, _liveLng);
    if (results.isNotEmpty) {
      final closestMatch = results.first;

      _addToHistory(closestMatch);

      setState(() {
        _activeDestination = LatLng(closestMatch['lat'], closestMatch['lon']);
        _destinationName = closestMatch['display_name'].split(',')[0].toUpperCase();
        _searchController.text = closestMatch['display_name'];
        _realStreetPath.clear();
      });
      _mapController.move(_activeDestination!, 14.0);
      await _fetchStreetRoute();
    } else {
      setState(() {
        _hudInstruction = "Target not found. Try a different pincode or name.";
        _isFetchingRoute = false;
      });
    }
  }

  void _selectSuggestion(Map<String, dynamic> suggestion) async {
    FocusScope.of(context).unfocus();

    _addToHistory(suggestion);

    setState(() {
      _activeDestination = LatLng(suggestion['lat'], suggestion['lon']);
      _destinationName = suggestion['display_name'].split(',')[0].toUpperCase();
      _searchController.text = suggestion['display_name'];
      _suggestionsList.clear();
      _realStreetPath.clear();
      _isFetchingRoute = true;
      _hudInstruction = "Routing path directly to target...";
    });
    _mapController.move(_activeDestination!, 15.0);
    await _fetchStreetRoute();
  }

  Future<void> _fetchStreetRoute() async {
    if (_activeDestination == null) {
      return;
    }
    RouteData? routeData = await _streetService.getRealRoadDirections(LatLng(_liveLat, _liveLng), _activeDestination!);
    if (mounted && routeData != null) {
      setState(() {
        _realStreetPath = routeData.path;
        _apiTotalDistance = routeData.distanceMeters;
        _apiTotalDuration = routeData.durationSeconds;
        _isFetchingRoute = false;
        _currentPathIndex = 0;
        _updateNavigationHUD();
        _updateMetrics();
      });
    }
  }

  void _updateMetrics() {
    if (_realStreetPath.isEmpty || _currentPathIndex >= _realStreetPath.length - 1) {
      setState(() {
        _distanceRemaining = "0 m";
        _timeRemaining = "Arrived";
      });
      return;
    }
    double distM = 0.0;
    const Distance distCalc = Distance();
    for (int i = _currentPathIndex; i < _realStreetPath.length - 1; i++) {
      distM += distCalc.as(LengthUnit.Meter, _realStreetPath[i], _realStreetPath[i + 1]);
    }

    double ratio = _apiTotalDistance > 0 ? (distM / _apiTotalDistance) : 0;
    double timeS;

    if (_selectedMode == 'default') {
      timeS = _apiTotalDuration * ratio;
    } else {
      double speedMps;
      int hour = DateTime.now().hour;
      bool isPeakHour = (hour >= 8 && hour <= 11) || (hour >= 17 && hour <= 20);
      bool isNight = (hour >= 22 || hour <= 5);

      if (_selectedMode == 'walk') {
        speedMps = 1.38;
      } else if (_selectedMode == '2w') {
        if (isPeakHour) {
          speedMps = 5.55;
        } else if (isNight) {
          speedMps = 11.11;
        } else {
          speedMps = 8.33;
        }
      } else {
        if (isPeakHour) {
          speedMps = 3.33;
        } else if (isNight) {
          speedMps = 13.88;
        } else {
          speedMps = 6.94;
        }
      }
      timeS = distM / speedMps;
    }

    int timeM = (timeS / 60).ceil();

    setState(() {
      _distanceRemaining = distM > 1000 ? "${(distM / 1000).toStringAsFixed(1)} km" : "${distM.toInt()} m";
      _timeRemaining = timeM > 60 ? "${timeM ~/ 60}h ${timeM % 60}m" : "$timeM min";
    });
  }

  void _updateNavigationHUD() {
    if (_realStreetPath.isEmpty) {
      return;
    }
    if (_currentPathIndex >= _realStreetPath.length - 1) {
      setState(() {
        _hudInstruction = "You have arrived at $_destinationName!";
      });
      return;
    }
    LatLng c = _realStreetPath[_currentPathIndex];
    LatLng n = _realStreetPath[_currentPathIndex + 1];

    double angle = atan2(n.longitude - c.longitude, n.latitude - c.latitude) * 180 / pi;

    setState(() {
      _currentHeading = angle;

      if (_currentPathIndex == 0) {
        _hudInstruction = "Head toward the main road to begin your route.";
      } else if (angle > 45 && angle < 135) {
        _hudInstruction = "In 50 meters, turn right onto the next street segment.";
      } else if (angle < -45 && angle > -135) {
        _hudInstruction = "In 50 meters, make a safe left turn.";
      } else {
        _hudInstruction = "Continue straight along the optimized road channel.";
      }
    });
  }

  void _moveToNextStep() {
    if (_realStreetPath.isEmpty || _currentPathIndex >= _realStreetPath.length - 1) {
      return;
    }
    setState(() {
      _currentPathIndex++;
      _liveLat = _realStreetPath[_currentPathIndex].latitude;
      _liveLng = _realStreetPath[_currentPathIndex].longitude;
      _mapController.move(LatLng(_liveLat, _liveLng), _mapController.camera.zoom);
      _updateNavigationHUD();
      _updateMetrics();
    });
  }

  Future<void> _initializeLiveTracking() async {
    try {
      debugPrint("MapScreen: Starting GPS tracking...");
      _gpsStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 3,
        ),
      ).listen((pos) {
        if (!mounted || _currentPathIndex > 0) {
          return;
        }
        setState(() {
          _liveLat = pos.latitude;
          _liveLng = pos.longitude;
          _mapController.move(LatLng(_liveLat, _liveLng), _mapController.camera.zoom);
        });
      }, onError: (e) {
        debugPrint("MapScreen: GPS Stream Error: $e");
      });
    } catch (e) {
      debugPrint("MapScreen: Failed to start GPS tracking: $e");
    }
  }

  Widget _buildActiveTransportMarker() {
    return Transform.rotate(
      angle: _currentHeading * pi / 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 18, height: 18,
            decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 3))]
            ),
          ),
          ShaderMask(
            shaderCallback: (Rect bounds) => const LinearGradient(
              colors: [
                Color(0xFFFF0000),
                Color(0xFFFF5722),
                Color(0xFFFFC544),
                Color(0xFFFF0000),
              ],
              stops: [0.0, 0.4, 0.7, 1.0],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds),
            child: const Icon(Icons.navigation, color: Colors.white, size: 36),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isRouteActive = _realStreetPath.isNotEmpty;
    bool isSearchActive = _searchFocusNode.hasFocus || _searchController.text.isNotEmpty;

    bool showHistory = _searchFocusNode.hasFocus && _searchController.text.isEmpty && _searchHistory.isNotEmpty;
    bool showSuggestions = _suggestionsList.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          elevation: 6,
          backgroundColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
          flexibleSpace: AnimatedBuilder(
              animation: _gradientController,
              builder: (context, child) => ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: const [Color(0xFF0052D4), Color(0xFF4364F7), Color(0xFF00E5FF)],
                            begin: _gradientTop.value,
                            end: _gradientBottom.value
                        )
                    )
                ),
              )
          ),
          // ➔ EXACT MATCH: Michroma Google Font applied to AppBar text
          title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const NavigoLogo(),
                const SizedBox(width: 14),
                Text(
                    'NAVIGO MAPS',
                    style: GoogleFonts.michroma(
                        textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3.0,
                            shadows: [Shadow(color: Colors.black38, blurRadius: 2.0, offset: Offset(0, 1.5))]
                        )
                    )
                )
              ]
          )
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(_liveLat, _liveLng),
              initialZoom: 16.0,
              onLongPress: (tapPosition, point) {
                FocusScope.of(context).unfocus();
                setState(() {
                  _activeDestination = point;
                  _destinationName = "MAP PIN";
                  _searchController.text = "Dropped Pin (${point.latitude.toStringAsFixed(3)}, ${point.longitude.toStringAsFixed(3)})";
                  _suggestionsList.clear();
                  _realStreetPath.clear();
                  _isFetchingRoute = true;
                  _hudInstruction = "Routing path directly to map pin...";
                });
                _fetchStreetRoute();
              },
            ),
            children: [
              TileLayer(urlTemplate: _baseMapStyle, userAgentPackageName: 'com.example.navigo'),

              if (_activeOverlays.contains('transit'))
                TileLayer(urlTemplate: 'https://mt1.google.com/vt/lyrs=h,transit&x={x}&y={y}&z={z}'),
              if (_activeOverlays.contains('traffic'))
                TileLayer(urlTemplate: 'https://mt1.google.com/vt/lyrs=h,traffic&x={x}&y={y}&z={z}'),

              if (isRouteActive)
                AnimatedBuilder(
                    animation: _gradientController,
                    builder: (context, child) {
                      return ShaderMask(
                        shaderCallback: (Rect bounds) => LinearGradient(
                          colors: const [Color(0xFF0052D4), Color(0xFF4364F7), Color(0xFF00E5FF), Color(0xFF4364F7)],
                          stops: const [0.0, 0.4, 0.8, 1.0],
                          begin: _gradientTop.value,
                          end: _gradientBottom.value,
                        ).createShader(bounds),
                        blendMode: BlendMode.srcIn,
                        child: PolylineLayer(
                            polylines: [
                              Polyline(points: _realStreetPath, strokeWidth: 8.0, color: Colors.white.withValues(alpha: 0.5)),
                              Polyline(points: _realStreetPath, strokeWidth: 4.0, color: Colors.white),
                            ]
                        ),
                      );
                    }
                ),

              MarkerLayer(markers: [
                Marker(
                    point: LatLng(_liveLat, _liveLng),
                    width: 140, height: 140,
                    child: isRouteActive
                        ? _buildActiveTransportMarker()
                        : AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) => IdleHumanMarker(
                        heading: _currentHeading,
                        pulse: _pulseController.value,
                      ),
                    )
                ),
                if (_activeDestination != null)
                  Marker(
                      point: _activeDestination!,
                      width: 24, height: 36,
                      alignment: Alignment.center,
                      child: const PerfectDestinationPin()
                  ),
              ]),
            ],
          ),

          if (isRouteActive) Positioned(top: 168, left: 16, right: 16, child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), decoration: BoxDecoration(color: const Color(0xFF0052D4).withValues(alpha: 0.9), borderRadius: BorderRadius.circular(16)), child: Row(children: [_isFetchingRoute ? const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(color: Color(0xFF00E5FF), strokeWidth: 3)) : const Icon(Icons.navigation_rounded, color: Color(0xFF00E5FF), size: 26), const SizedBox(width: 14), Expanded(child: Text(_hudInstruction, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)))]))),

          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  SizedBox(width: 40, height: 40, child: FloatingActionButton(heroTag: 'compass_btn', elevation: 4, backgroundColor: Colors.white.withValues(alpha: 0.9), foregroundColor: Colors.black87, onPressed: () => _mapController.rotate(0.0), child: const GoogleCompassIcon())),
                  const SizedBox(height: 32),
                  Container(width: 56, height: 56, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0052D4), Color(0xFF4364F7), Color(0xFF00E5FF)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))]), child: FloatingActionButton(heroTag: 'route_planner', elevation: 0, backgroundColor: Colors.transparent, foregroundColor: Colors.white, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ShortestPathScreen())), child: const Icon(Icons.alt_route_rounded))), const SizedBox(height: 16),
                  Container(width: 50, height: 50, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFFF3D00), Color(0xFFFFC107)], begin: Alignment.bottomLeft, end: Alignment.topRight), shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFFFF3D00).withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3))]), child: FloatingActionButton(heroTag: 'map_layers', elevation: 0, backgroundColor: Colors.transparent, foregroundColor: Colors.white, onPressed: _showMapStyleMenu, child: const Icon(Icons.layers_outlined, size: 24))), const SizedBox(height: 12),
                  SizedBox(width: 40, height: 40, child: FloatingActionButton(heroTag: 'my_loc_btn', elevation: 4, backgroundColor: Colors.white.withValues(alpha: 0.9), foregroundColor: Colors.black87, onPressed: () => _mapController.move(LatLng(_liveLat, _liveLng), 16.0), child: const Icon(Icons.my_location, color: Color(0xFF0052D4), size: 22))), const SizedBox(height: 12),
                  SizedBox(width: 34, height: 34, child: FloatingActionButton.small(heroTag: 'z_in', elevation: 2, backgroundColor: Colors.white.withValues(alpha: 0.8), foregroundColor: const Color(0xFF0052D4), onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1.0), child: const Icon(Icons.add, size: 18))), const SizedBox(height: 12),
                  SizedBox(width: 34, height: 34, child: FloatingActionButton.small(heroTag: 'z_out', elevation: 2, backgroundColor: Colors.white.withValues(alpha: 0.8), foregroundColor: const Color(0xFF0052D4), onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1.0), child: const Icon(Icons.remove, size: 18))),
                ],
              ),
            ),
          ),

          if (isRouteActive)
            Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedFireModeSelector(
                            currentMode: _selectedMode,
                            onModeSelected: _setMode,
                          ),
                          const SizedBox(height: 16),

                          Card(
                              elevation: 12,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              child: Container(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                            children: [
                                              Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: Color(0xFFE8EFFF), shape: BoxShape.circle), child: const Icon(Icons.spatial_audio_off_outlined, color: Color(0xFF0052D4), size: 24)),
                                              const SizedBox(width: 16),
                                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Target: $_destinationName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis), const SizedBox(height: 4), const Text('Active Route Tracking', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600, fontSize: 13))])),
                                              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(_distanceRemaining, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0052D4))), Text(_timeRemaining, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13))])
                                            ]
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                            children: [
                                              Expanded(child: SizedBox(height: 46, child: OutlinedButton.icon(onPressed: () { setState(() { _realStreetPath.clear(); _activeDestination = null; _searchController.clear(); _selectedMode = 'default'; }); }, icon: const Icon(Icons.close, size: 16), label: const Text('CLEAR'), style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent), foregroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))))),
                                              const SizedBox(width: 12),
                                              Expanded(child: SizedBox(height: 46, child: ElevatedButton.icon(onPressed: isRouteActive && (_currentPathIndex < _realStreetPath.length - 1) ? _moveToNextStep : null, icon: const Icon(Icons.arrow_forward_ios, size: 16), label: const Text('NEXT STEP'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0052D4), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))))
                                            ]
                                        )
                                      ]
                                  )
                              )
                          )
                        ]
                    )
                )
            ),

          Positioned(
            top: 108, left: 16, right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 52, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(26), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))]),
                  child: Center(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onChanged: _onSearchTextChanged,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: "Search here", hintStyle: const TextStyle(fontSize: 16, color: Colors.black54),

                        prefixIcon: isSearchActive
                            ? IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black54, size: 26),
                          onPressed: () {
                            _searchFocusNode.unfocus();
                            _searchController.clear();
                            setState(() {
                              _suggestionsList.clear();
                              _realStreetPath.clear();
                              _activeDestination = null;
                            });
                          },
                        )
                            : IconButton(
                            icon: ShaderMask(shaderCallback: (Rect bounds) => const LinearGradient(colors: [Color(0xFF0052D4), Color(0xFF4364F7), Color(0xFF00E5FF)], begin: Alignment.topLeft, end: Alignment.bottomRight).createShader(bounds), child: const Icon(Icons.search, color: Colors.white, size: 28)),
                            onPressed: () {
                              _searchFocusNode.requestFocus();
                            }
                        ),

                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isSearchingSuggestions)
                              const Padding(padding: EdgeInsets.all(14.0), child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black54)))
                            else if (_searchController.text.isNotEmpty && !_speechToText.isListening)
                              IconButton(icon: const Icon(Icons.clear, color: Colors.black54), onPressed: () { _searchController.clear(); setState(() => _suggestionsList.clear()); })
                            else
                              IconButton(
                                  icon: AnimatedFireMic(isListening: _speechToText.isListening),
                                  onPressed: () {
                                    if (!_speechEnabled) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Microphone permission denied.'), backgroundColor: Colors.redAccent));
                                      return;
                                    }
                                    _speechToText.isNotListening ? _startListening() : _stopListening();
                                  }
                              ),
                            const SizedBox(width: 8),
                          ],
                        ),

                        border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onSubmitted: (_) => _executeLiveSearch(),
                    ),
                  ),
                ),

                if (showSuggestions || showHistory)
                  Container(
                      margin: const EdgeInsets.only(top: 8.0),
                      constraints: const BoxConstraints(maxHeight: 280),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6))]
                      ),
                      child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: showSuggestions ? _suggestionsList.length : _searchHistory.length,
                          separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF5F5F5)),
                          itemBuilder: (context, index) {

                            bool isHistoryItem = !showSuggestions;
                            final suggestion = isHistoryItem ? _searchHistory[index] : _suggestionsList[index];

                            double distM = 0.0;
                            if (suggestion['lat'] != null && suggestion['lon'] != null) {
                              const Distance distCalc = Distance();
                              distM = distCalc.as(LengthUnit.Meter, LatLng(_liveLat, _liveLng), LatLng(suggestion['lat'], suggestion['lon']));
                            }
                            String distStr = distM > 1000 ? "${(distM / 1000).toStringAsFixed(1)} km" : "${distM.toInt()} m";

                            List<String> addressParts = suggestion['display_name'].split(',');
                            String mainTitle = addressParts.isNotEmpty ? addressParts[0].trim() : suggestion['display_name'];
                            String subtitle = addressParts.length > 1 ? addressParts.sublist(1).join(', ').trim() : '';

                            return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),

                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: isHistoryItem ? Colors.grey.shade100 : const Color(0xFFE8EFFF),
                                      shape: BoxShape.circle
                                  ),
                                  child: Icon(
                                      isHistoryItem ? Icons.history : Icons.location_on_rounded,
                                      color: isHistoryItem ? Colors.grey.shade600 : const Color(0xFF0052D4),
                                      size: 20
                                  ),
                                ),

                                title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          child: Text(
                                              mainTitle,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis
                                          )
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                          distStr,
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.green)
                                      )
                                    ]
                                ),
                                subtitle: subtitle.isNotEmpty ? Text(
                                    subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, color: Colors.grey)
                                ) : null,

                                trailing: isHistoryItem
                                    ? IconButton(
                                  icon: const Icon(Icons.close, color: Colors.grey, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      _searchHistory.removeAt(index);
                                    });
                                  },
                                )
                                    : null,

                                onTap: () {
                                  _selectSuggestion(suggestion);
                                }
                            );
                          }
                      )
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMapStyleMenu() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 40),
                decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Map type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                        IconButton(icon: const Icon(Icons.close, color: Colors.black54), onPressed: () => Navigator.pop(context))
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBaseMapBtn('Default', 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}', Icons.map_outlined, const Color(0xFF0052D4), setModalState),
                        _buildBaseMapBtn('Satellite', 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}', Icons.satellite_alt_outlined, const Color(0xFF0F9D58), setModalState),
                        _buildBaseMapBtn('Terrain', 'https://mt1.google.com/vt/lyrs=p&x={x}&y={y}&z={z}', Icons.terrain_outlined, const Color(0xFFE67C73), setModalState),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(height: 1, color: Color(0xFFEEEEEE))),
                    const Text('Map details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      alignment: WrapAlignment.start,
                      children: [
                        _buildOverlayBtn('Public\ntransport', 'transit', Icons.directions_transit_outlined, const Color(0xFF9C27B0), setModalState),
                        _buildOverlayBtn('Traffic', 'traffic', Icons.traffic_outlined, const Color(0xFFD32F2F), setModalState),
                      ],
                    ),
                  ],
                ),
              );
            }
        )
    );
  }

  Widget _buildBaseMapBtn(String label, String url, IconData icon, Color themeColor, StateSetter setModalState) {
    bool isActive = _baseMapStyle == url;
    return GestureDetector(
      onTap: () {
        setState(() {
          _baseMapStyle = url;
        });
        setModalState(() {});
      },
      child: SizedBox(
        width: 70,
        child: Column(
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: isActive ? themeColor.withValues(alpha: 0.2) : themeColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: isActive ? themeColor : themeColor.withValues(alpha: 0.2),
                    width: isActive ? 2.0 : 1.0
                ),
              ),
              child: Center(
                  child: Icon(
                      icon,
                      size: 30,
                      color: isActive ? themeColor : themeColor.withValues(alpha: 0.6)
                  )
              ),
            ),
            const SizedBox(height: 8),
            Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                    color: isActive ? themeColor : Colors.grey.shade700
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayBtn(String label, String overlayId, IconData icon, Color themeColor, StateSetter setModalState) {
    bool isActive = _activeOverlays.contains(overlayId);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isActive) {
            _activeOverlays.remove(overlayId);
          } else {
            _activeOverlays.add(overlayId);
          }
        });
        setModalState(() {});
      },
      child: SizedBox(
        width: 70,
        child: Column(
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: isActive ? themeColor.withValues(alpha: 0.2) : themeColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: isActive ? themeColor : themeColor.withValues(alpha: 0.2),
                    width: isActive ? 2.0 : 1.0
                ),
              ),
              child: Center(
                  child: Icon(
                      icon,
                      size: 30,
                      color: isActive ? themeColor : themeColor.withValues(alpha: 0.6)
                  )
              ),
            ),
            const SizedBox(height: 8),
            Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                    color: isActive ? themeColor : Colors.grey.shade700
                )
            ),
          ],
        ),
      ),
    );
  }
}