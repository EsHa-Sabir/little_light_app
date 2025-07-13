import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../screens/admin/navbar/navbar.dart';
import '../../screens/donation/navbar/navbar.dart';
import '../../screens/registration/login.dart';
import '../../screens/registration/slider.dart';
import '../../screens/requesters/navBar.dart';
import '../../screens/volunteer/home.dart';

class RoleBasedRedirect extends StatefulWidget {
  @override
  _RoleBasedRedirectState createState() => _RoleBasedRedirectState();
}

class _RoleBasedRedirectState extends State<RoleBasedRedirect> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;

  User? _user;
  String? _role;

  @override
  void initState() {
    super.initState();
    _checkUserAndRole();
  }

  Future<void> _checkUserAndRole() async {
    try {
      print("🔍 Checking current FirebaseAuth user...");
      User? user = _auth.currentUser;

      if (user != null) {
        print("✅ Logged-in user found: ${user.uid}");

        DocumentSnapshot userData = await _firestore.collection('users').doc(user.uid).get();
        print("📄 Firestore document fetched");

        if (userData.exists) {
          String? role = userData['role'];
          print("👤 User role from Firestore: $role");

          if (role != null) {
            setState(() {
              _user = user;
              _role = role;
              _isLoading = false;
            });
          } else {
            print("⚠️ Role is null in user document");
            setState(() {
              _isLoading = false;
            });
          }
        } else {
          print("❌ No Firestore document for user");
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        print("🚫 No FirebaseAuth user logged in");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("🔥 Error in _checkUserAndRole(): $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Color(0XFF9CCCF2))),
      );
    } else {
      print("➡️ Navigation Decision - User: $_user | Role: $_role");
      if (_user != null && _role != null) {
        switch (_role) {
          case 'Donor':
            return DonorNavigationBar();
          case 'Volunteer':
            return VolunteerScreen();
          case 'Requester':
            return RequesterNavBar();
          case 'Admin':
            return AdminNavigationBar();
          default:
            print("⚠️ Unknown role encountered: $_role");
            return LoginScreen();
        }
      } else {
        print("👋 No user or role found, showing SliderScreen");
        return SliderScreen();
      }
    }
  }
}
