import 'dart:async';
import 'package:flutter/material.dart';
import 'location_service.dart';
import 'package:geolocator/geolocator.dart';

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  State<LocationSearchScreen> createState() =>
      _LocationSearchScreenState();
}

class _LocationSearchScreenState
    extends State<LocationSearchScreen> {
  final TextEditingController _searchController =
  TextEditingController();

  final LocationService _locationService = LocationService();

  List<dynamic> places = [];

  Timer? _debounce;

  Future<void> searchLocation(String value) async {
    if (value.trim().length < 3) {
      setState(() {
        places = [];
      });
      return;
    }

    final result = await _locationService.searchPlaces(value);

    print(result);

    if (!mounted) return;

    setState(() {
      places = result;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Location"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "Search city, area or location",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {});

                if (_debounce?.isActive ?? false) {
                  _debounce!.cancel();
                }

                _debounce = Timer(
                  const Duration(milliseconds: 500),
                      () {
                    searchLocation(value);
                  },
                );
              },
            ),

            const SizedBox(height: 15),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.my_location,
                  color: Colors.blue,
                ),
                title: const Text("Auto Detect My Location"),
                subtitle: const Text("Use your current GPS location"),
                onTap: () async {
                  try {
                    Position position = await Geolocator.getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.high,
                    );

                    String address = await _locationService.getAddressFromLatLng(
                      position.latitude,
                      position.longitude,
                    );

                    Navigator.pop(
                      context,
                      {
                        "name": address,
                        "lat": position.latitude,
                        "lon": position.longitude,
                      },
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Unable to get current location"),
                      ),
                    );
                  }
                },
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: _searchController.text.trim().isEmpty
                  ? const Center(
                child: Text(
                  "Start typing to search locations",
                ),
              )

                  : places.isEmpty
                  ? ListView(
                children: [

                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.location_on,
                        color: Colors.orange,
                      ),
                      title: Text(
                        'Use "${_searchController.text}"',
                      ),
                      subtitle: const Text(
                        "Location not found. Tap to use this location.",
                      ),
                      onTap: () {
                        Navigator.pop(
                          context,
                          {
                            "name": _searchController.text,
                            "lat": null,
                            "lon": null,
                          },
                        );
                      },
                    ),
                  ),

                ],
              )

                  : ListView.builder(
                itemCount: places.length,
                itemBuilder: (context, index) {
                  final place = places[index];

                  return Card(
                    elevation: 2,
                    margin:
                    const EdgeInsets.symmetric(
                        vertical: 4),
                    child: ListTile(
                      leading: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                      ),
                      title: Text(
                        place["display_name"],
                        maxLines: 2,
                        overflow:
                        TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        print("Selected Place: ${place["display_name"]}");
                        print("Latitude: ${place["lat"]}");
                        print("Longitude: ${place["lon"]}");

                        Navigator.pop(
                          context,
                          {
                            "name": place["display_name"],
                            "lat": double.parse(place["lat"]),
                            "lon": double.parse(place["lon"]),
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}