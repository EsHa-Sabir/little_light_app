
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../backend/user/user_provider.dart';
import '../../widgets/custom_textfield.dart';

class ChangeEmail extends StatefulWidget {
String oldEmail;
   ChangeEmail({super.key,required this.oldEmail});
  @override
  State<ChangeEmail> createState() => _ChangeEmailState();
}

class _ChangeEmailState extends State<ChangeEmail> {
  /// Text Editing Controllers:
  var oldEmailController=new TextEditingController();
  var newEmailController=new TextEditingController();
  var passwordController=new TextEditingController();
  bool isChange=false;

  @override
  void initState() {
    super.initState();


  }
  @override
  Widget build(BuildContext context) {
    /// Get User Data For Display Purpose:
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      /// Appbar:
    appBar: AppBar(
          title: const Text('Change Email'),
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
          /// Current Email Label:
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Align(
              child: Text(
                "Current Email",
                style: TextStyle(
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w400,
                    fontSize: 13),),
              alignment: Alignment.centerLeft,),
          ),
          SizedBox(
            height: 3,
          ),
          /// Display Email:
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Align(
              alignment: Alignment.centerLeft,
                child: Text(
                    "${widget.oldEmail}",
                    style: TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w300,
                        fontSize: 11))),
          ),
          SizedBox(height: 30,),
          /// New Email TextField:
          Center(
            child: CustomTextField(
              controller: newEmailController,
              icon: Icons.email_outlined,
              label: 'New E-mail',
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {},
              validator:  (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }else if(!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),

          ),
          SizedBox(height: 10,),
          /// Password TextField:
          CustomTextField(
            controller: passwordController,
            icon: Icons.lock_outline_rounded,
            label: ' Current Password',
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
              child:  ElevatedButton (
                onPressed: () async{
                  setState(() {
                    isChange=true;
                  });
                  /// Update Email Function:
                 await userProvider.updateEmail(
                      newEmailController.text,
                      passwordController.text,context);
                  setState(() {
                    isChange=false;
                  });
                  newEmailController.clear();
                  passwordController.clear();

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9CCCF2),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child:isChange?const CircularProgressIndicator(color: Colors.white,):Text(
                  "Update",
                  style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),),
              )
          )
        ]
      ),
    );
  }
}
