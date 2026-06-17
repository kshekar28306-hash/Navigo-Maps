import 'package:flutter/material.dart';
import 'screens/map_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NavigoApp());
}

class NavigoApp extends StatelessWidget {
  const NavigoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigo',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      // Boot directly into the Map! (Using Bangalore coordinates as the default startup)
      home: const MapScreen(latitude: 13.0279, longitude: 77.6361),
    );
  }
}