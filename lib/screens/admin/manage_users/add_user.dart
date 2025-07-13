import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_project/widgets/appbar.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../../widgets/custom_textfield.dart';
import '../../../widgets/toast_message.dart';

class AddUserScreen extends StatefulWidget {
  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  /// key:
  final _formKey = GlobalKey<FormState>();
  /// FirebaseAuth and Firestore Object:
  final FirebaseAuth _auth= FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  /// For Loading:
  bool _isload=false;

  /// Controllers:
  final TextEditingController nameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController mobileController = TextEditingController();

/// Roles:
  final List<String> roles = ['Donor', 'Requester', 'Volunteer'];
/// Select Role:
  String? selectedRole;
/// addUser Function:
 Future<void> addUser(BuildContext context,String email,String password,String role,String mobile,String username) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      /// Create user in Firebase Authentication:
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      /// Send verification email after user registration
      User? user = userCredential.user;
      var playerId = await OneSignal.User.pushSubscription.id;
      print('player id: $playerId');
      if (user != null) {
        await user.sendEmailVerification();

        /// Add User in Firestore:
        await _firestore.collection('users').doc(user.uid).set({
          'username': username,
          'email': email,
          'mobile': mobile,
          'role': role,
          'image': null,
          'playerId':playerId

        });
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: currentUser!.email!,
          password: 'esha123@', // Admin ka password yahan manually set karein
        );

        showToast(message: "user have been successfully add.",context: context);


      } else {
        showToast(message: "User registration failed.",context: context);

      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showToast(message: "The email address is already in use.",context: context);
      }
      else {
        showToast(message: "An error occurred: ${e.code.toString()}",context: context);
      }

    } catch (e) {
      showToast(message: "Something went wrong. Please try again.",context: context);
      print("Error: $e");

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBarForScreens('Add User'),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 30,),
                /// Username Field:
                Center(
                  child: CustomTextField(
                    controller: nameController,
                    icon: Icons.person_outline,
                    label: 'Username',
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a username' : null,
                    onChanged:(value) {},
                  ),
                ),
                SizedBox(height: 20,),
          
                /// Email Field:
                CustomTextField(
                  controller: emailController,
                  icon: Icons.email_outlined,
                  label: 'E-mail',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter an email';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Enter a valid email';
                    return null;
                  },
                  onChanged:(value) {},
                ),
                SizedBox(height: 20,),
          
                /// Password Field:
                CustomTextField(
                  controller: passwordController,
                  icon: Icons.lock_outline_sharp,
                  label: 'Password',
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter password';
                    if (value.length < 8) return 'Password must be at least 8 characters';
                    return null;
                  },
                  onChanged:(value) {},
                ),
                SizedBox(height: 20,),
                /// Mobile Field:
                CustomTextField(
                  keyboardType: TextInputType.number,
                  controller: mobileController,
                  icon: Icons.phone_android,
                  label: 'Mobile',
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter phone number';
                    return null;
          
                  },
                  onChanged:(value) {},
                ),
                SizedBox(height: 20,),
          
                /// Dropdown Role Field:
                CustomTextField(
                  icon: Icons.person_outline,
                  label: 'Select Role',
                  isDropdown: true,
                  dropdownItems: ['Donor', 'Volunteer', 'Requester'],
                  onChanged: (value) => selectedRole = value,
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Please select a role' : null,
                ),
          
          
                SizedBox(height: 30),
                /// Button:
                SizedBox(
                  width: 270,
                  child: ElevatedButton(
                    onPressed: ()async{
                      setState(() {
                        _isload=true;
                      });
                    await  addUser(context,emailController.text,passwordController.text,selectedRole!,mobileController.text,nameController.text);
                      emailController.clear();
                      nameController.clear();
                      passwordController.clear();
                      mobileController.clear();

                    setState(() {
                        _isload=false;
                      });
                    },
                    child: _isload
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                       "Add User",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14, // Responsive font size
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9CCCF2),
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                  ),
                ),
                )],
            ),
          ),
        ),
      ),
    );
  }
}
