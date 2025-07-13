import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_project/screens/requesters/active_deliveries.dart';
import 'package:fyp_project/screens/requesters/history.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import '../../backend/notification/notification.dart';
import '../../backend/user/user_provider.dart';
import 'package:fyp_project/backend/history/request_history.dart';

class RequesterScreen extends StatefulWidget {
  @override
  State<RequesterScreen> createState() => _RequesterScreenState();
}

class _RequesterScreenState extends State<RequesterScreen> {
  /// User Id:
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  @override
  void initState() {
    super.initState();
    /// Fetch User Data:
    if (userId != null) {
      Provider.of<UserProvider>(context, listen: false).fetchUserData(userId!, context);
    }
    /// Get PlayerId:
    var playerId = OneSignal.User.pushSubscription.id;
    /// Fetch User Data:
    if (userId != null) {
      Provider.of<UserProvider>(context, listen: false).fetchUserData(userId!, context);
    }
    /// Update Player Id:
    FirebaseFirestore.instance.collection('users').doc(userId).update({
      'playerId':playerId
    });
    print('update player id Suucessfully');
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
          padding: EdgeInsets.only(left: screenWidth * 0.02, top: screenHeight * 0.02),
          child: Row(
            children: [
              userProvider.userData?["image"] != null &&
                  userProvider.userData?["image"].isNotEmpty
                  ? CircleAvatar(
                backgroundColor: Colors.white,
                radius: screenWidth * 0.08,
                backgroundImage: NetworkImage(userProvider.userData?["image"]),
              )
                  : CircleAvatar(
                radius: screenWidth * 0.08,
                backgroundColor: Color(0XFF9CCCF2),
                child: Icon(
                  Icons.person,
                  size: screenWidth * 0.06,
                  color: Colors.grey[200],
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Salaam, ${userProvider.userData?['username']} 👋',
                    style: GoogleFonts.poppins(fontSize: screenWidth * 0.04, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "Let's start Request!",
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                      fontSize: screenWidth * 0.03,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              )
            ],
          ),
        ),
        actions: [buildNotificationIcon(userId!)],
      ),
      body: Column(
        children: [
          SizedBox(height: screenHeight * 0.03),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            /// Activities:
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: screenWidth > 600 ? 3 : 2, // Adjust based on screen size
              crossAxisSpacing: screenWidth * 0.05,
              mainAxisSpacing: screenHeight * 0.02,
              children: [
                customActivities("assets/images/request/history.png", "Request History", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => History()));
                }),
                customActivities("assets/images/request/delivery.png", "Active Delivery", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ActiveDeliveriesScreen(requesterId: userId!)));
                }),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          /// Recent Request:
          customText("Recent Requests", screenWidth),
          SizedBox(height: screenHeight * 0.01),
          /// History
          Expanded(child: RequestHistoryList()),
        ],
      ),
    );
  }
}

Widget customText(String text, double screenWidth) {
  return Padding(
    padding: EdgeInsets.only(left: screenWidth * 0.05),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.w500, fontFamily: "Poppins")),
    ),
  );
}

Widget customActivities(String image, String text, VoidCallback onPressed) {
  return InkWell(
    onTap: onPressed,
    child: LayoutBuilder(builder: (context, constraints) {
      return Container(
        padding: EdgeInsets.all(constraints.maxWidth * 0.05),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color(0XFFF2F9FF),
          border: Border.all(color: Colors.white),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(3, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, height: constraints.maxWidth * 0.4, width: constraints.maxWidth * 0.4),
            SizedBox(height: constraints.maxWidth * 0.08),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13, fontFamily: "Poppins"),
            ),
          ],
        ),
      );
    }),
  );
}
