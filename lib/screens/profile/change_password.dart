import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../backend/user/user_provider.dart';
import '../../widgets/custom_textfield.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});
  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  /// Text Editing Controller:
  var oldPassswordController=TextEditingController();
  var newPassswordController=TextEditingController();
  bool isChange=false;
  @override
  Widget build(BuildContext context) {
    /// Object of user Provider Class:
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      /// Appbar:
      appBar: AppBar(
        title: const Text('Change Password'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(5),
          child: Column(
            children: [
              Container(
                color: const Color(0xFF9CCEF2),
                height: 1,
              ),
            ],
          ),
        ),
      ),
      /// Body:
      body: Column(
          children: [
            SizedBox(height: 30,),
            /// Old Password TextField:
            Center(
              child: CustomTextField(
                controller: oldPassswordController,
                icon: Icons.lock_outline_rounded,
                label: 'Old Password',
                isPassword: true,
                onChanged: (value) {},
                validator:  (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your  password';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: 10,),
            /// New Password TextField:
            CustomTextField(
              controller: newPassswordController,
              icon: Icons.lock_outline_rounded,
              label: 'New Password',
              isPassword: true,
              onChanged: (value) {},
              validator:  (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your  password';
                }
                return null;
              },
            ),
            SizedBox(height: 28,),
            /// Update Button:
            SizedBox(
                width: 270,
                child:  ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      isChange = true;
                    });

                    // Try-catch block to handle errors
                    try {
                      await userProvider.updatePassword(
                        oldPassswordController.text,
                        newPassswordController.text,context
                      );

                      // Clear input fields after successful update
                      oldPassswordController.clear();
                      newPassswordController.clear();
                    } catch (e) {
                      print("Error updating password: $e");
                    }

                    setState(() {
                      isChange = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9CCCF2),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: isChange
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    "Update",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )

            )
          ]
      ),
    );
  }
}
