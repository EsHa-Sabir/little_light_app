import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_project/widgets/appbar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../backend/requests_list/requests_list.dart';
import '../../../backend/user/user_provider.dart';
import '../donation_forms/financial_donation.dart';
import '../donation_forms/physical_donation.dart';

class CategoriesBasedRequester extends StatefulWidget {
  /// Category:
  final String category;
  const CategoriesBasedRequester({super.key,required this.category});
  @override
  State<CategoriesBasedRequester> createState() => _CategoriesBasedRequesterState();
}

class _CategoriesBasedRequesterState extends State<CategoriesBasedRequester> {
  /// Get User Id
  String? userId= FirebaseAuth.instance.currentUser?.uid;
  @override
  void initState() {
    super.initState();
    /// Fetch User Data From user Provider Class:
    if (userId != null) {
      Provider.of<UserProvider>(context, listen: false).fetchUserData(userId!,context);
    }

  }
  @override
  Widget build(BuildContext context) {
    /// User Provider:
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      /// App Bar:
      appBar: customAppBarForScreens("${widget.category} Requester"),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              /// Fetch Request:
              future: fetchRequestsWithUsersBasedOnCategory(widget.category),
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
                      style: TextStyle(color: Colors.red,
                      fontFamily: "Poppins",
                          fontWeight: FontWeight.w500,
                          fontSize: 13),

                    ),
                  );
                }
                final requesters = snapshot.data!;
                if (requesters.isEmpty) {
                  return Column(
                    children: [
                      SizedBox(
                        height: 100,
                      ),
                      Center(
                        /// Image:
                        child: Image.asset(
                          "assets/images/donation/request_list/search.gif",
                          width: 100,
                          height: 100,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Center(
                        child: Text(
                          "No requesters found for this category",
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
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0XFF9CCCF2)), // Border color
                          borderRadius: BorderRadius.circular(8), // Rounded corners
                        ),
                        /// Card:
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: const Color(0XFF9CCCF2),
                            backgroundImage: user['image'] != null ? NetworkImage(user['image']) : null,
                            child: user['image'] == null
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, // Align text to left
                            children: [
                              customTitle("Name:"),
                              customSubtitle(user['username'] ?? "No Name"),
                              SizedBox(height: 5),
                              customTitle("Request Type:"),
                              customSubtitle(category),
                              SizedBox(height: 5),
                              customTitle("Date/Time:"),
                              customSubtitle(date),
                              SizedBox(height: 5),
                              customTitle("Status:"),
                              customSubtitle(status),
                            ],
                          ),
                          trailing: status == "Pending"
                              ? Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center, // Center buttons
                            children: [
                              /// Accept Button:
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
                                  "Request Update",
                                  "Your Request has been Accepted by ${ userProvider.userData?['username'] ?? ""}",
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
                              /// Reject Button:
                              TextButton(
                                onPressed: () {
                                  updateRequestStatus(
                                    data['id'] ?? "",
                                    data['requesterId'] ?? "",
                                    "Request Update", "Your Request has been Rejected by ${ userProvider.userData?['username'] ?? ""}",
                                    "Rejected",userId!,context
                                  );
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
                            status,
                            style: TextStyle(
                              color: status == "Accepted" ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          /// Bottom Sheet:
                          onTap: () => showBottomSheet1(context, data),
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
