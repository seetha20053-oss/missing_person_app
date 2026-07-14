import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPersonScreen extends StatefulWidget {
  const SearchPersonScreen({super.key});

  @override
  State<SearchPersonScreen> createState() => _SearchPersonScreenState();
}

class _SearchPersonScreenState extends State<SearchPersonScreen> {
  final TextEditingController nameController = TextEditingController();

  String searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Missing Person"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase().trim();
                });
              },
              decoration: const InputDecoration(
                labelText: "Enter Name",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  searchText =
                      nameController.text.toLowerCase().trim();
                });
              },
              child: const Text("Search"),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('missing_persons')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  var reports = snapshot.data!.docs.where((doc) {
                    var data =
                    doc.data() as Map<String, dynamic>;

                    String name =
                    (data['name'] ?? '')
                        .toString()
                        .toLowerCase();

                    return name.contains(searchText);
                  }).toList();

                  if (reports.isEmpty) {
                    return const Center(
                      child: Text("No Person Found"),
                    );
                  }

                  return ListView.builder(
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      var report =
                      reports[index].data()
                      as Map<String, dynamic>;

                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(
                            report['name'] ?? '',
                          ),
                          subtitle: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),

                              Text(
                                'Age: ${report['age'] ?? ''}',
                              ),

                              Text(
                                'Gender: ${report['gender'] ?? ''}',
                              ),

                              Text(
                                'Location: ${report['location'] ?? ''}',
                              ),

                              Text(
                                'Description: ${report['description'] ?? ''}',
                              ),

                              Text(
                                'Status: ${report['status'] ?? 'Missing'}',
                                style: TextStyle(
                                  color:
                                  report['status'] == 'Found'
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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