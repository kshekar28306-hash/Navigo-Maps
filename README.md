# Navigo: Advanced AI Pathfinding & Live Navigation

Navigo is a high-performance Flutter navigation application designed for precision pathfinding and live telemetry tracking. Featuring a sleek "Fire & 3D" branding aesthetic, Navigo combines custom-built A* (A-Star) routing engines with real-world street data to provide a seamless navigation experience.

## 🚀 Core Features

### 1. Live Telemetry & GPS Scanning
- **Real-time Sonar Interface:** An animated radar/sonar UI that visualizes active GPS scanning.
- **Precision Coordinates:** Fetch and display live Latitude and Longitude with high-accuracy geolocation.
- **Closest Node Mapping:** Automatically snaps your raw GPS position to the nearest logical landmark in the navigation network.

### 2. AI-Powered Pathfinding (A* Algorithm)
- **Optimal Route Calculation:** Uses a custom implementation of the A* algorithm to find the fastest sequence of waypoints between any two locations.
- **Dynamic Waypoint Network:** A pre-loaded graph of interconnected nodes in Bangalore (Alpha Hub, Beta Core, etc.) for high-speed local routing.
- **Path Sequence HUD:** A step-by-step navigation "Heads-Up Display" (HUD) that guides you through the calculated sequence.

### 3. Real-World Street Routing
- **OSRM Integration:** Connects to the Open Source Routing Machine (OSRM) to generate routes on actual road networks.
- **Multi-Mode Navigation:** Toggle between different travel modes (Walking, 2-Wheeler, 4-Wheeler) with dynamic time-to-arrival (ETA) adjustments.
- **Live HUD Instructions:** Real-time directional cues (e.g., "In 50 meters, turn right") based on your movement along the path.

### 4. Interactive AI Route Builder
- **Multi-Stop Optimization:** Add multiple destinations and let the AI optimize the visit order based on distance.
- **Drag-to-Pin:** Long-press anywhere on the map to drop a pin and immediately calculate a route.
- **Minimized Control Panel:** A swipeable UI panel to manage your stops without cluttering the map view.

### 5. Smart Search & Voice Commands
- **Dynamic Suggestions:** Powered by Nominatim (OpenStreetMap), providing real-time search results for local landmarks.
- **Voice-Activated Search:** Integrated Speech-to-Text (STT) allows you to search for destinations using your voice.
- **Search History:** Quickly access your recent destinations and favorite spots.

### 6. Premium UI/UX Features
- **Fire & 3D Design Language:** Custom-painted logos, animated gradient app bars, and glowing UI components.
- **Multiple Map Layers:** Switch between Default, Satellite, and Terrain views with optional Traffic and Transit overlays.
- **Dynamic Map HUD:** Floating metrics showing distance remaining, ETA, and target destination details.

## 🛠️ Technology Stack

- **Framework:** Flutter (Dart)
- **Mapping:** `flutter_map` with `latlong2`
- **Location Services:** `geolocator`
- **Networking:** OSRM (Routing) & Nominatim (Search)
- **Fonts & UI:** Google Fonts (`Michroma`) & Custom Painters

## 📱 Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/navigo.git
   ```
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Run the application:**
   ```bash
   flutter run
   ```

---
*Built with ❤️ for the future of mobile navigation.*
