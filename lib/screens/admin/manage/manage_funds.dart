import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_project/widgets/appbar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../chat/chat_room.dart';


class ManageFundsScreen extends StatefulWidget {
  @override
  _ManageFundsScreenState createState() => _ManageFundsScreenState();
}

class _ManageFundsScreenState extends State<ManageFundsScreen> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  double totalFunds = 0.0;
  String? adminId;

  @override
  void initState() {
    super.initState();
    fetchAdminIdAndFunds();
  }

  /// ✅ Fetch Admin ID & Total Funds
  Future<void> fetchAdminIdAndFunds() async {
    try {
      adminId = FirebaseAuth.instance.currentUser?.uid;
      if (adminId == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: Admin is not logged in!")));
        return;
      }

      DocumentSnapshot fundsSnapshot =
      await FirebaseFirestore.instance.collection('funds').doc('admin').get();

      if (fundsSnapshot.exists) {
        setState(() {
          totalFunds = (fundsSnapshot['totalFunds'] ?? 0.0).toDouble();
        });
      }
    } catch (e) {
      print("Error fetching admin ID or funds: $e");
    }
  }

  /// ✅ Fetch Requester Data
  Future<Map<String, dynamic>?> fetchRequesterData(String requesterId) async {
    try {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(requesterId).get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        print("Requester not found in users collection!");
        return null;
      }
    } catch (e) {
      print("Error fetching requester data: $e");
      return null;
    }
  }
  Future<Map<String, dynamic>?> fetchRequestDetails(String requestId) async {
    try {
      DocumentSnapshot requestDoc = await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .get();

      if (requestDoc.exists) {
        return requestDoc.data() as Map<String, dynamic>;
      } else {
        print("Request not found!");
        return null;
      }
    } catch (e) {
      print("Error fetching request details: $e");
      return null;
    }
  }

  Future<void> _showRequestDetailsBottomSheet(String requestId, String requesterId) async {
    // Fetch request details from Firestore
    DocumentSnapshot requestSnapshot = await FirebaseFirestore.instance.collection('requests').doc(requestId).get();
    if (!requestSnapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Request details not found.")));
      return;
    }
    Map<String, dynamic> requestDetails = requestSnapshot.data() as Map<String, dynamic>;

    // Fetch requester details
    Map<String, dynamic>? requesterData = await fetchRequesterData(requesterId);
    if (requesterData == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Requester details not found.")));
      return;
    }

    // Show the bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Requester Information
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF9CCDF2),
                backgroundImage: requesterData['image'] != null ? NetworkImage(requesterData['image']) : null,
                child: requesterData['image'] == null ? const Icon(Icons.person, color: Colors.white, size: 50) : null,
              ),
              const SizedBox(height: 10),
              Text(
                requesterData['username'] ?? 'Requester Name',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, fontFamily: "Poppins"),
              ),
              Text(
                requesterData['mobile'] ?? 'No Phone Provided',
                style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w400, fontFamily: "Poppins"),
              ),
              const SizedBox(height: 15.0),
              // Chat Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(
                    userName: requesterData['username'] ?? "",
                    userId: requesterId,
                    imageurl: requesterData['image'] ?? "",
                  )));
                },
                icon: const Icon(Icons.chat_outlined, color: Colors.white),
                label: const Text(
                  'Chat Now',
                  style: TextStyle(color: Colors.white, fontFamily: "Poppins", fontWeight: FontWeight.w500, fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9CCDF2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 20),
              // Request Description
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Request Description",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: "Poppins"),
                ),
              ),
              const Divider(color: Color(0xFF9CCDF2)),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  requestDetails['description'] ?? 'No description provided.',
                  style: const TextStyle(fontSize: 12, fontFamily: "Poppins", fontWeight: FontWeight.w300),
                ),
              ),
              const SizedBox(height: 16.0),
              // Google Map with Request Location
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      requestDetails['location']?['latitude'] ?? 0.0,
                      requestDetails['location']?['longitude'] ?? 0.0,
                    ),
                    zoom: 14.0,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('requestLocation'),
                      position: LatLng(
                        requestDetails['location']?['latitude'] ?? 0.0,
                        requestDetails['location']?['longitude'] ?? 0.0,
                      ),
                    ),
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  /// ✅ Release Funds
  Future<void> _releaseFund(String donationId, String requesterId, double amount, String requestId) async {
    if (adminId == null) {
      await fetchAdminIdAndFunds();
      if (adminId == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: Admin ID not found.")));
        return;
      }
    }

    bool confirmRelease = await showReleaseConfirmationDialog();
    if (!confirmRelease) return;

    try {
      DocumentReference fundsRef =
      FirebaseFirestore.instance.collection('funds').doc('admin');
      DocumentSnapshot fundsSnapshot = await fundsRef.get();

      if (!fundsSnapshot.exists || (fundsSnapshot['totalFunds'] ?? 0.0) < amount) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Insufficient funds!")));
        return;
      }

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot freshFundsSnapshot = await transaction.get(fundsRef);
        double updatedFunds = (freshFundsSnapshot['totalFunds'] ?? 0.0).toDouble();

        if (updatedFunds < amount) throw Exception("Not enough funds");

        transaction.update(fundsRef, {'totalFunds': updatedFunds - amount});

        transaction.set(
            FirebaseFirestore.instance.collection('paymentsReleased').doc(), {
          'requesterId': requesterId,
          'requestId': requestId,
          'donationId': donationId,
          'amountReleased': amount,
          'timestamp': FieldValue.serverTimestamp(),
        });

        transaction.update(
            FirebaseFirestore.instance.collection('donations').doc(donationId),
            {'status': 'Passed'});
      });

      setState(() => totalFunds -= amount);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Fund Released Successfully!")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  /// ✅ Confirmation Dialog
  Future<bool> showReleaseConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        title: Center(
          child: Text("Confirm Fund Release",style: TextStyle(
            fontFamily: "Poppins",
            fontWeight: FontWeight.w500,
            fontSize: 13
          ),),
        ),
        content: Text("Are you sure you want to release this fund?",style: TextStyle(
            fontFamily: "Poppins",
            fontWeight: FontWeight.w400,
            fontSize: 12
        ),),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text("Cancel", style: TextStyle(color: Color(0xFF9CCCF2)))),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text("Release", style: TextStyle(color: Color(0xFF9CCCF2)))),
        ],
      ),
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBarForScreens('Manage Funds'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: "Search by Name",
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
                  onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
                ),
                SizedBox(height: 10),
                Text("Total Available Funds: PKR ${totalFunds.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('donations')
                  .where('category', whereIn: ['Wedding', 'Education', 'Health'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator(
                  color: Color(0xFF9CCDF2),
                ));

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    String donationId = doc.id;
                    String requesterId = data['requesterId'] ?? "";
                    String requestId = data['requestId'] ?? '';
                    double amount = double.tryParse(data['amount'].toString()) ?? 0.0;
                    String status = data['status'] ?? "Pending";

                    return Card(
                      color: Colors.white,
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0XFF9CCCF2),), // Border color and width
                          borderRadius: BorderRadius.circular(8), // Rounded corners
                        ),
                        child: ListTile(
                          leading: FutureBuilder<Map<String, dynamic>?>(
                            future: fetchRequesterData(requesterId),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return CircleAvatar(
                                  backgroundColor: Colors.grey[300],
                                  child: Icon(Icons.person, color: Colors.white),
                                );
                              }
                              var requesterData = snapshot.data!;
                              String imageUrl = requesterData['image'] ?? '';

                              return imageUrl.isNotEmpty
                                  ? CircleAvatar(
                                radius: 25,
                                backgroundColor: Color(0xFF9CCDF2),
                                backgroundImage: NetworkImage(imageUrl),
                              )
                                  : CircleAvatar(
                                radius: 20,
                                backgroundColor: Color(0xFF9CCDF2),
                                child: Icon(Icons.person, color: Colors.white),
                              );
                            },
                          ),
                          title: FutureBuilder<Map<String, dynamic>?>(
                            future: fetchRequesterData(requesterId),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return Text("Loading...");
                              var requesterData = snapshot.data!;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Request Type - ${data['category'] ?? 'N/A'}", style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.w500),),
                                  Text("Requester: ${requesterData['username'] ?? 'Unknown'}",
                                    style: TextStyle( fontSize: 12,
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.w400),),
                                  Text("Phone: ${requesterData['mobile'] ?? 'N/A'}",
                                    style: TextStyle( fontSize: 12,
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.w400),),
                                  Text("Amount: PKR $amount", style: TextStyle( fontSize: 12,
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.w400),)
                                ],
                              );
                            },
                          ),
                          trailing: status == "Pending"
                              ? TextButton(
                            onPressed: () => _releaseFund(donationId, requesterId, amount, requestId),
                            child: Text("Release", style: TextStyle( fontSize: 12,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w400,color: Colors.blue),),
                          )
                              : Icon(Icons.check_circle, color: Colors.green),
                            /// Bottom Sheet:
                          onTap: (){
                            _showRequestDetailsBottomSheet(requestId, requesterId);
                          },

                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
