import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp_project/backend/requests_list/requests_list.dart';
import 'package:fyp_project/widgets/appbar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RequestDetail extends StatefulWidget {
  /// Get Id:
  String requestId;
   RequestDetail({super.key,required this.requestId});

  @override
  State<RequestDetail> createState() => _RequestDetailState();
}

class _RequestDetailState extends State<RequestDetail> {
  /// Map:
  Map<String, dynamic>? requestData;
  /// Location:
  LatLng? requestLocation;
  /// For Loading Purpose:
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    /// Fetch Request Detail:
    _fetchRequestDetails();
  }
  /// Fetch Request Detail:
  Future<void> _fetchRequestDetails() async {
    try {
      DocumentSnapshot doc =
      await FirebaseFirestore.instance.collection('requests').doc(widget.requestId).get();
      if (doc.exists) {
        setState(() {
          requestData = doc.data() as Map<String, dynamic>;
          requestLocation = LatLng(requestData!["location"]["latitude"], requestData!["location"]["longitude"]);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Request not found!")));
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error fetching request details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Appbar:
      appBar: customAppBarForScreens("Request Detail"),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0XFF9CCCF2),))
          : requestData == null
          ? Center(child: Text("No details available",style: TextStyle(
        fontSize: 13,fontWeight: FontWeight.w400,
        fontFamily: "Poppins",color: Colors.grey
      ),))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10,),

          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customTitle("Name:"),
                customSubtitle(requestData!["name"]??""),
                customTitle("Description:"),
                customSubtitle(requestData!["description"]??""),
                customTitle("Type:"),
                customSubtitle(requestData!["requestType"]??""),
                customTitle("Phone:"),
                customSubtitle(requestData!["phone"]??""),
                customTitle("Address:"),
                customSubtitle(requestData!["address"]??""),
              ],
            ),
          ),
          /// Map:
          Expanded(
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: requestLocation!,
                  zoom: 14,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId("requestLocation"),
                    position: requestLocation!,
                  ),
                },
              ),
            ),
          ),

        ],
      ),
    );
  }
}
