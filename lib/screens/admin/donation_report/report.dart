import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp_project/widgets/appbar.dart';
import 'admin_report_screen.dart';

class DonorListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBarForScreens('Donor List'),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'Donor')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Color(0xFF9CCCF2)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Text(
                  'No donors found',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            );
          }

          final donors = snapshot.data!.docs;

          return ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 10),
            separatorBuilder: (_, __) => Divider(indent: 20, endIndent: 20),
            itemCount: donors.length,
            itemBuilder: (context, index) {
              final donor = donors[index];
              final donorName = donor['username'] ?? 'Unknown';
              final donorPhone = donor['mobile'] ?? 'No number';
              final donorImage = donor['image'] ?? '';

              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminReportScreen(
                        donorId: donor.id,
                        donorName: donorName,
                      ),
                    ),
                  );
                },
                leading: donorImage.isNotEmpty ? CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(donorImage) ,
                  backgroundColor: Colors.white
                ):CircleAvatar(
                  radius:  25,
                  backgroundColor: Color(0XFF9CCCF2),
                  child: Icon(Icons.person,size:  20,color: Colors.grey[200],),
                ),
                title: Text(
                  donorName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                subtitle: Row(
                  children: [
                    Icon(Icons.phone, size: 12, color: Colors.blue.shade400),
                    SizedBox(width: 4),
                    Text(
                      donorPhone,
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                trailing: CircleAvatar(
                  backgroundColor: Color(0xFFF3F6FD),
                  child: Icon(Icons.bar_chart, color: Colors.blue.shade300),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
