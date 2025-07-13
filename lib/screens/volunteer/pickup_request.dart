
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_project/backend/pickup_list/pickup_list.dart';
import 'package:fyp_project/widgets/appbar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../backend/requests_list/requests_list.dart';
import '../../backend/user/user_provider.dart';

class PickupRequest extends StatefulWidget {
  const PickupRequest({super.key});

  @override
  State<PickupRequest> createState() => _PickupRequestState();
}

class _PickupRequestState extends State<PickupRequest> {
  /// Search Controller:
  final TextEditingController _searchController = TextEditingController();
  /// Search Query:
  String searchQuery = "";
  /// Get Id:
  String? userId= FirebaseAuth.instance.currentUser?.uid;
  @override
  void initState() {
    super.initState();
    /// User Data:
    if (userId != null) {
      Provider.of<UserProvider>(context, listen: false).fetchUserData(userId!,context);
    }


  }



  @override
  Widget build(BuildContext context) {
    /// User Provider:
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      /// Appbar:
      appBar: customAppBarForScreens("Pickup & Drop Requests"),
      body: Column(
        children: [
          const SizedBox(height: 8),
          /// Search Bar:
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: SizedBox(
              height: 50,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: "Search by name",
                  hintStyle: const TextStyle(
                      fontSize: 13.5,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w400),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF9CCEF2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF9CCEF2)),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              /// Fetch Request:
              stream: fetchPickupRequestsWithUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0XFF9CCCF2),
                      ));
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "Error loading pickup requests",
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                final pickupRequest = snapshot.data!
                    .where((doc) {
                  final name = doc['user']['username']
                      .toString()
                      .toLowerCase();
                  return name.contains(searchQuery) ;
                })
                    .toList();

                if (pickupRequest.isEmpty) {
                  return Column(

                    children: [
                      SizedBox(
                        height: 100,
                      ),
                      /// Image:
                      Center(
                        child: Image.asset(
                          "assets/images/volunteer/no_delivery.png",
                          width: 70,
                          height: 70,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Center(
                        child: Text(
                          "No pickup request match your search.",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontFamily: "Poppins",
                              fontSize: 13,
                              color: Colors.grey),
                        ),
                      ),
                    ],
                  );
                }
                /// Display Request:
                return ListView.builder(
                  itemCount: pickupRequest.length,
                  itemBuilder: (context, index) {
                    final data = pickupRequest[index];
                    final user = data['user'];
                    final status = data['status'] ?? "Pending";
                    final date=data['timestamp'] != null
                        ? DateFormat('dd MMM yyyy, hh:mm a').format(data['timestamp'].toDate())
                        : "Unknown Date";
                    /// Card:
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0XFF9CCCF2),), // Border color and width
                          borderRadius: BorderRadius.circular(8), // Rounded corners
                        ),
                        child: ListTile(
                            leading:CircleAvatar(
                              radius: 30,
                              backgroundColor: const Color(0XFF9CCCF2),
                              backgroundImage: user['image'] != null
                                  ? NetworkImage(user['image'])
                                  : null,
                              child: user['image'] == null
                                  ? const Icon(
                                Icons.person,
                                color: Colors.white,
                              ) : null,
                            ),
                            title: Column(
                              children: [
                                customTitle("Name:"),
                                SizedBox(height: 1,),
                                customSubtitle(user['username'] ?? "No Name"),
                                SizedBox(height: 3,),
                                // customTitle("Pickup Address:"),
                                // SizedBox(height: 1,),
                                // customSubtitle(data['pickupAddress'] ?? "No Name"),
                                // customTitle("Delivery Address:"),
                                // SizedBox(height: 1,),
                                // customSubtitle(data['deliveryAddress'] ?? "No Name"),
                                // SizedBox(height: 3,),
                                customTitle("Submitted on:"),
                                SizedBox(height: 1,),
                                customSubtitle(date),
                                SizedBox(height: 3,),
                                customTitle("Status:"),
                                SizedBox(height: 1,),
                                customSubtitle(status),



                              ],
                            ),

                            trailing: status == "Pending"
                                ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                /// Accept Button:
                                TextButton(
                                  onPressed: () {

                                    updatePickupRequestStatus(
                                        data['id'] ?? "",
                                        data['donorId'] ?? "",
                                        "Pickup Request Update", "Your pickup Request has been Accepted by ${ userProvider.userData?['username'] ?? ""}",
                                        "Accepted",userId!
                                    ,context);

                                      setState(() {

                                      });

                                  },
                                  child: const Text(
                                    "Accept",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                SizedBox(width: 5), // Space between buttons

                                /// Reject Button:
                                TextButton(
                                  onPressed: () {
                                    updatePickupRequestStatus(
                                      data['id'] ?? "",
                                      data['donorId'] ?? "",
                                      "Pickup Request Update", "Your Request has been Rejected by ${ userProvider.userData?['username'] ?? ""}", "Rejected",userId!
                                   ,context );

                                    setState(() {

                                    });
                                  },
                                  child: const Text(
                                    "Reject",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            )
                                : Text(
                              status, // Show "Accepted" or "Rejected"
                              style: TextStyle(
                                color: status == "Accepted" ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            onTap: () => showBottomSheet2(context,data)

                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
