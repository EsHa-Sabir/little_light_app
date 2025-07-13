import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_project/widgets/appbar.dart';
import 'package:intl/intl.dart';

class PickupHistory extends StatelessWidget {
  const PickupHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Appbar:
      appBar: customAppBarForScreens("Pickup Request History"),
      /// Fetch pickup_requests:
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('pickup_requests')
            .where('donorId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Color(0xFF9CCCF2)));
          }
          print("Snapshot has data: ${snapshot.hasData}");
          print("Document count: ${snapshot.data?.docs.length}");

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Column(
              children: [
                SizedBox(height: 50),
                Center(child: Image.asset("assets/images/donation/history/pickup_history.png", height: 100, width: 100)),
                SizedBox(height: 10),
                Center(
                  child: Text(
                    "No Pickup history found",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey, fontFamily: "Poppins"),
                  ),
                ),
              ],
            );
          }

          final List<QueryDocumentSnapshot> pickupRequests = snapshot.data!.docs;
          pickupRequests.sort((a, b) {
            final Timestamp timeA = (a['timestamp'] ??
                Timestamp(0, 0)) as Timestamp;
            final Timestamp timeB = (b['timestamp'] ??
                Timestamp(0, 0)) as Timestamp;
            return timeB.compareTo(timeA);
          });
          return ListView.builder(
            itemCount: pickupRequests.length,
            itemBuilder: (context, index) {
              var pickupRequest =  pickupRequests[index].data() as Map<String, dynamic>;
              print("Fetched request: ${pickupRequest}");

              String pickupAddress = pickupRequest['pickupAddress'];
              String deliveryAddress = pickupRequest['deliveryAddress'];
              String status = pickupRequest['status'];
              Timestamp? timestamp = pickupRequest['timestamp'];

              String formattedDate = timestamp != null
                  ? DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate())
                  : "No Date";

              return Card(
                color: Color(0XFFE3F3FF),
                margin: EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),

                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Color(0xFF9CCCF2))
                  ),
                  child: ListTile(
                    leading: Image.asset('assets/images/donation/pickup/delivery.png',height: 50,width: 50,),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Pickup Location:",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500,
                              fontFamily: "Poppins"),
                        ),
                        Text(
                          "$pickupAddress",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400,
                              fontFamily: "Poppins"),
                        ),
                        Text(
                          "Delivery Location:",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500,
                              fontFamily: "Poppins"),
                        ),
                        Text(
                          "$deliveryAddress",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400,
                              fontFamily: "Poppins"),
                        ),
                        RichText(
                          text: TextSpan(
                            text: "Status: ",
                            style: TextStyle(
                                fontSize: 12, color: Colors.black87,
                                fontFamily: "Poppins",fontWeight: FontWeight.w400),
                            children: [
                              TextSpan(
                                text: status,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: _getStatusColor(status),
                                    fontFamily: "Poppins"
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text("Submitted On: $formattedDate",style: TextStyle(
                            fontSize: 12, color: Colors.black87,
                            fontFamily: "Poppins",fontWeight: FontWeight.w400),),
                        Text("Delivery Status: ${pickupRequest['delivery_status']??"N/A"}",style: TextStyle(
                            fontSize: 12, color: Colors.black87,
                            fontFamily: "Poppins",fontWeight: FontWeight.w400),),
                      ],
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

/// Status  Color:
Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'accepted':
      return Color(0XFF59968C);
    case 'rejected':
      return Color(0XFFFF5B5B);
    default:
      return Colors.grey;
  }
}
