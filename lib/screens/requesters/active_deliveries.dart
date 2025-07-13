import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_project/screens/requesters/track_delivery.dart';
import 'package:fyp_project/widgets/appbar.dart';

class ActiveDeliveriesScreen extends StatelessWidget {
  /// Get Id:
  final String requesterId;

  ActiveDeliveriesScreen({required this.requesterId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Appbar:
      appBar: customAppBarForScreens("My Active Deliveries"),
      /// Fetch Pickup_Request:
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('pickup_requests')
            .where('requesterId', isEqualTo: requesterId)
            .where('delivery_status', whereIn: ["Pending", "In Transit"]) // ✅ Query Fix
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Color(0XFF9CCCF2),));
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          var activeRequests = snapshot.data?.docs ?? [];

          if (activeRequests.isEmpty) {
            return Column(
              children: [
                SizedBox(height: 30,),
                Image.asset("assets/images/request/tracking.gif",height: 200,width: 200,),
                SizedBox(height: 10,),
                Center(child: Text("No active deliveries.", style: TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,fontFamily: "Poppins"),)),
              ],
            );
          }
        /// Display request:
          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: activeRequests.length,
            itemBuilder: (context, index) {
              var request = activeRequests[index];
              return Card(
                color: Colors.white,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:  Color(0XFF9CCCF2)

                    ),

                  ),
                  child: ListTile(
                    title: customText1("Request: ${request['description']}",),
                    subtitle:customText("Status: ${request['delivery_status']}"),
                    trailing: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LiveTrackingScreen(pickupId: request.id),
                          ),
                        );
                      },
                      child: Text("Track",style: TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: Color(0XFF9CCCF2)
                      ),),
                    ),
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
customText(String text){
  return  Text(text,style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      fontFamily: "Poppins"
  ),);
}
customText1(String text){
  return  Text(text,style: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      fontFamily: "Poppins"
  ),);
}