import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../screens/chat/chat_room.dart';
import '../../widgets/toast_message.dart';
import '../notification/notification.dart';



/// Fetch Request With Users:
Future<List<Map<String, dynamic>>> fetchRequestsWithUsers() async {
  try {
    print("Fetching requests from Firestore...");

    final requestsSnapshot =
    await FirebaseFirestore.instance.collection('requests').get();

    List<Map<String, dynamic>> mergedData = [];

    for (var request in requestsSnapshot.docs) {
      // ✅ Ensure 'requesterId' exists before accessing
      if (!request.data().containsKey('requesterId')) {
        print("Skipping document ${request.id}, 'requesterId' missing.");
        continue; // Skip this document
      }

      final requesterId = request['requesterId'];
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(requesterId)
          .get();

      if (userSnapshot.exists) {
        mergedData.add({
          'id': request.id, // Document ID
          ...request.data(),
          'user': userSnapshot.data(),
        });
      }
    }
    mergedData.sort((a, b) {
      if (a['status'] == 'Accepted' && b['status'] != 'Accepted'||a['status'] == 'Rejected' && b['status'] != 'Rejected') {
        return 1; // Move Accepted to the bottom
      } else if (a['status'] != 'Accepted' && b['status'] == 'Accepted'||a['status'] != 'Rejected' && b['status'] == 'Rejected') {
        return -1; // Keep non-Accepted at the top
      } else {
        // Sort by creation time for the same status
        final aTimestamp = a['createdAt'] ?? DateTime.now();
        final bTimestamp = b['createdAt'] ?? DateTime.now();
        return bTimestamp.compareTo(aTimestamp); // Newest first
      }
    });


    print("Fetched ${mergedData.length} requests successfully.");
    return mergedData;
  } catch (e) {
    print("Error fetching requests: $e");
    return [];
  }
}
/// Update Request Status:
void updateRequestStatus(
    String requestId,
    String requesterId,
    String title,
    String message,
    String status,
    String donorId,
    BuildContext context
    ) async {
  if (requestId.isEmpty) {
    if (context.mounted) {
      showToast(message: "Invalid Request ID", context: context);
    }
    return;
  }

  try {
    await FirebaseFirestore.instance
        .collection('requests')
        .doc(requestId)
        .update({'status': status, 'donorId': donorId});

    sendNotification1(requesterId, title, message);
    sendNotification(requesterId, title, message);

    if (context.mounted) {
      showToast(message: "Status Updated Successfully", context: context);
    }
  } catch (e) {
    if (context.mounted) {
      showToast(message: "Error updating status: $e", context: context);
    }
  }
}

/// Title:
customTitle(String text){
  return Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,style: TextStyle(
        color: Color(0XFF7E7E7E),
        fontFamily: "Poppins",
        fontSize: 12,
        fontWeight: FontWeight.w400
    ),
    ),
  );
}
/// SubTitle
customSubtitle(String text){
  return Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,style: TextStyle(
        color: Colors.black,
        fontFamily: "Poppins",
        fontSize: 12,
        fontWeight: FontWeight.w400
    ),
    ),
  );
}
/// Fetch Request With Users Based On Category:
Future<List<Map<String, dynamic>>> fetchRequestsWithUsersBasedOnCategory(String category) async {
  final requestsSnapshot =
  await FirebaseFirestore.instance.collection('requests').where("requestType",isEqualTo: category).get();

  List<Map<String, dynamic>> mergedData = [];

  for (var request in requestsSnapshot.docs) {
    final requesterId = request['requesterId'];
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(requesterId)
        .get();

    if (userSnapshot.exists) {
      mergedData.add({
        'id': request.id, // Add the document ID here
        ...request.data(),
        'user': userSnapshot.data(),
      });
    }
  }

  // Sort requests: Pending requests first, sorted by timestamp, then Accepted
  mergedData.sort((a, b) {
    if (a['status'] == 'Accepted' && b['status'] != 'Accepted') {
      return 1; // Move Accepted to the bottom
    } else if (a['status'] != 'Accepted' && b['status'] == 'Accepted') {
      return -1; // Keep non-Accepted at the top
    } else {
      // Sort by creation time for the same status
      final aTimestamp = a['createdAt'] ?? DateTime.now();
      final bTimestamp = b['createdAt'] ?? DateTime.now();
      return bTimestamp.compareTo(aTimestamp); // Newest first
    }
  });

  return mergedData;
}
/// BottomSheet:
Future<void> showBottomSheet1(BuildContext context, Map<String, dynamic> data) async {
  final user = data['user'];
  final location = data['location'];
  final customIcon = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(size: Size(48, 48)),
    "assets/images/donation/location/marker.png",
  );
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(25.0),
      ),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0XFF9CCCF2),
              backgroundImage: user['image'] != null
                  ? NetworkImage(user['image'])
                  : null,
              child: user['image'] == null
                  ? const Icon(
                Icons.person,
                color: Colors.white,
                size: 50,
              )
                  : null,
            ),
            const SizedBox(height: 5),
            Text(
              user['username'] ?? 'Requester Name',
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  fontFamily: "Poppins"),
            ),
            Text(
              data['phone'] ?? 'No Phone Provided',
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Poppins"),
            ),
            const SizedBox(height: 15.0),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatScreen(
                    userName: user['username']??"",
                    userId: data["requesterId"]??"",
                    imageurl: user['image'])))??"";
              },
              icon: const Icon(Icons.chat_outlined,color: Colors.white,),
              label: const Text(
                'Chat Now',
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w500,
                    fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0XFF9CCCF2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Request Description",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Poppins"),
              ),
            ),
            const Divider(color: Color(0XFF9CCCF2)),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                data['description'] ?? 'No description provided.',
                style: const TextStyle(
                    fontSize: 12,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w300),
              ),
            ),
            const SizedBox(height: 16.0),
            // Google Map with a custom marker
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    location?['latitude'] ?? 0.0,
                    location?['longitude'] ?? 0.0,
                  ),
                  zoom: 14.0,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('requesterLocation'),
                    position: LatLng(
                      location?['latitude'] ?? 0.0,
                      location?['longitude'] ?? 0.0,
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

