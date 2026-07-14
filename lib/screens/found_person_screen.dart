import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
class FoundPersonsScreen extends StatefulWidget {
  final String reportId;

  const FoundPersonsScreen({
    super.key,
    required this.reportId,
  });

  @override
  State<FoundPersonsScreen> createState() =>
      _FoundPersonsScreenState();
}

class _FoundPersonsScreenState
    extends State<FoundPersonsScreen> {
  File? selectedImage;

  final ImagePicker picker = ImagePicker();
  final locationController = TextEditingController();
  final detailsController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  Future<void> pickImage() async {
    final XFile? image =
    await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  @override
Widget build(BuildContext context) {
return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [

            // Green Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 60,
                left: 20,
                right: 20,
                bottom: 30,
              ),
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Report Found Person",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Help reunite families",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Warning Card
            Card(
              margin: const EdgeInsets.symmetric(
                  horizontal: 20),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Important: Please ensure the person matches a missing person report before submitting.",
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Upload Photo Card
            Card(
              margin: const EdgeInsets.symmetric(
                  horizontal: 20),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text("Upload Photo"),
                    SizedBox(height: 20),

                    ElevatedButton.icon(
                      onPressed: pickImage,
                      icon: Icon(Icons.upload),
                      label: Text("Choose Photo"),
                    ),
                    const SizedBox(height: 10),

                    if (selectedImage != null)
                      const Text(
                        "Image Selected Successfully",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Location Card
            Card(
              margin: const EdgeInsets.symmetric(
                  horizontal: 20),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: "Current Location",
                  ),
                ),
                    SizedBox(height: 10),
                    TextField(
                      controller: detailsController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: "Additional Details",
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Contact Card
            Card(
              margin: const EdgeInsets.symmetric(
                  horizontal: 20),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Your Name",
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: "Contact Number",
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Submit Button
            Padding(
              padding:
              const EdgeInsets.symmetric(
                  horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    Colors.green,
                  ),
                  onPressed: () async {
                    print("Submit button clicked");



                    // Save found report
                    await FirebaseFirestore.instance
                        .collection('found_reports')
                        .add({
                      'reportId': widget.reportId,
                      'currentLocation': locationController.text,
                      'additionalDetails': detailsController.text,
                      'reportedBy': nameController.text,
                      'phone': phoneController.text,
                      'timestamp': FieldValue.serverTimestamp(),
                    });
                    // Mark person as found
                    await FirebaseFirestore.instance
                        .collection('missing_persons')
                        .doc(widget.reportId)
                        .update({
                      'status': 'Found',
                      'timestamp': FieldValue.serverTimestamp(),
                    });
                    final personDoc = await FirebaseFirestore.instance
                        .collection('missing_persons')
                        .doc(widget.reportId)
                        .get();

                    final personName = personDoc.data()?['name'] ?? 'Person';
                    await FirebaseFirestore.instance
                        .collection('notifications')
                        .add({
                      'title': 'Person Found',
                      'message': '$personName has been found safely',
                      'timestamp': FieldValue.serverTimestamp(),
                      'isRead': false,
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Report Submitted Successfully'),
                      ),
                    );

                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Submit Report",
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
}
}
