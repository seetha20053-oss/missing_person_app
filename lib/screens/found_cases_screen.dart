import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'report_details_screen.dart';

class FoundCasesScreen extends StatefulWidget {
  const FoundCasesScreen({super.key});

  @override
  State<FoundCasesScreen> createState() =>
      _FoundCasesScreenState();
}

class _FoundCasesScreenState
    extends State<FoundCasesScreen> {

  String searchText = "";
  String getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inMinutes < 60) {
      return "${difference.inMinutes} mins ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hrs ago";
    } else {
      return "${difference.inDays} days ago";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Found Cases"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('missing_persons')
            .where('status', isEqualTo: 'Found')
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data!.docs;

          docs.sort((a, b) {
            Timestamp timeA = a['timestamp'];
            Timestamp timeB = b['timestamp'];

            return timeB.compareTo(timeA); // newest first
          });
          final filteredDocs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;

            final name =
            (data['name'] ?? '').toString().toLowerCase();

            return name.contains(
              searchText.toLowerCase(),
            );
          }).toList();

          if (docs.isEmpty) {
            return const Center(
              child: Text("No Found Cases"),
            );
          }

          return Column(
            children: [

              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: "Search by name",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                ),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {

                    final data =
                    filteredDocs[index].data()
                    as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.all(10),

                      child: ListTile(

                        leading: const CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                          ),
                        ),

                        title: Text(
                          data['name'] ?? 'Unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          getTimeAgo(
                            (data['timestamp'] as Timestamp).toDate(),
                          ),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReportDetailsScreen(
                                report: data,
                                reportId:
                                filteredDocs[index].id,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}