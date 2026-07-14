import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'report_person_screen.dart';
import 'search_person_screen.dart';
import 'view_reports_screen.dart';
import 'found_person_screen.dart';
import 'profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'map_screen.dart';
import 'found_cases_screen.dart';
import 'nearby_alerts_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'notification_screen.dart';
import 'report_details_screen.dart';
import 'login_screen.dart';
import 'location_search_screen.dart';
import 'location_service.dart';
class PoliceDashboardScreen extends StatefulWidget {
  const PoliceDashboardScreen({super.key});


  @override
  State<PoliceDashboardScreen> createState() =>_PoliceDashboardScreenState();
}

class _PoliceDashboardScreenState
    extends State<PoliceDashboardScreen> {
  int _selectedIndex = 0;
  final TextEditingController searchController = TextEditingController();
  String currentLocation = "Getting Location...";
  String selectedLocation = "Select Location";
  double? selectedLat;
  double? selectedLon;
  final LocationService _locationService = LocationService();

  final TextEditingController _searchController =
  TextEditingController();
  String name = '';
  Future<void> loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user.email)
        .get();

    if (query.docs.isNotEmpty) {
      final data = query.docs.first.data();

      setState(() {
        name = data['name'] ?? '';
      });
    }
  }

  Future<void> getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String address =
      await _locationService.getAddressFromLatLng(
        position.latitude,
        position.longitude,
      );

      setState(() {
        currentLocation = address;
        selectedLocation = address;
        _searchController.text = address;

        selectedLat = position.latitude;
        selectedLon = position.longitude;
      });
    } catch (e) {
      print(e);

      setState(() {
        selectedLocation = "Unable to get location";
      });
    }
  }
  @override
  void initState() {
    super.initState();
    getLocation();
    loadUserName();
  }
  String getTimeAgo(Timestamp timestamp) {
    final difference = DateTime.now().difference(timestamp.toDate());

    if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else {
      return "${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago";
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(drawer: Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [

          UserAccountsDrawerHeader(
            accountName: Text(name),
            accountEmail: Text(
              FirebaseAuth.instance.currentUser?.email ?? '',
            ),
            currentAccountPicture: CircleAvatar(
              child: Icon(Icons.person, size: 40),
            ),
            decoration: BoxDecoration(
              color: Colors.red,
            ),
          ),

          ListTile(
            leading: Icon(Icons.home),
            title: Text("Home"),
            onTap: () {},
          ),

          ListTile(
            leading: Icon(Icons.person_add),
            title: Text("Report Person"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReportPersonScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.search),
            title: Text("Search Person"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SearchPersonScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.list_alt),
            title: Text("View Reports"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ViewReportsScreen(
                    isPolice: true,
                  ),
                ),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.check_circle),
            title: Text("Found Persons"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FoundPersonsScreen(
                    reportId: "",
                  ),
                ),
              );
            },
          ),

          Divider(),

          ListTile(
            leading: Icon(Icons.person),
            title: Text("Profile"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Logout"),
            onTap: () async {
              await FirebaseAuth.instance.signOut();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => LoginScreen(),
                ),
                    (route) => false,
              );
            },
          ),
        ],
      ),
    ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('missing_persons')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          var docs = snapshot.data!.docs;

          int totalReports = docs.length;

          int foundPersons = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['status'] == 'Found';
          }).length;

          int missingPersons = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['status'] == 'Missing';
          }).length;

          final recentMissing = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['status'] == 'Missing';
          }).take(5).toList();



          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [

                  // Welcome Banner
                  // Welcome Banner
                  // Welcome Banner
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFD32F2F),
                          Color(0xFFB71C1C),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "FindMe🔍",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const NotificationScreen(),
                                  ),
                                );
                              },
                              child: Stack(
                                children: [

                                  const Icon(
                                    Icons.notifications,
                                    color: Colors.white,
                                    size: 30,
                                  ),

                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('notifications')
                                        .where('isRead', isEqualTo: false)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      int count = snapshot.data?.docs.length ?? 0;

                                      if (count == 0) return const SizedBox();

                                      return Positioned(
                                        right: 0,
                                        top: 0,
                                        child: CircleAvatar(
                                          radius: 10,
                                          backgroundColor: Colors.red,
                                          child: Text(
                                            '$count',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ), // StreamBuilder
                                ], // Stack children
                              ), // Stack
                            ),
                          ],
                        ),// GestureDetector

                        SizedBox(height: 5),
                        Text(
                          "Welcome back, $name",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),

                        const Text(
                          "Together we can bring loved ones home safely",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LocationSearchScreen(),
                                ),
                              );

                              if (result != null) {
                                setState(() {
                                  _searchController.text = result["name"];
                                  selectedLocation = result["name"];
                                  currentLocation = result["name"];   // Add this line
                                  selectedLat = (result["lat"] as num).toDouble();
                                  selectedLon = (result["lon"] as num).toDouble();
                                });
                              }

                            },
                            child: AbsorbPointer(
                                child: TextField(
                                  controller: _searchController,
                                  readOnly: true,
                                  decoration: const InputDecoration(
                                    hintText: "Select Location",
                                    prefixIcon: Icon(Icons.location_on),
                                    border: InputBorder.none,
                                  ),
                                )
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                selectedLocation,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        const SizedBox(height: 15),
                        const SizedBox(height: 15),

                        SizedBox(
                          height: 250,
                          child: Row(
                            children: [

                              Expanded(
                                child: statCard(
                                  title: "Missing",
                                  count: missingPersons.toString(),
                                  icon: Icons.groups,
                                  color: const Color(0xffFF3B5C),
                                  lightColor: const Color(0xffFFE5EA),
                                ),
                              ),

                              const SizedBox(width: 18),

                              Expanded(
                                child: statCard(
                                  title: "Solved",
                                  count: foundPersons.toString(),
                                  icon: Icons.verified_user,
                                  color: const Color(0xff37C759),
                                  lightColor: const Color(0xffE6F9EA),
                                ),
                              ),

                              const SizedBox(width: 18),

                              Expanded(
                                child: statCard(
                                  title: "Total Cases",
                                  count: totalReports.toString(),
                                  icon: Icons.bar_chart,
                                  color: const Color(0xff2F6BFF),
                                  lightColor: const Color(0xffE8F0FF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ], // children
                    ), // Column
                  ), // Container



                  // Report Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Quick Actions",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text("Explore"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),


                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.8,
                    children: [
                      _actionCard(
                        context,
                        "Report Missing",
                        Icons.person_add_alt_1,
                        Colors.red,
                        const ReportPersonScreen(),
                      ),

                      _actionCard(
                        context,
                        "View Missing",
                        Icons.people,
                        Colors.blue,
                        const ViewReportsScreen(
                          isPolice: true,
                        ),
                      ),

                      _actionCard(
                        context,
                        "Found Cases",
                        Icons.verified_user,
                        Colors.green,
                        const FoundCasesScreen(),
                      ),



                      _actionCard(
                        context,
                        "Nearby Alerts",
                        Icons.notifications_active,
                        Colors.orange,
                         NearbyAlertsScreen(
                          selectedLat: selectedLat ?? 0.0,
                          selectedLon: selectedLon ?? 0.0,
                        )
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Recent Alerts",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),


                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
          itemCount: recentMissing.length,
                    itemBuilder: (context, index) {
                      final data = recentMissing[index].data() as Map<String, dynamic>;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.indigo,
                                      Colors.blue,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['name'] ?? 'No Name',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Text("Age: ${data['age'] ?? 'N/A'}"),

                                    Text(
                                      "Location: ${data['lastSeenLocation'] ?? 'Unknown'}",
                                    ),
                                    const SizedBox(height: 2),
                                    const SizedBox(height: 2),

                                    Text(
                                      data['timestamp'] != null
                                          ? getTimeAgo(data['timestamp'])
                                          : "Recently",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: data['status'] == 'Found'
                                            ? Colors.green.shade50
                                            : Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: data['status'] == 'Found'
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                      child: Text(
                                        data['status'] ?? 'Missing',
                                        style: TextStyle(
                                          color: data['status'] == 'Found'
                                              ? Colors.green
                                              : Colors.red,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReportDetailsScreen(
                                        report: data,
                                        reportId: recentMissing[index].id,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    "View",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }, // itemBuilder
                  ), // ListView.builder

                ], // Column children
              ), // Column
            ), // Padding
          ); // SingleChildScrollView
        }, // StreamBuilder builder
      ), // StreamBuilder



      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PoliceDashboardScreen(),
              ),
            );
          }

          else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MapScreen(
                  selectedLat: selectedLat ?? 17.3850,
                  selectedLon: selectedLon ?? 78.4867,
                ),
              ),
            );
          }

          else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfileScreen(),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "Map",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );

  }

  Widget statCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required Color lightColor,
  }) {
    return Container(
      height: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [

          // Bottom wave
          Positioned(
            bottom: -30,
            left: -10,
            right: -10,
            child: Container(
              height: 35,
              decoration: BoxDecoration(
                color: lightColor,
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [

                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),

                  const Spacer(),

                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(.15),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.trending_up,
                      color: color,
                      size: 22,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                title,
                style: const TextStyle(
                  fontSize:18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                title == "Missing"
                    ? "People reported\nmissing"
                    : title == "Solved"
                    ? "Successfully\nfound"
                    : "All time\ncases",
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _actionCard(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      Widget screen,
      ) {
    return InkWell(
      borderRadius: BorderRadius.circular(25),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => screen,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              color.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.20),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size:30,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),

                  const SizedBox(height: 8),


                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
