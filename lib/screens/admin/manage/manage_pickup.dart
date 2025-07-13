import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fyp_project/widgets/appbar.dart';

import '../../../widgets/toast_message.dart';

class ManagePickupRequestsScreen extends StatefulWidget {
  @override
  _ManagePickupRequestsScreenState createState() => _ManagePickupRequestsScreenState();
}

class _ManagePickupRequestsScreenState extends State<ManagePickupRequestsScreen> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBarForScreens('Manage Pickup Requests'),
      body: Column(
        children: [
          /// 🔹 **Search Bar**
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10, left: 15, right: 15),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search by Donor Name or Status",
                labelStyle: TextStyle(
                  fontFamily: "Poppins",
                  color: Color(0xFF989898),
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
                prefixIcon: Icon(Icons.search),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF9CCDF2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFF9CCDF2)),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          /// 🔹 **Pickup Requests List with Total Count**
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pickup_requests')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator(color: Color(0xFF9CCDF2)));
                }

                var allRequests = snapshot.data!.docs;

                /// 🔹 **Apply Search Filter**
                var filteredRequests = allRequests.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  var status = data['status'].toString().toLowerCase();
                  return status.contains(searchQuery);
                }).toList();

                return Column(
                  children: [
                    // 🔹 **Total Pickup Requests Count**
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Total Pickup Requests: ${filteredRequests.length}",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: "Poppins"),
                      ),
                    ),

                    // 🔹 **Filtered Pickup Requests List**
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredRequests.length,
                        itemBuilder: (context, index) {
                          var data = filteredRequests[index].data() as Map<String, dynamic>;
                          String requestId = filteredRequests[index].id;
                          String donorId = data['donorId'] ?? "";
                          String requesterId = data['requesterId'] ?? "";
                          String volunteerId = data['volunteerId'] ?? "";
                          String pickupLocation = data['pickupAddress'] ?? "";
                          String deliveryLocation = data['deliveryAddress'] ?? "";
                          String status = data['status'] ?? "";
                          Timestamp timestamp = data['timestamp'];
                          String formattedDate =
                          DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate());

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance.collection('users').doc(donorId).get(),
                            builder: (context, donorSnapshot) {
                              String donorName = "Unknown Donor";
                              String donorImage = "";
                              if (donorSnapshot.hasData && donorSnapshot.data!.exists) {
                                var donorData = donorSnapshot.data!.data() as Map<String, dynamic>;
                                donorName = donorData['username'] ?? "Unknown Donor";
                                donorImage = donorData['image'] ?? '';
                              }

                              return FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance.collection('users').doc(requesterId).get(),
                                builder: (context, requesterSnapshot) {
                                  String requesterName = "Unknown Requester";
                                  if (requesterSnapshot.hasData && requesterSnapshot.data!.exists) {
                                    var requesterData = requesterSnapshot.data!.data() as Map<String, dynamic>;
                                    requesterName = requesterData['username'] ?? "Unknown Requester";
                                  }

                                  return FutureBuilder<DocumentSnapshot>(
                                    future: status == "Accepted"
                                        ? FirebaseFirestore.instance.collection('users').doc(volunteerId).get()
                                        : null,
                                    builder: (context, volunteerSnapshot) {
                                      String volunteerName = "-";

                                      if (status == "Accepted") {
                                        if (volunteerSnapshot.connectionState == ConnectionState.waiting) {
                                          return Center(child: CircularProgressIndicator(color:Color(0xFF9CCDF2))); // Or a placeholder
                                        } else if (volunteerSnapshot.hasData && volunteerSnapshot.data != null && volunteerSnapshot.data!.exists) {
                                          var volunteerData = volunteerSnapshot.data!.data() as Map<String, dynamic>;
                                          volunteerName = volunteerData['username'] ?? "Unknown Volunteer";
                                        } else {
                                          volunteerName = "Unknown Volunteer";
                                        }
                                      }

                                      return Card(
                                        color: Colors.white,
                                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Color(0xFF9CCDF2)),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: ListTile(
                                            leading: donorImage.isNotEmpty
                                                ? CircleAvatar(
                                              radius: 25,
                                              backgroundColor: Color(0xFF9CCDF2),
                                              backgroundImage: NetworkImage(donorImage),
                                            )
                                                : CircleAvatar(
                                              radius: 25,
                                              backgroundColor: Color(0xFF9CCDF2),
                                              child: Icon(Icons.person, color: Colors.white),
                                            ),
                                            title: Text(
                                              "Donor: $donorName",
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontFamily: "Poppins",
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("Requester: $requesterName", style: TextStyle(fontSize: 12, fontFamily: "Poppins")),
                                                Text("Pickup: $pickupLocation", style: TextStyle(fontSize: 12, fontFamily: "Poppins")),
                                                Text("Delivery: $deliveryLocation", style: TextStyle(fontSize: 12, fontFamily: "Poppins")),
                                                Text("Submitted on: $formattedDate", style: TextStyle(fontSize: 12, fontFamily: "Poppins")),
                                                Row(
                                                  children: [
                                                    Text("Status: ", style: TextStyle(fontSize: 12, fontFamily: "Poppins")),
                                                    Text(
                                                      status,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontFamily: "Poppins",
                                                        color: status == "Pending"
                                                            ? Colors.orange
                                                            : status == "Accepted"
                                                            ? Colors.green
                                                            : Colors.red,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                if (status == "Accepted")
                                                  Text("Accepted by: $volunteerName", style: TextStyle(fontSize: 12, fontFamily: "Poppins")),
                                              ],
                                            ),
                                            trailing: CircleAvatar(
                                              backgroundColor: Colors.grey.shade200,
                                              child: IconButton(
                                                icon: Icon(Icons.delete, color: Colors.red),
                                                onPressed: () => deletePickupRequest(requestId),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );

                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 **Function to Delete Pickup Request**
  void deletePickupRequest(String requestId) async {
    bool confirmDelete = await showDeleteConfirmationDialog();
    if (confirmDelete) {
      await FirebaseFirestore.instance.collection('pickup_requests').doc(requestId).delete();
      showToast(message: 'Successfully delete pickup request');
    }
  }

  /// 🔹 **Delete Confirmation Dialog**
  Future<bool> showDeleteConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        backgroundColor: Colors.white,
        title: Text(
          "Delete Request",
          style: TextStyle(
              fontFamily: "Poppins",
              fontWeight: FontWeight.w500,
              fontSize: 14),),
        content: Text(
            "Are you sure you want to delete this request?",
            style: TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.w400,
                fontSize: 13)
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
                "Cancel",
                style: TextStyle(
                    color: Color(0xFF9CCDF2),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Poppins")
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
                "Delete",
                style: TextStyle(
                    color: Color(0xFF9CCDF2),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Poppins")),
          ),
        ],
      ),
    ) ?? false;
  }
}
