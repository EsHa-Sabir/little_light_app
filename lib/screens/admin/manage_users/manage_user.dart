import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_project/screens/admin/manage_users/edit_user.dart';
import 'package:fyp_project/widgets/appbar.dart';
import 'add_user.dart';

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  /// Select Role:
  String? selectedRole;
  /// get Id:
  final String adminUid = FirebaseAuth.instance.currentUser!.uid;
  /// Search Query:
  String searchQuery = '';
 /// Get user Based On role:
  Stream<QuerySnapshot> getUsersStream() {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    if (selectedRole != null) {
      return users.where('role', isEqualTo: selectedRole).snapshots();
    } else {
      return users.snapshots();
    }
  }
/// Delete user:
  void deleteUser(String userId) async {
    try {


      await FirebaseFirestore.instance.collection('users').doc(userId).delete();


      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User Deleted Successfully!")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Appbar
      appBar: customAppBarForScreens('Manage Users'),
      body: Column(
        children: [
          /// 🔹 SEARCH BY NAME
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search by Name',
                labelStyle: TextStyle(
                  fontFamily: "Poppins",
                    color: Color(0xFF989898),
                  fontWeight: FontWeight.w400,fontSize: 14
                ),
                prefixIcon: Icon(Icons.search),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color:Color(0xFF9CCDF2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF9CCDF2)),
                  ),
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query.toLowerCase();
                });
              },
            ),
          ),
          /// 🔹 FILTER USING FILTER CHIPS (ROLE BASED)
          Padding(
            padding: const EdgeInsets.only(top: 0,left: 16,right: 16,bottom: 5),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, // ✅ Horizontal scrolling enabled
              child: Row(
                children: ['All', 'Donor', 'Requester', 'Volunteer'].map((role) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3), // ✅ Space between chips
                    child: ChoiceChip(
                      label: Text(
                        role,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w400,
                          color: selectedRole == role || (role == 'All' && selectedRole == null)
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      selected: selectedRole == role || (role == 'All' && selectedRole == null),
                      onSelected: (isSelected) {
                        setState(() {
                          selectedRole = role == 'All' ? null : role;
                        });
                      },
                      selectedColor: Color(0xFF9CCDF2),
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: selectedRole == role || (role == 'All' && selectedRole == null)
                              ? Color(0xFF9CCDF2)
                              : Colors.grey.shade200,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          /// 🔹 USER LIST WITH PROPER EMPTY STATE HANDLING
          Expanded(
            child: StreamBuilder(
              stream: getUsersStream(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Color(0xFF9CCDF2) ,));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Column(
                    children: [
                      SizedBox(height: 20,),
                      Center(child: Image.asset('assets/images/admin/search.gif',height: 100,width: 100,)),
                      SizedBox(height: 10,),
                      Center(child: Text("No users found", style: TextStyle(fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,fontFamily: "Poppins"))),
                    ],
                  );
                }

                var filteredDocs = snapshot.data!.docs.where((doc) {
                  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  return searchQuery.isEmpty ||
                      (data['username']?.toLowerCase() ?? '').contains(searchQuery);
                }).toList();

                /// ✅ IF NO MATCH FOUND, SHOW MESSAGE
                if (filteredDocs.isEmpty) {
                  return Column(
                    children: [
                      SizedBox(height: 20,),
                      Center(child: Image.asset('assets/images/admin/search.gif',height: 100,width: 100,)),
                      SizedBox(height: 10,),
                      Center(child: Text("No users found",  style: TextStyle(fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,fontFamily: "Poppins"))),
                    ],
                  );
                }

                return ListView(
                  children: filteredDocs.map((doc) {
                    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                    if (doc.id == adminUid) return SizedBox.shrink();
                    return ListTile(
                      leading: data["image"]!= null
                          &&data["image"].isNotEmpty? CircleAvatar(
                        backgroundColor: Colors.white,
                        radius:  20,
                        backgroundImage: NetworkImage(data["image"]),
                      ): CircleAvatar(
                        radius:  20,
                        backgroundColor: Color(0XFF9CCCF2),
                        child: Icon(Icons.person,size:  20,color: Colors.grey[200],),
                      ),
                      title: customText1(data['username']),
                      subtitle: customText("Role: ${data['role']}\nMobile: ${data['mobile']}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue.shade400),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      EditUserScreen(userId: doc.id, userData: data)),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red.shade400),
                            onPressed: () => deleteUser(doc.id),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
      /// For Add User:
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add,color: Colors.white,),
        backgroundColor: Color(0XFF9CCCF2) ,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddUserScreen()),
          );
        },
      ),
    );
  }
}
/// Custom text:
customText(String text){
  return Text(
    text,
    style: TextStyle(fontWeight: FontWeight.w400,fontFamily: "Poppins",fontSize: 12),
  );
}
/// Custom text:
customText1(String text){
  return Text(
    text,
    style: TextStyle(fontWeight: FontWeight.w500,fontFamily: "Poppins",fontSize: 12),
  );
}