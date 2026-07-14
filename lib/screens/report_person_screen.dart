import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'location_search_screen.dart';

class ReportPersonScreen extends StatefulWidget {
  const ReportPersonScreen({super.key});

  @override
  State<ReportPersonScreen> createState() => _ReportPersonScreenState();
}

class _ReportPersonScreenState extends State<ReportPersonScreen> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final identificationController = TextEditingController();
  final locationController = TextEditingController();
  double? selectedLat;
  double? selectedLon;
  final clothesController = TextEditingController();
  final contactPhoneController = TextEditingController();
  final descriptionController = TextEditingController();

  String selectedGender = "Male";

  TextEditingController lastSeenDateController =
  TextEditingController();

  XFile? selectedImage;

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        selectedImage = image;
      });
    }
  }

  Future<void> selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      lastSeenDateController.text =
      "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
    }
  }

  Future<void> submitReport() async {
    if (nameController.text.isEmpty ||
        ageController.text.isEmpty ||
        locationController.text.isEmpty ||
        contactPhoneController.text.isEmpty ||
        lastSeenDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields"),
        ),
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await FirebaseFirestore.instance
          .collection('missing_persons')
          .add({
        'name': nameController.text,
        'age': ageController.text,
        'gender': selectedGender,
        'height': heightController.text,
        'identificationMarks':
        identificationController.text,
        'lastSeenDate':
        lastSeenDateController.text,
        'lastSeenLocation':
        locationController.text,
        'clothesDescription':
        clothesController.text,
        'contactNumber':
        contactPhoneController.text,
        'description':
        descriptionController.text,
        'latitude': selectedLat ?? position.latitude,
        'longitude': selectedLon ?? position.longitude,
        'status': 'Missing',
        'timestamp':
        FieldValue.serverTimestamp(),
      });
      await FirebaseFirestore.instance
          .collection('notifications')
          .add({
        'title': 'New Missing Person',
        'message': '${nameController.text} reported missing',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Report Submitted Successfully",
          ),
        ),
      );
      Navigator.pop(context);
      nameController.clear();
      ageController.clear();
      heightController.clear();
      identificationController.clear();
      locationController.clear();
      clothesController.clear();
      contactPhoneController.clear();
      descriptionController.clear();
      lastSeenDateController.clear();

      setState(() {
        selectedImage = null;
        selectedGender = "Male";
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    }
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                  20, 60, 20, 30),
              decoration: const BoxDecoration(
                color: Colors.red,
              ),
              child: const Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    "Report Missing Person",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Fill in all details carefully",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  sectionTitle(
                    "Upload Photos (Max 5 Photos)",
                  ),

                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blue,
                          style: BorderStyle.solid,
                        ),
                        borderRadius:
                        BorderRadius.circular(15),
                      ),
                      child: selectedImage == null
                          ? const Column(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                        children: [
                          Icon(
                            Icons.upload,
                            size: 40,
                          ),
                          SizedBox(height: 10),
                          Text("Add Photo"),
                        ],
                      )
                          : const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 60,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Card(
                    child: Padding(
                      padding:
                      const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          sectionTitle(
                              "Personal Information"),

                          TextField(
                            controller:
                            nameController,
                            decoration:
                            const InputDecoration(
                              labelText:
                              "Full Name *",
                              border:
                              OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(
                              height: 15),

                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller:
                                  ageController,
                                  decoration:
                                  const InputDecoration(
                                    labelText:
                                    "Age *",
                                    border:
                                    OutlineInputBorder(),
                                  ),
                                ),
                              ),

                              const SizedBox(
                                  width: 15),

                              Expanded(
                                child:
                                DropdownButtonFormField<
                                    String>(
                                  value:
                                  selectedGender,
                                  decoration:
                                  const InputDecoration(
                                    labelText:
                                    "Gender *",
                                    border:
                                    OutlineInputBorder(),
                                  ),
                                  items: [
                                    "Male",
                                    "Female",
                                    "Other"
                                  ]
                                      .map(
                                        (e) =>
                                        DropdownMenuItem(
                                          value: e,
                                          child:
                                          Text(e),
                                        ),
                                  )
                                      .toList(),
                                  onChanged:
                                      (value) {
                                    setState(() {
                                      selectedGender =
                                      value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                              height: 15),

                          TextField(
                            controller:
                            heightController,
                            decoration:
                            const InputDecoration(
                              labelText:
                              "Height",
                              hintText:
                              "e.g. 5'8 or 173 cm",
                              border:
                              OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(
                              height: 15),

                          TextField(
                            controller:
                            identificationController,
                            maxLines: 3,
                            decoration:
                            const InputDecoration(
                              labelText:
                              "Identification Marks",
                              hintText:
                              "Scars, tattoos, birthmarks",
                              border:
                              OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Card(
                    child: Padding(
                      padding:
                      const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          sectionTitle(
                              "Last Seen Information"),

                          TextField(
                            controller:
                            lastSeenDateController,
                            readOnly: true,
                            onTap: selectDate,
                            decoration:
                            const InputDecoration(
                              labelText:
                              "Last Seen Date *",
                              border:
                              OutlineInputBorder(),
                              suffixIcon:
                              Icon(Icons.calendar_month),
                            ),
                          ),

                          const SizedBox(
                              height: 15),

                          TextField(
                            controller: locationController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: "Last Seen Location *",
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.location_on),
                            ),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LocationSearchScreen(),
                                ),
                              );

                              if (result != null) {
                                setState(() {
                                  locationController.text = result["name"];

                                  selectedLat = result["lat"] == null
                                      ? null
                                      : double.parse(result["lat"].toString());

                                  selectedLon = result["lon"] == null
                                      ? null
                                      : double.parse(result["lon"].toString());

                                  print("Location = ${result["name"]}");
                                  print("Latitude = $selectedLat");
                                  print("Longitude = $selectedLon");
                                });
                              }
                            },
                          ),

                          const SizedBox(
                              height: 15),

                          TextField(
                            controller:
                            clothesController,
                            maxLines: 3,
                            decoration:
                            const InputDecoration(
                              labelText:
                              "Clothes Description",
                              border:
                              OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Card(
                    child: Padding(
                      padding:
                      const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          sectionTitle(
                              "Contact Information"),

                          TextField(
                            controller:
                            contactPhoneController,
                            keyboardType:
                            TextInputType.phone,
                            decoration:
                            const InputDecoration(
                              labelText:
                              "Contact Number *",
                              border:
                              OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller:
                    descriptionController,
                    maxLines: 4,
                    decoration:
                    const InputDecoration(
                      labelText:
                      "Additional Description",
                      border:
                      OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        Colors.red,
                        foregroundColor:
                        Colors.white,
                      ),
                      onPressed:
                      submitReport,
                      child: const Text(
                        "Submit Report",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
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