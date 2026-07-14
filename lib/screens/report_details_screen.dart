import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'found_person_screen.dart';

class ReportDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> report;
  final String reportId;
  const ReportDetailsScreen({
    super.key,
    required this.report,
    required this.reportId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Details"),
      ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Image
              report['imageUrl'] != null &&
                  report['imageUrl'].toString().isNotEmpty
                  ? ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
                child: Image.network(
                  report['imageUrl'],
                  height: 450, // Bigger image
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
                  : Container(
                height: 450,
                width: double.infinity,
                color: Colors.grey.shade300,
                child: const Icon(
                  Icons.person,
                  size: 120,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      report['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: report['status'] == 'Found'
                            ? Colors.green
                            : Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        report['status'] ?? 'Missing',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const SizedBox(height: 20),

// Person Details Card
                    Card(
                      margin: const EdgeInsets.all(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            const Text(
                              "Personal Information",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const Divider(),

                            Text("Full Name: ${report['name'] ?? ''}"),
                            Text("Age: ${report['age'] ?? ''}"),
                            Text("Gender: ${report['gender'] ?? ''}"),
                            Text("Height: ${report['height'] ?? ''}"),

                            const SizedBox(height: 10),

                            Text(
                              "Identification Marks: "
                                  "${report['identificationMarks'] ?? ''}",
                            ),
                          ],
                        ),
                      ),
                    ),

                    Card(
                      margin: const EdgeInsets.all(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            const Text(
                              "Last Seen Information",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const Divider(),

                            Text(
                              "Last Seen Date: "
                                  "${report['lastSeenDate'] ?? report['missingDate'] ?? ''}",
                            ),

                            const SizedBox(height: 8),

                            Text(
                              "Last Seen Location: "
                                  "${report['lastSeenLocation'] ?? report['location'] ?? ''}",
                            ),

                            const SizedBox(height: 8),

                            Text(
                              "Clothes Description: "
                                  "${report['clothesDescription'] ?? ''}",
                            ),

                            const SizedBox(height: 15),

                          ],
                        ),
                      ),
                    ),
// Contact Information Card
                    Card(
                      margin: const EdgeInsets.all(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            const Text(
                              "Contact Information",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const Divider(),

                            Text(
                              "Phone Number: "
                                  "${report['contactNumber'] ?? report['contactPhone'] ?? ''}",
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.all(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            const Text(
                              "Additional Description",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const Divider(),

                            Text(
                              report['description'] ?? '',
                            ),
                          ],
                        ),
                      ),
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('found_reports')
                          .where('reportId', isEqualTo: reportId)
                          .snapshots(),
                      builder: (context, snapshot) {

                        if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return const SizedBox();
                        }

                        final found =
                        snapshot.data!.docs.first.data()
                        as Map<String, dynamic>;

                        return Card(
                          margin: const EdgeInsets.all(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [

                                const Text(
                                  "Found Report Details",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const Divider(),
                                if (found['imageUrl'] != null)
                                  Image.network(
                                    found['imageUrl'],
                                    height: 250,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                Text(
                                  "Current Location: ${found['currentLocation'] ?? ''}",
                                ),

                                Text(
                                  "Additional Details: ${found['additionalDetails'] ?? ''}",
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  "Reported By: ${found['reportedBy'] ?? ''}",
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  "Phone: ${found['phone'] ?? ''}",
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Card(
                      margin: const EdgeInsets.all(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            const Text(
                              "Last Seen Location",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Row(
                              children: [

                                const SizedBox(width: 8),
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          report['lastSeenLocation'] ??
                                              report['location'] ??
                                              'Unknown',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            ElevatedButton.icon(
                              onPressed: () async {
                                double? lat = report['latitude'];
                                double? lng = report['longitude'];

                                if (lat != null && lng != null) {
                                  final Uri googleUrl = Uri.parse(
                                    'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
                                  );

                                  await launchUrl(
                                    googleUrl,
                                    webOnlyWindowName: '_blank',
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Location coordinates not available"),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.navigation),
                              label: const Text("Navigate"),
                            )
                          ],
                        ),
                      ),
                    ),

                    if (report['status'] != 'Found')
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FoundPersonsScreen(
                                  reportId: reportId,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.check_circle),
                          label: const Text("Report Found"),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }
}