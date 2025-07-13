import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_project/widgets/appbar.dart';
import 'package:fyp_project/widgets/toast_message.dart';

import '../../../widgets/custom_textfield.dart';

class EditUserScreen extends StatefulWidget {
  /// Get Id
final String userId;
/// Fetch User Data:
final Map<String, dynamic> userData;

EditUserScreen({required this.userId, required this.userData});

@override
_EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  /// Form key:
  final _formKey = GlobalKey<FormState>();
  ///  Controllers:
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  /// Selected Role:
  String? selectedRole;
  /// For loading purpose:
  bool _isLoad=false;

  @override
  void initState() {
    super.initState();
    /// Set initial values:
    nameController.text = widget.userData['username'];
    phoneController.text=widget.userData['mobile'];
    addressController.text=widget.userData['address']??"";
    selectedRole = widget.userData['role'];
  }
/// Update User:
  Future<void> updateUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
          'username': nameController.text,
          'role': selectedRole,
          'mobile':phoneController.text,
          'address':addressController.text
        });

        /// Firebase Auth profile bhi update karein
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null && user.uid == widget.userId) {
          await user.updateDisplayName(nameController.text);
        }

        showToast(message: "Update User Successfully");
        Navigator.pop(context);
      } catch (e) {
        showToast(message: "Error Update User: $e");
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Appbar:
      appBar: customAppBarForScreens('Edit User'),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(

            children: [
              SizedBox(height: 40,),
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
              /// Mobile Field:
              CustomTextField(
                keyboardType: TextInputType.number,
                controller: phoneController,
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
              /// Mobile Field:
              CustomTextField(
                keyboardType: TextInputType.number,
                controller: addressController,
                icon: Icons.location_on,
                label: 'Address',
                validator: (value) {


                },
                onChanged:(value) {},
              ),
              SizedBox(height: 20,),
            /// Dropdown Role Field:
            CustomTextField(
              icon: Icons.person_outline,
              label: 'Select Role',
              initialValue: selectedRole,
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
                  onPressed: () async {
                    setState(() {
                      _isLoad=true;
                    });
                   await updateUser();
                    setState(() {
                      _isLoad=false;
                    });
                  },
                  child:_isLoad?CircularProgressIndicator(color: Colors.white,): Text("Update User",
                      style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Poppins")),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9CCCF2),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
