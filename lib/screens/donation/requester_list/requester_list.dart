import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_project/widgets/appbar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../backend/requests_list/requests_list.dart';
import '../../../backend/user/user_provider.dart';
import '../donation_forms/financial_donation.dart';
import '../donation_forms/physical_donation.dart';

class RequesterList extends StatefulWidget {
  const RequesterList({Key? key}) : super(key: key);

  @override
  _RequesterListState createState() => _RequesterListState();
}

class _RequesterListState extends State<RequesterList> {
  /// Search Controller:
  final TextEditingController _searchController = TextEditingController();
  /// For Searching Purpose:
  String searchQuery = "";
  /// Fetch User Id:
  String? userId= FirebaseAuth.instance.currentUser?.uid;
@override
  void initState() {
    super.initState();
    /// Fetch User Data:
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
      appBar: customAppBarForScreens("View Requester"),
      body: Column(
        children: [
          const SizedBox(height: 8),
          /// Search:
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: SizedBox(
              height: 50,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: "Search by name or category",
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
            child: FutureBuilder<List<Map<String, dynamic>>>(
              /// Fetch Request:
              future: fetchRequestsWithUsers(),
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
                      "Error loading requesters",
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }
                final requesters = snapshot.data!
                    .where((doc) {
                  final name = doc['user']['username']
                      .toString()
                      .toLowerCase();
                  final category =
                  doc['requestType'].toString().toLowerCase();
                  return name.contains(searchQuery) ||
                      category.contains(searchQuery);
                })
                    .toList();

                if (requesters.isEmpty) {
                  return Column(

                    children: [
                      SizedBox(
                        height: 100,
                      ),
                      /// Image:
                      Center(
                        child: Image.asset(
                          "assets/images/donation/request_list/search.gif",
                          width: 100,
                          height: 100,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Center(
                        child: Text(
                          "No requesters match your search.",
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

                return ListView.builder(
                  itemCount: requesters.length,
                  itemBuilder: (context, index) {
                    final data = requesters[index];
                    final user = data['user'];
                    final status = data['status'] ?? "Pending";
                    final category = data['requestType'] ?? "No Type ";
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
                              customTitle("Request Type:"),
                              SizedBox(height: 1,),
                              customSubtitle(category),
                              SizedBox(height: 3,),
                              customTitle("Date/Time:"),
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
                                /// Accept Button
                                TextButton(
                                  onPressed: () {
                                    if(category=='Book'||category=='Cloth'||category=='Food'){
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                          PhysicalDonation(requesterId:data['requesterId'] ?? "",
                                              category:category,
                                              name:data['name'] ?? "",requestId:  data['id'] ?? "",)));
                                    }else{
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                          FinancialDonation(requesterId:data['requesterId'] ?? "",
                                              category:category,
                                              name:data['name'] ?? "",requestId:    data['id'] ?? "",)));
                                    }
                                    updateRequestStatus(
                                        data['id'] ?? "",
                                        data['requesterId'] ?? "",
                                      "Request Update", "Your Request has been Accepted by ${ userProvider.userData?['username'] ?? ""}",
                                        "Accepted",userId!,context
                                    );

                                    setState(() {});
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
                                /// Reject Button
                                TextButton(
                                  onPressed: () {
                                    updateRequestStatus(
                                        data['id'] ?? "",
                                        data['requesterId'] ?? "",
                                      "Request Update", "Your Request has been Rejected by ${ userProvider.userData?['username'] ?? ""}", "Rejected",userId!
                                    ,context);

                                    setState(() {});
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
                          /// Bottom Sheet:
                            onTap: () => showBottomSheet1(context,data)

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
