import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/place_model.dart';
import '../services/location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final LocationService _locationService = LocationService();
  
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  List<PlaceModel> _places = [];
  bool _isLoading = true;

  // Default location (Buenos Aires)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-34.6037, -58.3816),
    zoom: 13.0,
  );

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    // Get sample places
    _places = PlaceModel.getSamplePlaces();
    
    // Get current location
    Position? position = await _locationService.getCurrentLocation();
    
    setState(() {
      _currentPosition = position;
      _isLoading = false;
    });

    // Add markers for places
    await _addPlaceMarkers();
    
    // Add marker for current location if available
    if (_currentPosition != null) {
      _addCurrentLocationMarker();
      _moveToLocation(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      );
    }
  }

  Future<BitmapDescriptor> _createMarkerImageFromIcon(IconData icon, Color color) async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: 70.0, // Reduced size
        fontFamily: icon.fontFamily,
        color: color,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(0.0, 0.0));

    final img = await pictureRecorder.endRecording().toImage(70, 70);
    final data = await img.toByteData(format: ImageByteFormat.png);
    return BitmapDescriptor.bytes(data!.buffer.asUint8List());
  }

  Future<void> _addPlaceMarkers() async {
    // Create custom icons matching the list style
    final BitmapDescriptor doctorIcon = await _createMarkerImageFromIcon(
      Icons.local_hospital, 
      Colors.blue,
    );
    
    final BitmapDescriptor pharmacyIcon = await _createMarkerImageFromIcon(
      Icons.local_pharmacy,
      Colors.green,
    );

    for (var place in _places) {
      final marker = Marker(
        markerId: MarkerId(place.id),
        position: LatLng(place.latitude, place.longitude),
        infoWindow: InfoWindow(
          title: place.name,
          snippet: place.address,
        ),
        icon: place.type == 'doctor' ? doctorIcon : pharmacyIcon,
      );
      
      setState(() {
        _markers.add(marker);
      });
    }
  }

  void _addCurrentLocationMarker() {
    if (_currentPosition == null) return;

    final marker = Marker(
      markerId: const MarkerId('current_location'),
      position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      infoWindow: const InfoWindow(
        title: 'Mi Ubicación',
        snippet: 'Estás aquí',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      _markers.add(marker);
    });
  }

  Future<void> _moveToLocation(LatLng location, {double zoom = 15.0}) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: location,
          zoom: zoom,
        ),
      ),
    );
  }

  Future<void> _goToCurrentLocation() async {
    if (_currentPosition != null) {
      await _moveToLocation(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      );
    }
  }

  void _onPlaceTapped(PlaceModel place) {
    _moveToLocation(LatLng(place.latitude, place.longitude));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Servicios'),
        backgroundColor: Colors.teal,
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Google Map
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: _initialPosition,
                  markers: _markers,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
                
                // List of places at the bottom
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Handle bar
                        Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        
                        // Title
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            'Puntos de Interés',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        
                        // List of places (horizontal scroll)
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            itemCount: _places.length,
                            itemBuilder: (context, index) {
                              final place = _places[index];
                              return _buildPlaceCard(place);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCurrentLocation,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildPlaceCard(PlaceModel place) {
    final isDoctor = place.type == 'doctor';
    
    return GestureDetector(
      onTap: () => _onPlaceTapped(place),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: 280, // Fixed width for horizontal scroll
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: isDoctor
                  ? [Colors.blue.shade50, Colors.blue.shade100]
                  : [Colors.green.shade50, Colors.green.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isDoctor ? Icons.local_hospital : Icons.local_pharmacy,
                    color: isDoctor ? Colors.blue : Colors.green,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          place.address,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDoctor 
                          ? Colors.blue.withValues(alpha: 0.2) 
                          : Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isDoctor ? 'Médico' : 'Farmacia',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDoctor ? Colors.blue[900] : Colors.green[900],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
