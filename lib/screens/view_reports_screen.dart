import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'report_details_screen.dart';
import 'package:intl/intl.dart';
class ViewReportsScreen extends StatefulWidget {
  final bool isPolice;

  const ViewReportsScreen({
    super.key,
    required this.isPolice,
  });

  @override
  State<ViewReportsScreen> createState() => _ViewReportsScreenState();
}
class _ViewReportsScreenState extends State<ViewReportsScreen> {
  String searchText = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Reports"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('missing_persons')
            .where('status', isEqualTo: 'Missing')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final reports = snapshot.data!.docs;
          final filteredReports = reports.where((doc) {
            final report = doc.data() as Map<String, dynamic>;

            return report['name']
                .toString()
                .toLowerCase()
                .contains(searchText);
          }).toList();

          return Column(
            children: [

            Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.indigo],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),

                const SizedBox(height: 15),



                const Text(
                  "Missing Persons",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 15),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      searchText = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search by name or location...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),



              ],
            ),
          ),


          Expanded(
          child: ListView.builder(


            itemCount: filteredReports.length,
            itemBuilder: (context, index) {
              final report =
              filteredReports[index].data() as Map<String, dynamic>;
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportDetailsScreen(
                        report: report,
                        reportId: filteredReports[index].id,
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.all(12),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        report['imageUrl'] != null &&
                            report['imageUrl'].toString().isNotEmpty
                            ? CircleAvatar(
                          radius: 35,
                          backgroundImage: NetworkImage(report['imageUrl']),
                        )
                            : CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.blue.shade100,
                          child: const Icon(
                            Icons.person,
                            color: Colors.blue,
                            size: 28,
                          ),
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text(
                                report['name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text("Age: ${report['age'] ?? ''}"),
                              const SizedBox(height: 4),

                              Text("Gender: ${report['gender'] ?? ''}"),
                              const SizedBox(height: 4),

                              Text(
                                "Location: ${report['lastSeenLocation'] ?? report['location'] ?? 'Unknown'}",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),

                              Text("Description: ${report['description'] ?? ''}"),
                              const SizedBox(height: 4),
                              if (report['timestamp'] != null)
                                Text(
                                  "Reported On: ${DateFormat('dd MMM yyyy, hh:mm a').format(
                                    (report['timestamp'] as Timestamp).toDate(),
                                  )}",
                                ),

                              Text(
                                "Status: ${report['status'] ?? 'Missing'}",
                                style: TextStyle(
                                  color: report['status'] == 'Found'
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (widget.isPolice)
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              bool? confirm = await showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Delete Report"),
                                  content: const Text(
                                    "Are you sure you want to delete this report?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text("Delete"),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await FirebaseFirestore.instance
                                    .collection('missing_persons')
                                    .doc(filteredReports[index].id)
                                    .delete();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Report deleted successfully"),
                                  ),
                                );
                              }
                            },
                          ),
                      ],
                    ),
                  ),
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