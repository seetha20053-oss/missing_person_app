import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'edit_profile_screen.dart';
import 'login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = '';
  String email = '';
  String phone = '';
  String imageUrl = '';
  String role = '';
  Future<void> loadProfile() async {

    final user = FirebaseAuth.instance.currentUser!;

    print("Current Email = ${user.email}");

    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user.email)
        .get();

    print("Docs Found = ${query.docs.length}");

    if (query.docs.isNotEmpty) {

      final data = query.docs.first.data();

      print(data);

      setState(() {
        name = data['name'] ?? "";
        email = data['email'] ?? "";
        phone = data['phone'].toString();
        role = data['role'] ?? "";
      });
    } else {
      print("No document found");
    }
  }
  @override
  void initState() {
    super.initState();
    loadProfile();
  }


    Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) return;

    File file = File(image.path);

    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child('profile.jpg');

    await ref.putFile(file);

    String downloadUrl = await ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      'imageUrl': downloadUrl,
    }, SetOptions(merge: true));

    setState(() {
      imageUrl = downloadUrl;
    });
  }

  Future<void> logout() async {
    bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text(
            "Are you sure you want to logout?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("No"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );

    if (confirmLogout != true) return;

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),

            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage:
                  imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                  child: imageUrl.isEmpty
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),

                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: pickAndUploadImage,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text("Name"),
                subtitle: Text(name),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.email),
                title: const Text("Email"),
                subtitle: Text(email),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.phone),
                title: const Text("Phone"),
                subtitle: Text(phone),
              ),
            ),

            if (role != "police")
              Card(
                child: ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text("Edit Profile"),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(
                          name: name,
                          email: email,
                          phone: phone,
                        ),
                      ),
                    );

                    loadProfile();
                  },
                ),
              ),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
                title: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                onTap: logout,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}