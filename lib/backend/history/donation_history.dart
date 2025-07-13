import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:intl/intl.dart';

class DonationHistoryList extends StatelessWidget {
  final bool isPadding;
  const DonationHistoryList({super.key,required this.isPadding});


  @override
  Widget build(BuildContext context) {
    /// Fetch Id From Firebase:
    final donorId = FirebaseAuth.instance.currentUser!.uid;
    /// Fetch Donations:
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('donations')
          .where('donorId', isEqualTo: donorId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Color(0xFF9CCCF2)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Column(

            children: [
              SizedBox(height: 40,),
              /// Images:
              Center(child:  Image.asset("assets/images/donation/history/history.png",height: 100,width: 100,)),
              SizedBox(height: 10,),
              Center(
                child: Text(
                  "No donation history found",
                  style: TextStyle(fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,fontFamily: "Poppins"),
                ),
              ),
            ],
          );
        }
        /// Store data in List:
        final List<QueryDocumentSnapshot> donations = snapshot.data!.docs;
        donations.sort((a, b) {
          final Timestamp timeA = (a['timestamp'] ??
              Timestamp(0, 0)) as Timestamp;
          final Timestamp timeB = (b['timestamp'] ??
              Timestamp(0, 0)) as Timestamp;
          return timeB.compareTo(timeA);
        });
        /// Display Data:
        return ListView.separated(
          shrinkWrap: true,
          padding:isPadding? EdgeInsets.all(16):EdgeInsets.all(0),
          physics: NeverScrollableScrollPhysics(),
          itemCount: donations.length,
          separatorBuilder: (context, index) =>
              Column(
                children: [
                  /// Dash Line:
                  Dash(
                      direction: Axis.horizontal,
                      dashLength: 3,
                      length: 320,
                      dashColor: Color(0XFF9CCCF2)
                  ),
                  SizedBox(height: 10,),
                ],
              ),
          itemBuilder: (context, index) {
            final donation = donations[index].data() as Map<String, dynamic>;
            final String category = donation['category'] ?? "Unknown";
            final String name = donation['requesterName'] ?? "";
            final String? quantity = donation['quantity'] ;
            final Timestamp? timestamp = donation['timestamp'] as Timestamp?;
            final String formattedDate = timestamp != null
                ? DateFormat('dd-MM-yy,hh:mm a').format(timestamp.toDate())
                : "Unknown Date";
            final String? amount = donation['amount'] ;
           final String? status=donation['status'];
            return Row(
              children: [
                /// Category Icon:
                _buildCategoryIcon(category),
                SizedBox(width: 12),
                /// Data:
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Donation Type: $category",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500,
                            fontFamily: "Poppins"),
                      ),
                      SizedBox(height: 5),
                      Text("Requester Name: $name",style: TextStyle(
                          fontSize: 12, color: Colors.black87,
                          fontFamily: "Poppins",fontWeight: FontWeight.w400),),
                      Text(
                        amount == null
                            ? "Quantity: $quantity"
                            : (quantity == null ? "Amount: $amount PKR" : "No Data Available"),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      status!=null? RichText(
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
                      ):SizedBox(),
                      Text("Submitted On: $formattedDate",style: TextStyle(
                          fontSize: 12, color: Colors.black87,
                          fontFamily: "Poppins",fontWeight: FontWeight.w400),),

                      SizedBox(height: 5,)


                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
/// Category Based Icon:
Widget _buildCategoryIcon(String category) {
  IconData iconData;
  switch (category.toLowerCase()) {
    case 'book':
      iconData = Icons.menu_book;
      break;
    case 'cloth':
      iconData = Icons.shopping_bag;
      break;
    case 'financial support'||'education'||'wedding'||'health':
      iconData = Icons.attach_money;
      break;
    case 'food':
      iconData = Icons.restaurant;
      break;
    default:
      iconData = Icons.help_outline;
  }
  return Container(
    width: 50,
    height: 50,
    decoration: BoxDecoration(
      border: Border.all(color: Color(0XFF9CCCF2)),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Center(
      child: Icon(iconData, size: 28, color: Colors.black87),
    ),
  );
}
///  Status Color:
Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'passed':
      return Color(0XFF59968C);
    case 'Failed':
      return Color(0XFFFF5B5B);
    default:
      return Colors.grey;
  }
}
