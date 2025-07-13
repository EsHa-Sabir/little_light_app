import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_project/screens/profile/profile.dart';
import 'package:fyp_project/screens/volunteer/pickup_request.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import '../../backend/notification/notification.dart';
import '../../backend/pickup_list/pickup_list.dart';
import '../../backend/requests_list/requests_list.dart';
import '../../backend/user/user_provider.dart';
import '../../widgets/toast_message.dart';
import '../chat/inbox.dart';
import 'package:geolocator/geolocator.dart';

class VolunteerScreen extends StatefulWidget {
  @override
  State<VolunteerScreen> createState() => _VolunteerScreenState();
}

class _VolunteerScreenState extends State<VolunteerScreen> {
  /// Get User Id:
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  /// For location:
  StreamSubscription<Position>? positionStream;

  @override
  void initState() {
    super.initState();
    /// Get PlayerId:
    var playerId = OneSignal.User.pushSubscription.id;
    /// Update Player Id:
    FirebaseFirestore.instance.collection('users').doc(userId).update({
      'playerId':playerId
    });
    print('update player id Suucessfully');
    /// Fetch User Data:
    Provider.of<UserProvider>(context, listen: false).fetchUserData(userId!, context);
    /// For Location:
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkLocationServices(context);
    });
    /// For Location Update
    getRequestId(userId!).then((requestId) {
      if (requestId != null) {
        startRealTimeLocationUpdate(requestId,context); // Start updating location
      } else {
        print("❌ No active pickup request found for this volunteer.");
      }
    });

  }
  /// Get Pickup Request Id:
  Future<String?> getRequestId(String volunteerId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('pickup_requests')
        .where('volunteerId', isEqualTo: volunteerId) // Filter by Volunteer ID
        .where('status', isEqualTo: 'Accepted')
        .where('delivery_status',isEqualTo: 'In Transit') // Active request only
        .limit(1) // Only get one active request
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id; // Return request ID
    }
    return null; // No active request found
  }
  /// Update Location:
  /// Function to start real-time location updates
  Future<void> startRealTimeLocationUpdate(String requestId, BuildContext context) async {
    // 📌 Check if location is enabled
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      showToast(message: "Please turn on location for real time tracking", context: context);
      return; // ❌ Stop function if location is OFF
    }

    // 📌 Get current location
    Position? position = await getCurrentLocation();
    if (position != null) {
      await FirebaseFirestore.instance.collection('pickup_requests').doc(requestId).update({
        'volunteerLocation': {
          "lat": position.latitude,
          "lng": position.longitude
        }
      });
      print("✅ Real-Time Location Updated: ${position.latitude}, ${position.longitude}");
    } else {
      showToast(message: "❌ Could not fetch location. Try again.", context: context);
    }
  }
  /// ✅ Check if Location Services (GPS) are Enabled:
  Future<void> checkLocationServices(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showLocationDialog(context);
    }
  }
  /// ✅ Show Dialog if GPS is Disabled:
  void showLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          title: Center(
              child: Text(
                "Location Required",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              )),
          content: Text(
            "Please enable location services to continue.",
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("No Thanks", style: TextStyle(color:Colors.blue)),
            ),
            TextButton(
              onPressed: () async {
                await Geolocator.openLocationSettings();
                Navigator.pop(context);
              },
              child: Text("Enable", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    /// User Provider:
    final userProvider = Provider.of<UserProvider>(context);
    /// Media Query:
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      /// Appbar:
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: double.infinity,
        leading: Padding(
          padding:  EdgeInsets.only(left: screenWidth * 0.02, top: screenHeight * 0.02),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              userProvider.userData?["image"]!= null
                  && userProvider.userData?["image"].isNotEmpty? CircleAvatar(
                backgroundColor: Colors.white,
                radius:  screenWidth * 0.08,
                backgroundImage: NetworkImage(userProvider.userData?["image"]),
              ): CircleAvatar(
                radius:  screenWidth * 0.08,
                backgroundColor: Color(0XFF9CCCF2),
                child: Icon(Icons.person,size:  screenWidth * 0.06,color: Colors.grey[200],),
              ),
              SizedBox(width: screenWidth * 0.03),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Salaam, ${userProvider.userData?['username']} 👋',
                    style: GoogleFonts.poppins(
                        fontSize:  screenWidth * 0.04,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "Let's start Deliveries!",
                    style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                        fontSize:  screenWidth * 0.03),
                    overflow: TextOverflow.ellipsis,),
                ],
              )

            ],
          ),
        ),
        actions: [

          buildNotificationIcon(userId!)
        ],
      ),
      /// Body:
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.02),
            /// Activities:
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                customContainer(screenWidth, screenHeight, 'assets/images/volunteer/delivery.png', 'Pick & Drop', () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PickupRequest()));
                }),
                customContainer(screenWidth, screenHeight, 'assets/images/volunteer/chat.png', 'Chat', () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Inbox()));
                }),
                customContainer(screenWidth, screenHeight, 'assets/images/volunteer/profile.png', 'Account', () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
                }),
              ],
            ),
            customText(screenWidth, 'Recent Requests'),
            /// Recent requests:
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                /// Fetch Pickup request:
                stream: fetchPickupRequestsWithUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0XFF9CCCF2),
                        ));
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        "Error loading pickup requests",
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final pickupRequest = snapshot.data!;
                  if (pickupRequest.isEmpty) {
                    return Column(

                      children: [
                        SizedBox(
                          height: 100,
                        ),
                        /// Image:
                        Center(
                          child: Image.asset(
                            "assets/images/volunteer/no_delivery.png",
                            width: 70,
                            height: 70,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Center(
                          child: Text(
                            "No pickup request match your search.",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontFamily: "Poppins",
                                fontSize: 13,
                                color: Colors.grey),
                          ),
                        ),
                      ],
                    );
                  }
                  /// Display request:
                  return ListView.builder(
                    itemCount: pickupRequest.length,
                    itemBuilder: (context, index) {
                      final data = pickupRequest[index];
                      final user = data['user'];
                      final status = data['status'] ?? "Pending";
                      final date=data['timestamp'] != null
                          ? DateFormat('dd MMM yyyy, hh:mm a').format(data['timestamp'].toDate())
                          : "Unknown Date";
                      /// Card:
                      return Card(
                        color: Colors.white,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0XFF9CCCF2),), // Border color and width
                            borderRadius: BorderRadius.circular(8), // Rounded corners
                          ),
                          child: ListTile(
                              leading:CircleAvatar(
                                radius: 30,
                                backgroundColor: const Color(0XFF9CCCF2),
                                backgroundImage: user['image'] != null
                                    ? NetworkImage(user['image'])
                                    : null,
                                child: user['image'] == null
                                    ? const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                ) : null,
                              ),
                              title: Column(
                                children: [
                                  customTitle("Name:"),
                                  SizedBox(height: 1,),
                                  customSubtitle(user['username'] ?? "No Name"),
                                  SizedBox(height: 3,),
                                  // customTitle("Pickup Address:"),
                                  // SizedBox(height: 1,),
                                  // customSubtitle(data['pickupAddress'] ?? "No Name"),
                                  // customTitle("Delivery Address:"),
                                  // SizedBox(height: 1,),
                                  // customSubtitle(data['deliveryAddress'] ?? "No Name"),
                                  // SizedBox(height: 3,),
                                  customTitle("Submitted on:"),
                                  SizedBox(height: 1,),
                                  customSubtitle(date),
                                  SizedBox(height: 3,),
                                  customTitle("Status:"),
                                  SizedBox(height: 1,),
                                  customSubtitle(status),



                                ],
                              ),

                              trailing: status == "Pending"
                                  ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  /// Accept Button:
                                  TextButton(
                                    onPressed: () {

                                      updatePickupRequestStatus(
                                          data['id'] ?? "",
                                          data['donorId'] ?? "",
                                          "Pickup Request Update", "Your pickup Request has been Accepted by ${ userProvider.userData?['username'] ?? ""}",
                                          "Accepted",userId!,context
                                      );

                                      setState(() {   });
                                    },
                                    child: const Text(
                                      "Accept",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 5), // Space between buttons

                                  /// Reject Button:
                                  TextButton(
                                    onPressed: () {
                                      updatePickupRequestStatus(
                                          data['id'] ?? "",
                                          data['donorId'] ?? "",
                                          "Pickup Request Update", "Your Request has been Rejected by ${ userProvider.userData?['username'] ?? ""}", "Rejected",userId!
                                          ,context);

                                      setState(() { });
                                    },
                                    child: const Text(
                                      "Reject",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                                  : Text(
                                status, // Show "Accepted" or "Rejected"
                                style: TextStyle(
                                  color: status == "Accepted" ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            /// Bottom Sheet:
                              onTap: () => showBottomSheet2(context,data)

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

  /// ✅ Custom Container for Buttons
  Widget customContainer(double screenWidth, double screenHeight, String image, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: screenWidth * 0.28,
        height: screenHeight * 0.15,
        decoration: BoxDecoration(
          color: Color(0XFFE3F3FF),
          border: Border.all(color: Color(0xFF9CCCF2)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.02),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: screenWidth * 0.15,
                height: screenWidth * 0.15,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Color(0xFF9CCCF2)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset(image, width: screenWidth * 0.1, height: screenWidth * 0.1),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                text,
                style: TextStyle(fontFamily: 'Poppins', fontSize: screenWidth * 0.035, fontWeight: FontWeight.w400),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ Custom Text Widget
  Widget customText(double screenWidth, String text) {
    return Padding(
      padding: EdgeInsets.only(top: screenWidth * 0.04, bottom: screenWidth * 0.02),
      child: Align(
          alignment: Alignment.centerLeft,
          child: Text(text, style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.w500, fontFamily: "Poppins"))),
    );
  }
}



/// Update Location:
// void startPeriodicLocationUpdate(String requestId) {
//   Timer.periodic(Duration(seconds: 30), (Timer t) async {
//     Position? position = await getCurrentLocation();
//     if (position != null) {
//       await FirebaseFirestore.instance.collection('pickup_requests').doc(requestId).update({
//         'volunteerLocation': {
//           "lat": position.latitude,
//           "lng": position.longitude
//         }
//       });
//       print("✅ Periodic Location Updated in pickup_requests: ${position.latitude}, ${position.longitude}");
//     }
//   });
// }