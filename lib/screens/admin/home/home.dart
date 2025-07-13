import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_project/screens/admin/manage/manage_donations.dart';
import 'package:fyp_project/screens/admin/manage/manage_funds.dart';
import 'package:fyp_project/screens/admin/manage/manage_pickup.dart';
import 'package:fyp_project/screens/admin/manage_users/manage_user.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

import '../../../backend/notification/notification.dart';
import '../../../backend/user/user_provider.dart';
import '../manage/manage_requests.dart';
import '../donation_report/report.dart';


class AdminDashboard extends StatefulWidget {
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  /// User Id Fetch From Firebase:
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  @override
  initState()  {

    super.initState();
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
    initializeFundsDocument('admin');

  }
  Future<void> initializeFundsDocument(String userId) async {
    DocumentReference fundsRef =
    FirebaseFirestore.instance.collection('funds').doc(userId);

    DocumentSnapshot snapshot = await fundsRef.get();

    if (!snapshot.exists) {
      await fundsRef.set({'totalFunds': '0'});
    }
  }


  @override
  Widget build(BuildContext context) {
    /// User Provider:
    final userProvider = Provider.of<UserProvider>(context);
    /// Get Size of Screen:
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
                    "Let's start management!",
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
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16.0),
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        children: [
          _buildDashboardButton(context, "Manage Users", 'assets/images/admin/users.gif', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserManagementScreen()),
            );
          },),
          _buildDashboardButton(context, "Donations", 'assets/images/admin/donations.gif', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ManageDonationsScreen()),
            );
          },),
          _buildDashboardButton(context, "View Requests", 'assets/images/admin/requests.gif',() {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ManageRequestsScreen()),
            );
          }),
          _buildDashboardButton(context, "Pickups", 'assets/images/admin/pickup.gif',() {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ManagePickupRequestsScreen()),
            );
          }),
          _buildDashboardButton(context, "Funds", 'assets/images/admin/bank.gif',() {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ManageFundsScreen()),
            );
          }),
          _buildDashboardButton(context, "Reports",'assets/images/admin/report.gif',() {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DonorListScreen()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDashboardButton(BuildContext context, String title, String image,VoidCallback onTap) {
    return GestureDetector(
      onTap:onTap,
      child: Card(
        color:Colors.white,
        elevation: 4.0,
        child: Container(
       decoration: BoxDecoration(
         borderRadius: BorderRadius.circular(10),
         border: Border.all(
             color:  Color(0XFFF2F9FF)
         ),
       ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(image,height:60,width: 60 ,),
              SizedBox(height: 10.0),
              Text(title,style: TextStyle(fontWeight: FontWeight.w400,fontSize: 13,fontFamily: "Poppins")),
            ],
          ),
        ),
      ),
    );
  }
}
