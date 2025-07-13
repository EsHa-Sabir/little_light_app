import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../screens/chat/chat_room.dart';
import '../../widgets/toast_message.dart';
import '../notification/notification.dart';

/// Fetch Pickup Request:
Stream<List<Map<String, dynamic>>> fetchPickupRequestsWithUsers() {
  return FirebaseFirestore.instance
      .collection('pickup_requests')
      .snapshots()
      .asyncMap((snapshot) async {
    List<Map<String, dynamic>> mergedData = [];

    for (var pickupRequest in snapshot.docs) {
      if (!pickupRequest.data().containsKey('donorId')) continue;
      final donorId = pickupRequest['donorId'];

      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(donorId)
          .get();

      if (userSnapshot.exists) {
        mergedData.add({
          'id': pickupRequest.id,
          ...pickupRequest.data(),
          'user': userSnapshot.data(),
        });
      }
    }

    /// Sorting logic
    mergedData.sort((a, b) {
      if ((a['status'] == 'Accepted' && b['status'] != 'Accepted') ||
          (a['status'] == 'Rejected' && b['status'] != 'Rejected')) {
        return 1;
      } else if ((a['status'] != 'Accepted' && b['status'] == 'Accepted') ||
          (a['status'] != 'Rejected' && b['status'] == 'Rejected')) {
        return -1;
      } else {
        final aTimestamp = a['createdAt'] ?? DateTime.now();
        final bTimestamp = b['createdAt'] ?? DateTime.now();
        return bTimestamp.compareTo(aTimestamp);
      }
    });

    return mergedData;
  });
}

/// Check Location is on or not:
Future<Position?> getCurrentLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    await Geolocator.openLocationSettings();
    await Future.delayed(Duration(seconds: 3)); // ✅ Thoda time dein settings open hone ka
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("❌ GPS abhi bhi disabled hai.");
      return null;
    }
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print("❌ Location permission abhi bhi denied hai.");
      return null;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    await Geolocator.openAppSettings();
    return null;
  }

  try {
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  } catch (e) {
    print("❌ Location fetch error: $e");
    return null;
  }
}

/// Update Request Status:
void updatePickupRequestStatus(
    String pickupId,
    String donorId,
    String title,
    String message,
    String status,
    String volunteerId,
    BuildContext context) async {

  if (pickupId.isEmpty) {
    showToast(message: "❌ Invalid Pickup ID", context: context);
    return;
  }

  if (status == "Rejected") {
    // Reject case: Location check ki zaroorat nahi
    try {
      await FirebaseFirestore.instance.collection('pickup_requests').doc(pickupId).update({
        'status': status,
        'volunteerId': volunteerId,
      });

      sendNotification1(donorId, title, message);
      sendNotification(donorId, title, message);

      showToast(message: "✅ Request Rejected", context: context);
    } catch (e) {
      showToast(message: "❌ Error rejecting request: $e", context: context);
      print("❌ Firestore Reject Error: $e");
    }
    return;
  }

  // Accept case: Pehle location check karein
  bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
  if (!isLocationEnabled) {
    bool userEnabled = await promptEnableLocation(context);
    if (!userEnabled) {
      showToast(message: "❌ Location is required to accept pickup request,Please Turn on location.", context: context);
      return;
    }
  }

  Position? position = await getCurrentLocation();
  if (position == null) {
    showToast(message: "❌ Could not fetch location. Enable GPS.", context: context);
    return;
  }

  try {
    await FirebaseFirestore.instance.collection('pickup_requests').doc(pickupId).update({
      'status': status,
      'volunteerId': volunteerId,
      'volunteerLocation': {"lat": position.latitude, "lng": position.longitude},
      "delivery_status": "In Transit"
    });

    sendNotification1(donorId, title, message);
    sendNotification(donorId, title, message);

    showToast(message: "✅ Status Updated Successfully", context: context);
  } catch (e) {
    showToast(message: "❌ Error updating status: $e", context: context);
    print("❌ Firestore Update Error: $e");
  }
}

