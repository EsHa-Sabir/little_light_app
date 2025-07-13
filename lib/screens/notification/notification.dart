import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/date_time.dart';
import '../../widgets/appbar.dart';

class NotificationScreen extends StatelessWidget {
  final String userId;
  const NotificationScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Appbar:
      appBar:customAppBarForScreens("Notification"),
      body: FutureBuilder<QuerySnapshot>(
        /// Fetch Notification From Firebase:
        future: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: userId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Color(0XFF9CCCF2),));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return customNoNotification();
          }
          /// Store data inf Notification Variable:
          var notifications = snapshot.data!.docs;
          /// Sorting locally by timestamp in descending order
          notifications.sort((a, b) {
            Timestamp timeA = a['timestamp'];
            Timestamp timeB = b['timestamp'];
            return timeB.compareTo(timeA); /// Descending order
          });
          /// UI Of Notification:
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              var notification = notifications[index].data() as Map<String, dynamic>;
              return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 10),
              child: Container(
              decoration: BoxDecoration(
              border: Border.all(color: Color(0XFFE3F3FF),), // Border color and width
              borderRadius: BorderRadius.circular(8), // Rounded corners
              ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0XFF9CCCF2),
                    radius: 20,
                    child: Icon(Icons.notifications,color: Colors.white,),
                  ),
                  title:Text(notification["title"],style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    fontFamily: "Poppins"
                  ),),
                  subtitle:Text(notification["message"],style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 11,
                      fontFamily: "Poppins"
                  ),) ,
                  trailing: Text(notification['timestamp'] != null
                      ? getDateHeader(notification['timestamp'].toDate(),true)
                      : '',style: TextStyle(
                    color: Color(0XFF758FA4),
                    fontFamily: "Poppins",
                    fontSize: 10,
                    fontWeight: FontWeight.w400

                  ),),
                  onTap: () {
                    FirebaseFirestore.instance
                        .collection('notifications')
                        .doc(notifications[index].id)
                        .update({'isRead': true});

                    if (notification['type'] == 'request_accepted') {

                    }
                  },
                ),
              ));
            },
          );
        },
      ),
    );
  }
}
/// No Notification:
customNoNotification(){
  return Column(

    children: [
      SizedBox(height: 20,),
      Center(child: Image.asset("assets/images/notification/notification_image.png",height: 230,width: 230,)),
      Text("No Notification Found",style: TextStyle(
          fontFamily: "Poppins",
          fontWeight: FontWeight.w400,
          fontSize: 15,
          color: Color(0xFF7C7373)
      ),)
    ],
  );
}