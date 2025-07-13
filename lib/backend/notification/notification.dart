import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../screens/notification/notification.dart';

/// Send Status Bar Notification by using One Signal:
void sendNotification1(String userId, String title, String message) async {
  /// Requester ka OneSignal Player ID Firestore se lein
  DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

  String playerId = userDoc['playerId'];

  var notification = {
    "app_id": "04759181-be77-435e-85aa-688ae3fb5fa5",
    "include_player_ids": [playerId],
    "headings": {"en": title},
    "contents": {"en": message},
    "data": {
      "screen": "notification_screen",
      "userId": userId
    },
  };

  var response = await http.post(
    Uri.parse("https://onesignal.com/api/v1/notifications"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": dotenv.env["ONE_SIGNAL_AUTHORIZATION"]??"",
    },
    body: jsonEncode(notification),
  );

  print("Notification Response: ${response.body}");
}
/// Unread Notification Count:
Stream<int> getUnreadNotificationCount(String userId) {
  return FirebaseFirestore.instance
      .collection('notifications')
      .where('userId', isEqualTo: userId)
      .where('isRead', isEqualTo: false)
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
}
/// Notification Icon:
Widget buildNotificationIcon(String userId1) {
  return StreamBuilder<int>(
    stream: getUnreadNotificationCount(userId1),
    builder: (context, snapshot) {
      int count = snapshot.data ?? 0;
      return Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationScreen(userId: userId1)),

              );
            },
          ),
          if (count > 0)
            Positioned(
              right: 11,
              top: 11,

              child: CircleAvatar(
                radius: 6,
                backgroundColor: Colors.red,
                child: Text(
                  count.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 8),
                ),
              ),
            ),

        ],
      );
    },
  );
}
/// Send Notification:
void sendNotification(String userId,String title,String message) async {
  await FirebaseFirestore.instance.collection('notifications').add({
    'userId': userId, // Jis user ko notification chahiye
    'title': title,
    'message': message,
    'timestamp': FieldValue.serverTimestamp(),
    'isRead': false, // Unread notifications ke liye
    'type': 'request_accepted'
  });

}
/// Send Notification to Volunteer:
void sendNotificationToSpecificUsers(String title, String message,String role) async {
  try {
    QuerySnapshot volunteerDocs = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: role)
        .get();

    List<String> playerIds = [];

    for (var doc in volunteerDocs.docs) {
      if (doc['playerId'] != null) {
        playerIds.add(doc['playerId']);
      }
    }

    if (playerIds.isEmpty) {
      print("❌ No Users found with OneSignal player ID.");
      return;
    }

    var notification = {
      "app_id": "04759181-be77-435e-85aa-688ae3fb5fa5",
      "include_player_ids": playerIds,
      "headings": {"en": title},
      "contents": {"en": message},
      "data": {
        "screen": "notification_screen",
      },
    };

    var response = await http.post(
      Uri.parse("https://onesignal.com/api/v1/notifications"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": dotenv.env["ONE_SIGNAL_AUTHORIZATION"]??"",
      },
      body: jsonEncode(notification),
    );

    print("📨 Notification Response: ${response.body}");

    if (response.statusCode == 200) {
      print("✅ Push notification sent successfully.");
    } else {
      print("❌ Failed to send notification. Status Code: ${response.statusCode}");
    }
  } catch (e) {
    print("❌ Error in sendNotificationToVolunteers: $e");
  }
}

/// Store Notification for Volunteer:
void sendNotificationToSpecificUsers1(String title, String message,String role) async {
  QuerySnapshot volunteerDocs = await FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: role) // Sirf volunteers ko fetch karein
      .get();

  for (var doc in volunteerDocs.docs) {
    String volunteerId = doc.id; // Volunteer ka Firestore userId

    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': volunteerId, // Sirf volunteer ke liye store hoga
      'title': title,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false, // Unread notification

    });
  }

  print("Notification stored for all volunteers.");
}
