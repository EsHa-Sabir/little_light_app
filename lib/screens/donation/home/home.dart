import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_project/backend/history/donation_history.dart';
import 'package:fyp_project/backend/history/pickup_history.dart';
import 'package:fyp_project/screens/donation/report/report.dart';
import 'package:fyp_project/screens/donation/requester_list/categories_based_requester.dart';
import 'package:fyp_project/screens/donation/requester_list/requester_list.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import '../../../backend/notification/notification.dart';
import '../../../backend/user/user_provider.dart';
import '../history/donation_history.dart';

class DonorScreen extends StatefulWidget {
  @override
  State<DonorScreen> createState() => _DonorScreenState();
}

class _DonorScreenState extends State<DonorScreen> {
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

  }

  @override
  Widget build(BuildContext context) {
    /// User Provider:
    final userProvider = Provider.of<UserProvider>(context);
    /// Get Size of Screen:
    final size = MediaQuery.of(context).size;
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
                    "Let's start Donation!",
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
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: 7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            /// Banner
            customBanner(context),
            SizedBox(height: 15),
            /// Categories:
            customText("Select Categories"),
            SizedBox(height: 20),
            /// Categories:
            Wrap(
              spacing: size.width * 0.05925,
              runSpacing: 15,
              alignment: WrapAlignment.spaceBetween,
              children: [
                customContainer("assets/images/donation/categories/medical.png", "Health", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CategoriesBasedRequester(category: "Health")));
                }),
                customContainer("assets/images/donation/categories/education.png", "Education", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CategoriesBasedRequester(category: "Education")));
                }),
                customContainer("assets/images/donation/categories/cloth.png", "Cloth", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CategoriesBasedRequester(category: "Cloth")));
                }),
                customContainer("assets/images/donation/categories/book.png", "Book", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CategoriesBasedRequester(category: "Book")));
                }),
              ],
            ),
            SizedBox(height: 20),
            /// Quick Tools:
            customText("Quick Tools"),
            SizedBox(height: 20),
            /// Quick Tools:
            GridView.count(
              crossAxisCount: size.width > 600 ? 4 : 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: [
                customActivities("assets/images/donation/activities/history.png", "Donation History", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => DonationHistory()));
                }),
                customActivities("assets/images/donation/activities/view.png", "View requester", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RequesterList()));
                }),
                customActivities("assets/images/donation/activities/report.png", "Your Reports", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => DonorReportScreen(donorId: userId!, donorName: userProvider.userData?['username'])));
                }),
                customActivities("assets/images/donation/activities/truck.png", "PickUp History", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PickupHistory()));
                }),
              ],
            ),
            SizedBox(height: 20),
            /// Recent Donations:
            Row(
              children: [ customText("Recent Donations"),
                SizedBox(width: size.width * 0.4),
                InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>DonationHistory()));
                  },
                  child: Text("See all",style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w500
                  ),),
                )

              ],
            ),
            SizedBox(height: 20,),
            /// Donation History:
            DonationHistoryList(isPadding: false,)



          ],
        ),
      ),
    );
  }
}
/// Custom Container:
Widget customContainer(String image, String text, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          height: 65,
          width: 65,
          child: Center(child: Image.asset(image, width: 30, height: 30)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Color(0XFF9CCCF2)),
          ),
        ),
        SizedBox(height: 3),
        Text(
          text,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: "Poppins", fontSize: 12, fontWeight: FontWeight.w500, color: Color(0XFF9D9D9D)),
        )
      ],
    ),
  );
}
/// Banner:
 customBanner(BuildContext context){
  return   Container(
    width: double.infinity,
    height: 140,
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: Color(0XFF9CCCF2)
        )
    ),
    child: Stack(
      children: [
        Row(
          children: [
            Column(
              children: [
                SizedBox(height: 10,),
                Text('Sharing Food to Help \nthe Needy',
                    style: TextStyle(fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Poppins")),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    height: 40,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),

                          ),
                          side: BorderSide(
                              color: Color(0XFF78C3FF)
                          )
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>CategoriesBasedRequester(category: "Food")));
                      },
                      child: Center(
                        child: Text('Donate Now',style: TextStyle(
                            color: Color(0XFF78C3FF),
                            fontFamily: "POppins",
                            fontWeight: FontWeight.w500,
                            fontSize: 13
                        ),),
                      ),
                    ),
                  ),
                ),
              ],

            ),

          ],
        ),
        Positioned(
            bottom: 5,
            right: 0,
            child: Image.asset(
              "assets/images/donation/banner/banner.png",
              fit: BoxFit.cover,
              width: 100,height: 100,))
      ],
    ),
  );
 }
 /// Text:
 customText(String text){
  return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,fontFamily: "Poppins")));
 }
 /// Activities:
 customActivities(String image, String text,VoidCallback onPressed){
  return  InkWell(
    onTap: onPressed,
    child: Container(
      width: 100,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color(0XFFF2F9FF),
        border: Border.all(
            color: Colors.white
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3), // Shadow color with opacity
            spreadRadius: 2, // How wide the shadow spreads
            blurRadius: 5, // How soft the shadow looks
            offset: Offset(3, 3), // X and Y offset of the shadow
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image,height: 50,width: 50,),
          SizedBox(height: 20,),
          Text(text,style: TextStyle(fontWeight: FontWeight.w400,fontSize: 13,fontFamily: "Poppins"),),


        ],
      ),

    ),
  );

 }