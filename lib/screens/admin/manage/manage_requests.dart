import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fyp_project/widgets/appbar.dart';

import '../../../widgets/toast_message.dart';

class ManageRequestsScreen extends StatefulWidget {
  @override
  _ManageRequestsScreenState createState() => _ManageRequestsScreenState();
}

class _ManageRequestsScreenState extends State<ManageRequestsScreen> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBarForScreens('Manage Requests'),
      body: Column(
        children: [
          /// 🔹 **Search Bar**
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10, left: 15, right: 15),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search Requests",
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

          /// 🔹 **Requests List with Total Count**
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('requests')
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
                  var name = data['name'].toString().toLowerCase();
                  var category = data['requestType'].toString().toLowerCase();
                  return name.contains(searchQuery) || category.contains(searchQuery);
                }).toList();

                return Column(
                  children: [
                    // 🔹 **Total Requests Count**
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Total Requests: ${filteredRequests.length}",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: "Poppins"),
                      ),
                    ),

                    // 🔹 **Filtered Requests List**
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredRequests.length,
                        itemBuilder: (context, index) {
                          var data = filteredRequests[index].data() as Map<String, dynamic>;
                          String requestId = filteredRequests[index].id;
                          String requesterId = data['requesterId'] ?? "";
                          String requesterName = data['name'] ?? "";
                          String category = data['requestType'] ?? "";
                          String status = data['status'] ?? "";
                          Timestamp timestamp = data['timestamp'];
                          String formattedDate =
                          DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate());

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance.collection('users').doc(requesterId).get(),
                            builder: (context, userSnapshot) {
                              String imageUrl = "";
                              String phoneNumber = "N/A"; // Default phone number if not found
                              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                                var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                                imageUrl = userData['image'] ?? ''; // 🔹 Fetch image URL from users collection
                                phoneNumber = userData['mobile'] ?? "N/A"; // 🔹 Fetch phone number
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
                                    leading: imageUrl.isNotEmpty
                                        ? CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Color(0xFF9CCDF2),
                                      backgroundImage: NetworkImage(imageUrl),
                                    )
                                        : CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Color(0xFF9CCDF2),
                                      child: Icon(Icons.person, color: Colors.white),
                                    ),
                                    title: Text(
                                      "Request Type - $category",
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.w500),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Requester: $requesterName",
                                          style: TextStyle( fontSize: 12,
                                              fontFamily: "Poppins",
                                              fontWeight: FontWeight.w400), // 🔹 Always black
                                        ),
                                        Text(
                                          "Phone: $phoneNumber",
                                          style: TextStyle( fontSize: 12,
                                              fontFamily: "Poppins",
                                              fontWeight: FontWeight.w400), // 🔹 Always black
                                        ),
                                        Text(
                                          "Submitted on: $formattedDate",
                                          style: TextStyle( fontSize: 12,
                                              fontFamily: "Poppins",
                                              fontWeight: FontWeight.w400), // 🔹 Always black
                                        ),
                                        Row(
                                          children: [
                                            Text("Status: ", style: TextStyle( fontSize: 12,
                                                fontFamily: "Poppins",
                                                fontWeight: FontWeight.w400)),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: status == "Pending"
                                                    ? Colors.orange.withOpacity(0.2)
                                                    : status == "Accepted"
                                                    ? Colors.green.withOpacity(0.2)
                                                    : Colors.red.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                status,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontFamily: "Poppins",
                                                  color: status == "Pending"
                                                      ? Colors.orange
                                                      : status == "Accepted"
                                                      ? Colors.green
                                                      : Colors.red,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: CircleAvatar(
                                      backgroundColor: Colors.grey.shade200,
                                      child: IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red.shade400,size: 20,),
                                        onPressed: () => deleteRequest(requestId),
                                      ),
                                    ),
                                  ),
                                ),
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

  /// 🔹 **Function to Delete Request**
  void deleteRequest(String requestId) async {
    bool confirmDelete = await showDeleteConfirmationDialog();
    if (confirmDelete) {
      await FirebaseFirestore.instance.collection('requests').doc(requestId).delete();
      showToast(message: 'Successfully delete request');
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