/// Function to prompt user to enable location
Future<bool> promptEnableLocation(BuildContext context) async {
  if (!context.mounted) return false; // Ensure context is valid before proceeding

  return await showDialog<bool>(
    context: context,
    barrierDismissible: false, // User dialog ko back button se dismiss na kare
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text("Enable Location"),
        content: Text("Please enable location services to accept the request."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop(true); // Close dialog first
              await Geolocator.openLocationSettings();
            },
            child: Text("Enable"),
          ),
        ],
      );
    },
  ) ?? false; // Default return false if dialog is dismissed
}


/// Bottom Sheet:
Future<void> showBottomSheet2(BuildContext context, Map<String, dynamic> data) async {
  final user = data['user'];
  final deliveryLatitude = data['deliveryLatitude'];
  final deliveryLongitude = data['deliveryLongitude'];
  final pickupLatitude = data['pickupLatitude'];
  final pickupLongitude = data['pickupLongitude'];
  final requestId = data['requestId'];
  final deliveryStatus = data['delivery_status'] ?? 'Pending'; // Default status

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
              backgroundImage: user['image'] != null ? NetworkImage(user['image']) : null,
              child: user['image'] == null
                  ? const Icon(Icons.person, color: Colors.white, size: 50)
                  : null,
            ),
            const SizedBox(height: 5),
            Text(
              user['username'] ?? 'Requester Name',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, fontFamily: "Poppins"),
            ),
            Text(
              user['mobile'] ?? 'No Phone Provided',
              style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w400, fontFamily: "Poppins"),
            ),
            const SizedBox(height: 15.0),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      userName: user['username'] ?? "",
                      userId: data["donorId"] ?? "",
                      imageurl: user['image'],
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.chat_outlined, color: Colors.white),
              label: const Text(
                'Chat Now',
                style: TextStyle(color: Colors.white, fontFamily: "Poppins", fontWeight: FontWeight.w500, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0XFF9CCCF2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Description", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: "Poppins")),
            ),
            const Divider(color: Color(0XFF9CCCF2)),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                data['description'] ?? 'No description provided.',
                style: const TextStyle(fontSize: 12, fontFamily: "Poppins", fontWeight: FontWeight.w300),
              ),
            ),
            const SizedBox(height: 16.0),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "PickUp Location:",
                style: TextStyle(fontSize: 14, fontFamily: "Poppins", fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 5),
            /// Google Map with a custom marker
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(pickupLatitude ?? 0.0, pickupLongitude ?? 0.0),
                  zoom: 14.0,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('pickUp'),
                    position: LatLng(pickupLatitude ?? 0.0, pickupLongitude ?? 0.0),
                  ),
                  Marker(
                    markerId: const MarkerId("delivery"),
                    position: LatLng(deliveryLatitude, deliveryLongitude),
                  ),
                },
              ),
            ),
            const SizedBox(height: 20),
            /// Show button only if status is not "Delivered"
            if (deliveryStatus != 'Delivered')
              TextButton(
                onPressed: () async {
                  await PickupService().markAsDelivered(requestId);
                  Navigator.pop(context); // Close the bottom sheet after marking delivered
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Marked as Delivered"), backgroundColor: Colors.green),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text(
                  "Mark as Delivered",
                  style: TextStyle(color: Color(0XFF9CCCF2), fontSize: 14, fontWeight: FontWeight.w600,fontFamily: "Poppins"),
                ),
              ),
          ],
        ),
      );
    },
  );
}



class PickupService {
  Future<void> markAsDelivered(String requestId) async {
    await FirebaseFirestore.instance
        .collection('pickup_requests')
        .where('requestId', isEqualTo: requestId)
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.update({'delivery_status': 'Delivered'});
      }
    });
  }
}
