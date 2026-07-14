import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import 'report_details_screen.dart';

class MapScreen extends StatefulWidget {
  final double selectedLat;
  final double selectedLon;

  const MapScreen({
    super.key,
    required this.selectedLat,
    required this.selectedLon,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController mapController = MapController();

  List<Marker> markers = [];

  LatLng currentLocation = const LatLng(
    17.3850,
    78.4867,
  );

  @override
  void initState() {
    super.initState();

    currentLocation = LatLng(
      widget.selectedLat,
      widget.selectedLon,
    );

    Future.delayed(Duration.zero, () async {
      try {
        await loadMarkers();
      } catch (e) {
        print("MAP ERROR: $e");
      }
    });
  }

  Future<void> loadCurrentLocation() async {
    bool serviceEnabled =
    await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) return;

    LocationPermission permission =
    await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
      await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position =
    await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    currentLocation = LatLng(
      position.latitude,
      position.longitude,
    );

    await loadMarkers();

    mapController.move(currentLocation, 13);

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> loadMarkers() async {
    print("Loading markers...");
    markers.clear();

    final snapshot = await FirebaseFirestore.instance
        .collection('missing_persons')
        .where('status', isEqualTo: 'Missing')
        .get();
    print("Documents found: ${snapshot.docs.length}");

    List<Marker> tempMarkers = [];

    /// Current Location Marker
    tempMarkers.add(
      Marker(
        point: currentLocation,
        width: 80,
        height: 80,
        child: const Icon(
          Icons.my_location,
          color: Colors.blue,
          size: 40,
        ),
      ),
    );

    for (var doc in snapshot.docs) {
      print(doc.data());
      final data = doc.data();

      if (data['latitude'] == null ||
          data['longitude'] == null) {
        continue;
      }

      double reportLat =
      (data['latitude'] as num).toDouble();

      double reportLon =
      (data['longitude'] as num).toDouble();

      double distance =
      Geolocator.distanceBetween(
        currentLocation.latitude,
        currentLocation.longitude,
        reportLat,
        reportLon,
      );

      print("Person: ${data['name']}");
      print("Distance: $distance");
      tempMarkers.add(
        Marker(
          point: LatLng(reportLat, reportLon),
          width: 80,
          height: 80,
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(data["name"] ?? "Unknown"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("📍 ${data["location"] ?? ""}"),
                      const SizedBox(height: 10),
                      Text("Status : ${data["status"] ?? ""}"),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Close"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReportDetailsScreen(
                              report: data,
                              reportId: doc.id,
                            ),
                          ),
                        );
                      },
                      child: const Text("View Details"),
                    ),
                  ],
                ),
              );
            },
            child: const Icon(
              Icons.location_on,
              color: Colors.red,
              size: 40,
            ),
          ),
        ),
      );
    }

    setState(() {
      markers = tempMarkers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Missing Persons Map"),
      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: currentLocation,
          initialZoom: 13,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate:
            "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),

          CircleLayer(
            circles: [
              CircleMarker(
                point: currentLocation,
                radius: 20000,
                useRadiusInMeter: true,
                color: Colors.blue.withOpacity(0.2),
                borderColor: Colors.blue,
                borderStrokeWidth: 2,
              ),
            ],
          ),

          MarkerLayer(
            markers: markers,
          ),
        ],
      ),
    );
  }
}