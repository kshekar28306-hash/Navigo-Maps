import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../services/street_routing.dart';

class NavigoLogo extends StatelessWidget {
  const NavigoLogo({super.key});
  @override
  Widget build(BuildContext context) {
    // ➔ OPTIMIZATION: RepaintBoundary stops the logo from constantly redrawing
    return RepaintBoundary(
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 3))]
        ),
        child: CustomPaint(
          painter: NavigoLogoPainter(),
        ),
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
    // ➔ OPTIMIZATION: RepaintBoundary isolates the fast animation from the rest of the screen
    return RepaintBoundary(
      child: AnimatedBuilder(
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
      ),
    );
  }
}

class ShortestPathScreen extends StatefulWidget {
  const ShortestPathScreen({super.key});
  @override
  State<ShortestPathScreen> createState() => _ShortestPathScreenState();
}

class _ShortestPathScreenState extends State<ShortestPathScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final RealStreetRoutingService _streetService = RealStreetRoutingService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  Timer? _debounceTimer;
  late AnimationController _gradientController;
  late Animation<Alignment> _gradientTop, _gradientBottom;
  List<Map<String, dynamic>> _stops = [];
  List<LatLng> _multiStopPath = [];

  List<Map<String, dynamic>> _suggestionsList = [];
  final List<Map<String, dynamic>> _searchHistory = [];

  bool _isSearchingSuggestions = false, _isCalculatingRoute = false, _isPanelMinimized = false;
  String _totalDistanceStr = "0 m", _totalTimeStr = "0 min";
  final LatLng _defaultCenter = const LatLng(13.0279, 77.6361);

  String _baseMapStyle = 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}';
  final Set<String> _activeOverlays = {};

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat(reverse: true);
    _gradientTop = Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.topRight).animate(_gradientController);
    _gradientBottom = Tween<Alignment>(begin: Alignment.bottomRight, end: Alignment.bottomLeft).animate(_gradientController);

    _searchFocusNode.addListener(() {
      setState(() {});
    });

    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onStatus: (status) => setState(() {}),
    );
    setState(() {});
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
    _debounceTimer?.cancel();
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

    double searchLat = _stops.isNotEmpty ? _stops.last['lat'] : _defaultCenter.latitude;
    double searchLng = _stops.isNotEmpty ? _stops.last['lon'] : _defaultCenter.longitude;

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      List<Map<String, dynamic>> results = await _streetService.getSearchSuggestions(text.trim(), searchLat, searchLng);

      if (results.isNotEmpty) {
        const Distance distanceCalculator = Distance();
        LatLng currentLoc = LatLng(searchLat, searchLng);

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

  void _addStop(Map<String, dynamic> suggestion) async {
    FocusScope.of(context).unfocus();

    _addToHistory(suggestion);

    setState(() {
      _stops.add({'name': suggestion['display_name'].split(',')[0], 'lat': suggestion['lat'], 'lon': suggestion['lon']});
      _searchController.clear();
      _suggestionsList.clear();
    });
    _mapController.move(LatLng(suggestion['lat'], suggestion['lon']), 13.0);
    _calculateOptimalRoute();
  }

  void _removeStop(int index) {
    setState(() {
      _stops.removeAt(index);
    });
    _calculateOptimalRoute();
  }

  void _optimizeRouteOrder() {
    if (_stops.length < 2) {
      return;
    }
    setState(() {
      _isCalculatingRoute = true;
    });
    List<Map<String, dynamic>> optimizedList = [_stops.first];
    List<Map<String, dynamic>> unvisited = List.from(_stops.sublist(1));
    const distanceCalc = Distance();
    while (unvisited.isNotEmpty) {
      var current = optimizedList.last;
      unvisited.sort((a, b) {
        double distA = distanceCalc.as(LengthUnit.Meter, LatLng(current['lat'], current['lon']), LatLng(a['lat'], a['lon']));
        double distB = distanceCalc.as(LengthUnit.Meter, LatLng(current['lat'], current['lon']), LatLng(b['lat'], b['lon']));
        return distA.compareTo(distB);
      });
      optimizedList.add(unvisited.first);
      unvisited.removeAt(0);
    }
    setState(() {
      _stops = optimizedList;
    });
    _calculateOptimalRoute();
  }

  Future<void> _calculateOptimalRoute() async {
    if (_stops.length < 2) {
      setState(() {
        _multiStopPath.clear();
        _totalDistanceStr = "0 m";
        _totalTimeStr = "0 min";
      });
      return;
    }
    setState(() {
      _isCalculatingRoute = true;
    });
    List<LatLng> coords = _stops.map((stop) => LatLng(stop['lat'], stop['lon'])).toList();
    RouteData? routeData = await _streetService.getMultiStopRoute(coords);
    if (mounted && routeData != null) {
      setState(() {
        _multiStopPath = routeData.path;
        _totalDistanceStr = routeData.distanceMeters > 1000 ? "${(routeData.distanceMeters / 1000).toStringAsFixed(1)} km" : "${routeData.distanceMeters.toInt()} m";
        int timeMinutes = (routeData.durationSeconds / 60).ceil();
        _totalTimeStr = timeMinutes > 60 ? "${timeMinutes ~/ 60}h ${timeMinutes % 60}m" : "$timeMinutes min";
        _isCalculatingRoute = false;
      });
    } else {
      setState(() {
        _isCalculatingRoute = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double panelHeight = _isPanelMinimized ? 145.0 : screenHeight * 0.58;
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
          toolbarHeight: 65,
          titleSpacing: 0,
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
          title: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const NavigoLogo(),
                      const SizedBox(height: 2),
                      Text(
                        'NAVIGO',
                        style: GoogleFonts.michroma(
                            textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                shadows: [Shadow(color: Colors.black38, blurRadius: 1.5, offset: Offset(0, 1))]
                            )
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Text(
                      'ROUTE BUILDER',
                      style: GoogleFonts.michroma(
                          textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                              shadows: [Shadow(color: Colors.black38, blurRadius: 2.0, offset: Offset(0, 1.5))]
                          )
                      )
                  )
                ]
            ),
          )
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _defaultCenter,
                initialZoom: 12.0,
                onLongPress: (tapPosition, point) {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _stops.add({
                      'name': 'Pin (${point.latitude.toStringAsFixed(3)}, ${point.longitude.toStringAsFixed(3)})',
                      'lat': point.latitude,
                      'lon': point.longitude
                    });
                    _searchController.clear();
                    _suggestionsList.clear();
                  });
                  _calculateOptimalRoute();
                },
              ),
              children: [
                TileLayer(urlTemplate: _baseMapStyle, userAgentPackageName: 'com.example.navigo'),

                if (_activeOverlays.contains('transit'))
                  TileLayer(urlTemplate: 'https://mt1.google.com/vt/lyrs=h,transit&x={x}&y={y}&z={z}'),
                if (_activeOverlays.contains('traffic'))
                  TileLayer(urlTemplate: 'https://mt1.google.com/vt/lyrs=h,traffic&x={x}&y={y}&z={z}'),

                if (_multiStopPath.isNotEmpty)
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
                                Polyline(points: _multiStopPath, strokeWidth: 8.0, color: Colors.white.withValues(alpha: 0.5)),
                                Polyline(points: _multiStopPath, strokeWidth: 4.0, color: Colors.white),
                              ]
                          ),
                        );
                      }
                  ),

                MarkerLayer(markers: _stops.asMap().entries.map<Marker>((entry) {
                  int index = entry.key; var stop = entry.value;
                  bool isFirst = index == 0; bool isLast = index == _stops.length - 1 && _stops.length > 1;
                  Color markerColor = isFirst ? Colors.green : (isLast ? Colors.redAccent : Colors.orange);
                  return Marker(point: LatLng(stop['lat'], stop['lon']), width: 40, height: 40, child: Container(decoration: BoxDecoration(color: markerColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2.5), boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2))]), child: Center(child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)))));
                }).toList(),
                ),
              ],
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 250), curve: Curves.easeInOut, right: 16, bottom: panelHeight + 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 40, height: 40, child: FloatingActionButton(heroTag: 'p_compass_btn', elevation: 4, backgroundColor: Colors.white.withValues(alpha: 0.9), foregroundColor: Colors.black87, onPressed: () => _mapController.rotate(0.0), child: const GoogleCompassIcon())),

                const SizedBox(height: 12),

                Container(width: 50, height: 50, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFFF3D00), Color(0xFFFFC107)], begin: Alignment.bottomLeft, end: Alignment.topRight), shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFFFF3D00).withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3))]), child: FloatingActionButton(heroTag: 'p_map_layers', elevation: 0, backgroundColor: Colors.transparent, foregroundColor: Colors.white, onPressed: _showMapStyleMenu, child: const Icon(Icons.layers_outlined, size: 24))), const SizedBox(height: 12),
                SizedBox(width: 40, height: 40, child: FloatingActionButton(heroTag: 'p_my_loc_btn', elevation: 4, backgroundColor: Colors.white.withValues(alpha: 0.9), foregroundColor: Colors.black87, onPressed: () => _mapController.move(_defaultCenter, 13.0), child: const Icon(Icons.my_location, color: Color(0xFF0052D4), size: 22))), const SizedBox(height: 12),
                SizedBox(width: 34, height: 34, child: FloatingActionButton.small(heroTag: 'p_z_in', elevation: 2, backgroundColor: Colors.white.withValues(alpha: 0.8), foregroundColor: const Color(0xFF0052D4), onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1.0), child: const Icon(Icons.add, size: 18))), const SizedBox(height: 12),
                SizedBox(width: 34, height: 34, child: FloatingActionButton.small(heroTag: 'p_z_out', elevation: 2, backgroundColor: Colors.white.withValues(alpha: 0.8), foregroundColor: const Color(0xFF0052D4), onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1.0), child: const Icon(Icons.remove, size: 18))),
              ],
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250), curve: Curves.easeInOut, height: panelHeight,
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                children: [
                  GestureDetector(
                      onTap: () => setState(() => _isPanelMinimized = !_isPanelMinimized),
                      onVerticalDragEnd: (details) {
                        if (details.primaryVelocity! > 0 && !_isPanelMinimized) {
                          setState(() => _isPanelMinimized = true);
                        } else if (details.primaryVelocity! < 0 && _isPanelMinimized) {
                          setState(() => _isPanelMinimized = false);
                        }
                      },
                      child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 10), color: Colors.transparent, child: Column(mainAxisSize: MainAxisSize.min, children: [Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2.5))), const SizedBox(height: 2), Icon(_isPanelMinimized ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 16, color: Colors.grey.shade400)]))),
                  if (!_isPanelMinimized) ...[
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: Container(
                          height: 52, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(26), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))], border: Border.all(color: const Color(0xFFE8EFFF), width: 1.5)),
                          child: Center(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              onChanged: _onSearchTextChanged,
                              style: const TextStyle(fontSize: 16, color: Colors.black87),
                              decoration: InputDecoration(
                                hintText: "Add destination or stop...", hintStyle: const TextStyle(fontSize: 15, color: Colors.black54),

                                prefixIcon: isSearchActive
                                    ? IconButton(
                                  icon: const Icon(Icons.arrow_back, color: Colors.black54, size: 26),
                                  onPressed: () {
                                    _searchFocusNode.unfocus();
                                    _searchController.clear();
                                    setState(() {
                                      _suggestionsList.clear();
                                    });
                                  },
                                )
                                    : IconButton(
                                    icon: ShaderMask(shaderCallback: (Rect bounds) => const LinearGradient(colors: [Color(0xFF0052D4), Color(0xFF4364F7), Color(0xFF00E5FF)], begin: Alignment.topLeft, end: Alignment.bottomRight).createShader(bounds), child: const Icon(Icons.add_location_alt, color: Colors.white, size: 28)),
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
                            ),
                          ),
                        )
                    ),
                    Expanded(child: _stops.isEmpty ? const Center(child: Text("Add points to generate an optimal multi-stop route.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 15))) : ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), itemCount: _stops.length, itemBuilder: (context, index) => Card(elevation: 0, color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)), child: ListTile(leading: CircleAvatar(backgroundColor: const Color(0xFFE8EFFF), child: Text('${index + 1}', style: const TextStyle(color: Color(0xFF0052D4), fontWeight: FontWeight.bold))), title: Text(_stops[index]['name'], style: const TextStyle(fontWeight: FontWeight.bold)), trailing: IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent), onPressed: () => _removeStop(index)))))),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), child: SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: (_isCalculatingRoute || _stops.length < 2) ? null : _optimizeRouteOrder, icon: const Icon(Icons.auto_awesome), label: Text(_stops.length < 2 ? 'Add 2 stops to AI Optimize' : 'AI Optimize Route'), style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade700, foregroundColor: Colors.white, disabledBackgroundColor: Colors.grey.shade200, disabledForegroundColor: Colors.grey.shade500, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))))),
                  ],
                  Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))]), child: SafeArea(top: false, child: Row(children: [Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(color: Color(0xFFE8EFFF), shape: BoxShape.circle), child: const Icon(Icons.timeline, color: Color(0xFF4364F7))), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [const Text('Total Journey', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)), Row(children: [Text(_totalDistanceStr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0052D4))), const Text(" • ", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)), Text(_totalTimeStr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.green))])])), if (_isCalculatingRoute) const CircularProgressIndicator(color: Color(0xFF0052D4))]))),
                ],
              ),
            ),
          ),

          if ((showSuggestions || showHistory) && !_isPanelMinimized)
            Positioned(
                top: screenHeight * 0.42 + 80, left: 16, right: 16,
                child: Container(
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

                          double searchLat = _stops.isNotEmpty ? _stops.last['lat'] : _defaultCenter.latitude;
                          double searchLng = _stops.isNotEmpty ? _stops.last['lon'] : _defaultCenter.longitude;

                          double distM = 0.0;
                          if (suggestion['lat'] != null && suggestion['lon'] != null) {
                            const Distance distCalc = Distance();
                            distM = distCalc.as(LengthUnit.Meter, LatLng(searchLat, searchLng), LatLng(suggestion['lat'], suggestion['lon']));
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

                              onTap: () => _addStop(suggestion)
                          );
                        }
                    )
                )
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