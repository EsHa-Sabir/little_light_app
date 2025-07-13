import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp_project/widgets/toast_message.dart';
import 'package:intl/intl.dart';
import 'package:fyp_project/widgets/appbar.dart';

class ManageDonationsScreen extends StatefulWidget {
  @override
  _ManageDonationsScreenState createState() => _ManageDonationsScreenState();
}

class _ManageDonationsScreenState extends State<ManageDonationsScreen> {
  /// Search Controller:
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Custom AppBar
      appBar: customAppBarForScreens('Manage Donations'),
      body: Column(
        children: [
          /// Search Field:
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search Donations",
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

          /// Donations List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('donations')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(color: Color(0xFF9CCDF2)),
                  );
                }

                var allDonations = snapshot.data!.docs;

                /// Apply Search Filter:
                var filteredDonations = allDonations.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  var name = data['requesterName'].toString().toLowerCase();
                  var type = data['category'].toString().toLowerCase();
                  return name.contains(searchQuery) || type.contains(searchQuery);
                }).toList();

                return Column(
                  children: [
                    /// Display Total Donations Count
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Total Donations: ${filteredDonations.length}",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: "Poppins"),
                      ),
                    ),

                    /// Donations List
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredDonations.length,
                        itemBuilder: (context, index) {
                          var data = filteredDonations[index].data() as Map<String, dynamic>;
                          String donorId = data['donorId'];
                          Timestamp timestamp = data['timestamp'];
                          String formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate());

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance.collection('users').doc(donorId).get(),
                            builder: (context, donorSnapshot) {
                              if (donorSnapshot.connectionState == ConnectionState.waiting) {
                                return SizedBox(); // ✅ Removed extra loading indicator
                              }

                              var donorData = donorSnapshot.data?.data() as Map<String, dynamic>? ?? {};
                              String donorName = donorData['username'] ?? 'Unknown Donor';
                              String donorImage = donorData['image'] ?? '';

                              return Card(
                                color: Colors.white,
                                elevation: 3,
                                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(color: Color(0xFF9CCDF2)),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Color(0xFF9CCDF2),
                                    backgroundImage: donorImage.isNotEmpty ? NetworkImage(donorImage) : null,
                                    child: donorImage.isEmpty ? Icon(Icons.person, color: Colors.white) : null,
                                  ),
                                  title: Text(
                                    "Donation Type - ${data['category']}",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Donor: $donorName\nRequester: ${data['requesterName']}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      Text(
                                        data['amount'] == null
                                            ? "Quantity: ${data['quantity']}"
                                            : (data['quantity'] == null
                                            ? "Amount: ${data['amount']} PKR"
                                            : "No Data Available"),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      Text(
                                        "Submitted on: $formattedDate",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red.shade400, size: 20),
                                    onPressed: () => deleteDonation(filteredDonations[index].id),
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

  /// Delete Donation:
  void deleteDonation(String id) async {
    bool confirmDelete = await showDeleteConfirmationDialog();
    if (confirmDelete) {
      await FirebaseFirestore.instance.collection('donations').doc(id).delete();
      showToast(message: 'Successfully deleted donation');
    }
  }

  /// Delete Confirmation Dialog:
  Future<bool> showDeleteConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        backgroundColor: Colors.white,
        title: Text(
          "Delete Donation",
          style: TextStyle(
            fontFamily: "Poppins",
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        content: Text(
          "Are you sure you want to delete this donation?",
          style: TextStyle(
            fontFamily: "Poppins",
            fontWeight: FontWeight.w400,
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              "Cancel",
              style: TextStyle(color: Color(0xFF9CCDF2), fontSize: 13, fontWeight: FontWeight.w500, fontFamily: "Poppins"),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              "Delete",
              style: TextStyle(color: Color(0xFF9CCDF2), fontSize: 13, fontWeight: FontWeight.w500, fontFamily: "Poppins"),
            ),
          ),
        ],
      ),
    ) ??
        false;
  }
}
