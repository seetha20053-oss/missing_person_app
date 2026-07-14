import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'report_details_screen.dart';


class NearbyAlertsScreen extends StatelessWidget {
  final double selectedLat;
  final double selectedLon;

  const NearbyAlertsScreen({
    super.key,
    required this.selectedLat,
    required this.selectedLon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Alerts"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('missing_persons')
            .where('status', isEqualTo: 'Missing')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No Nearby Alerts"),
            );
          }

          List<QueryDocumentSnapshot> nearbyDocs = [];

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;

            if (data['latitude'] == null || data['longitude'] == null) {
              continue;
            }

            double reportLat = (data['latitude'] as num).toDouble();
            double reportLon = (data['longitude'] as num).toDouble();

            double distance = Geolocator.distanceBetween(
              selectedLat,
              selectedLon,
              reportLat,
              reportLon,
            );

            if (distance <= 20000) {
              nearbyDocs.add(doc);
            }
          }

          if (nearbyDocs.isEmpty) {
            return const Center(
              child: Text("No Nearby Alerts within 20 km"),
            );
          }

          return ListView.builder(
            itemCount: nearbyDocs.length,
            itemBuilder: (context, index) {
              final data =
              nearbyDocs[index].data() as Map<String, dynamic>;

              double distance = Geolocator.distanceBetween(
                selectedLat,
                selectedLon,
                (data['latitude'] as num).toDouble(),
                (data['longitude'] as num).toDouble(),
              );

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(
                      Icons.warning,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    data['name'] ?? 'Unknown',
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['lastSeenLocation'] ??
                            data['location'] ??
                            'Unknown Location',
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${(distance / 1000).toStringAsFixed(1)} km away",
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportDetailsScreen(
                          report: data,
                          reportId: nearbyDocs[index].id,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}