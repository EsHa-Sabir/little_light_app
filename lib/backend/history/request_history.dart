import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:intl/intl.dart';

class RequestHistoryList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final requesterId = FirebaseAuth.instance.currentUser!.uid;

    /// Fetch Request From Firebase To Check Status:
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('requests')
          .where('requesterId', isEqualTo: requesterId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Color(0xFF9CCCF2)));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Column(
            children: [
              SizedBox(height: 100),
              Center(child: Image.asset("assets/images/donation/history/history_icon.png", width: 80, height: 80)),
              SizedBox(height: 10),
              Center(
                child: Text(
                  "No request history found",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey, fontFamily: "Poppins"),
                ),
              ),
            ],
          );
        }

        final List<QueryDocumentSnapshot> requests = snapshot.data!.docs;
        requests.sort((a, b) {
          final Timestamp timeA = (a['timestamp'] ?? Timestamp(0, 0)) as Timestamp;
          final Timestamp timeB = (b['timestamp'] ?? Timestamp(0, 0)) as Timestamp;
          return timeB.compareTo(timeA);
        });

        return ListView.separated(
          padding: EdgeInsets.all(16),
          itemCount: requests.length,
          separatorBuilder: (context, index) => Column(
            children: [
              Dash(direction: Axis.horizontal, dashLength: 3, length: 320, dashColor: Color(0XFF9CCCF2)),
              SizedBox(height: 10),
            ],
          ),
          itemBuilder: (context, index) {
            final request = requests[index].data() as Map<String, dynamic>;
            final String category = request['requestType'] ?? "Unknown";
            final String status = request['status'] ?? "Pending";
            final String requestId = requests[index].id;
            final Timestamp? timestamp = request['timestamp'] as Timestamp?;
            final String formattedDate =
            timestamp != null ? DateFormat('dd-MM-yy, hh:mm a').format(timestamp.toDate()) : "Unknown Date";

            return FutureBuilder<String>(
              /// Fetch Delivery Status or Donated Amount:
              future: fetchAmountOrDeliveryStatus(requestId, category),
              builder: (context, deliverySnapshot) {
                String displayText = "Pending"; // Default status
                if (deliverySnapshot.connectionState == ConnectionState.waiting) {
                  displayText = "Checking...";
                } else if (deliverySnapshot.hasData) {
                  displayText = deliverySnapshot.data!;
                }

                return Row(
                  children: [
                    /// Icon:
                    _buildCategoryIcon(category),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Type:
                          Text(
                            "Request Type: $category",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: "Poppins"),
                          ),
                          SizedBox(height: 5),
                          /// Status:
                          RichText(
                            text: TextSpan(
                              text: "Status: ",
                              style: TextStyle(fontSize: 12, color: Colors.black87, fontFamily: "Poppins", fontWeight: FontWeight.w400),
                              children: [
                                TextSpan(
                                  text: status,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: _getStatusColor(status),
                                    fontFamily: "Poppins",
                                  ),
                                ),
                              ],
                            ),
                          ),
                          /// Show Amount if Financial Request, else show Delivery Status
                          Text(
                            ["education", "health", "wedding", "financial support"].contains(category.toLowerCase())
                                ? "Donated Amount: $displayText"
                                : "Delivery Status: $displayText",
                            style: TextStyle(fontSize: 12, color: Colors.black87, fontFamily: "Poppins", fontWeight: FontWeight.w400),
                          ),
                          /// Date:
                          Text(
                            "Submitted On: $formattedDate",
                            style: TextStyle(fontSize: 12, color: Colors.black87, fontFamily: "Poppins", fontWeight: FontWeight.w400),
                          ),
                          SizedBox(height: 5),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  /// Fetch Delivery Status OR Donated Amount:
  Future<String> fetchAmountOrDeliveryStatus(String requestId, String category) async {
    try {
      if (["education", "health", "wedding", "financial support"].contains(category.toLowerCase())) {
        /// Fetch Donated Amount:
        var donationQuery = await FirebaseFirestore.instance
            .collection('donations')
            .where('requestId', isEqualTo: requestId)
            .limit(1)
            .get();

        if (donationQuery.docs.isNotEmpty) {
          return "${donationQuery.docs.first['amount'] ?? '0'} PKR";
        }
        return "0 PKR";
      } else {
        /// Fetch Delivery Status:
        var deliveryQuery = await FirebaseFirestore.instance
            .collection('pickup_requests')
            .where('requestId', isEqualTo: requestId)
            .limit(1)
            .get();

        if (deliveryQuery.docs.isNotEmpty) {
          return deliveryQuery.docs.first['delivery_status'] ?? "Pending";
        }
        return "Pending";
      }
    } catch (e) {
      return "Error";
    }
  }

  /// Category Related Icon
  Widget _buildCategoryIcon(String category) {
    IconData iconData;
    switch (category.toLowerCase()) {
      case 'book':
        iconData = Icons.menu_book;
        break;
      case 'cloth':
        iconData = Icons.shopping_bag;
        break;
      case 'financial support':
      case 'education':
      case 'wedding':
      case 'health':
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

  /// Get Status Color:
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
}
