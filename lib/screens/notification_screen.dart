import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});
  Future<void> markAllAsRead() async {
    final unread = await FirebaseFirestore.instance
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in unread.docs) {
      await doc.reference.update({
        'isRead': true,
      });
    }
  }

  @override
  State<NotificationScreen> createState() =>
      _NotificationScreenState();
}

class _NotificationScreenState
    extends State<NotificationScreen> {

  @override
  void initState() {
    super.initState();
    markNotificationsAsRead();
  }

  Future<void> markNotificationsAsRead() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({
        'isRead': true,
      });
    }
  }

  Future<void> deleteNotification(String docId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(docId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No Notifications",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {

              final data =
              docs[index].data() as Map<String, dynamic>;

              bool found = data['title'] == 'Person Found';
              String timeText = "";

              if (data['timestamp'] != null) {
                final diff = DateTime.now().difference(
                  (data['timestamp'] as Timestamp)
                      .toDate(),
                );

                if (diff.inDays > 0) {
                  timeText =
                  "${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago";
                } else {
                  timeText =
                  "${diff.inHours}h ago";
                }
              }

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding:
                  const EdgeInsets.all(12),

                  leading: CircleAvatar(
                    backgroundColor: found
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    child: Icon(
                      found
                          ? Icons.check_circle
                          : Icons.warning,
                      color: found
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),

                  title: Text(
                    data['title'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  subtitle: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),

                      Text(
                        data['message'] ?? '',
                      ),

                      const SizedBox(height: 4),

                      Text(
                        timeText,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == "delete") {

                        await deleteNotification(
                          docs[index].id,
                        );

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Notification Deleted",
                            ),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: "delete",
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            SizedBox(width: 10),
                            Text("Delete"),
                          ],
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
    );
  }
}