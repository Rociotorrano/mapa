class PlaceModel {
  final String id;
  final String name;
  final String type; // 'doctor' or 'pharmacy'
  final double latitude;
  final double longitude;
  final String address;

  PlaceModel({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  // Sample data - Locations in Buenos Aires, Argentina
  static List<PlaceModel> getSamplePlaces() {
    return [
      // Doctors
      PlaceModel(
        id: '1',
        name: 'Dr. García - Clínica General',
        type: 'doctor',
        latitude: -34.6037,
        longitude: -58.3816,
        address: 'Av. Corrientes 1234, Buenos Aires',
      ),
      PlaceModel(
        id: '2',
        name: 'Dra. Martínez - Cardiología',
        type: 'doctor',
        latitude: -34.5989,
        longitude: -58.3932,
        address: 'Av. Santa Fe 2345, Buenos Aires',
      ),
      PlaceModel(
        id: '3',
        name: 'Dr. López - Pediatría',
        type: 'doctor',
        latitude: -34.6131,
        longitude: -58.3772,
        address: 'Av. Rivadavia 3456, Buenos Aires',
      ),
      PlaceModel(
        id: '4',
        name: 'Dra. Fernández - Dermatología',
        type: 'doctor',
        latitude: -34.5875,
        longitude: -58.3974,
        address: 'Av. Cabildo 4567, Buenos Aires',
      ),
      
      // Pharmacies
      PlaceModel(
        id: '5',
        name: 'Farmacia del Centro',
        type: 'pharmacy',
        latitude: -34.6083,
        longitude: -58.3712,
        address: 'Av. de Mayo 876, Buenos Aires',
      ),
      PlaceModel(
        id: '6',
        name: 'Farmacia San Martín',
        type: 'pharmacy',
        latitude: -34.5952,
        longitude: -58.4019,
        address: 'Av. Las Heras 987, Buenos Aires',
      ),
      PlaceModel(
        id: '7',
        name: 'Farmacia Moderna',
        type: 'pharmacy',
        latitude: -34.6156,
        longitude: -58.3685,
        address: 'Entre Ríos 1234, Buenos Aires',
      ),
      PlaceModel(
        id: '8',
        name: 'Farmacia 24hs',
        type: 'pharmacy',
        latitude: -34.5834,
        longitude: -58.4125,
        address: 'Av. del Libertador 5678, Buenos Aires',
      ),
    ];
  }
}
