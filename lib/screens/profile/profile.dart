import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_project/screens/profile/app_language.dart';
import 'package:fyp_project/screens/profile/change_email.dart';
import 'package:fyp_project/widgets/toast_message.dart';
import 'package:provider/provider.dart';
import 'package:fyp_project/screens/profile/edit_profile.dart';
import 'package:fyp_project/screens/registration/login.dart';
import '../../backend/firebase_service/firebase_auth_services.dart';
import '../../backend/user/user_provider.dart';
import '../../widgets/appbar.dart';
import '../../widgets/custom_textfield.dart';
import 'change_password.dart';


class Profile extends StatefulWidget {
  const Profile({super.key});
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? userId;
  /// Password Controller:
  final TextEditingController _passwordController = TextEditingController();
  /// Firebase Authentication Object:
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
    /// Get Current User Id From Firebase Auth:
    userId = _auth.currentUser?.uid;
    /// Fetch Current User Data From Firebase:
    if (userId != null) {
      Provider.of<UserProvider>(context, listen: false).fetchUserData(userId!,context);
    }
  }
  /// Delete User Account Confirmation Function:
  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Center(child: Text(
          'Delete Account',
          style: TextStyle(
              fontFamily: "Poppins",
              fontWeight: FontWeight.w600,
              fontSize: 13),)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'Are you sure you want to delete your account?',
                style: TextStyle(
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w400,
                    fontSize: 11)),
            SizedBox(height: 16),
            Center(
              child: CustomTextField(
                controller: _passwordController ,
                icon: Icons.lock_outline_rounded,
                label: 'Enter Password',
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Close dialog
            },
            child: Text(
              'Cancel',
              style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: "Poppins",color: Colors.blue
            ),),
          ),
          TextButton(
            onPressed: () async {
              /// Close Dialog Box:
              Navigator.of(ctx).pop();
              try {
                final password = _passwordController.text.trim();
                await FirebaseAuthServices().deleteAccount(password,context);
                showToast(message: "Account delete successfully",context: context);
                Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
              } catch (e) {
                showToast(message: "An error occured",context: context);
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(
              fontSize: 12,
             fontWeight: FontWeight.w500, fontFamily: "Poppins",color: Colors.blue
                  ),),
          ),
        ],
      ),
    );
  }
 /// Logout Function:
  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false, // Yeh sari screens hata dega
    );
  }
  @override
  Widget build(BuildContext context) {
    /// For Get User Data and Display Purpose:
    final userProvider = Provider.of<UserProvider>(context);
    return  Scaffold(
      /// AppBar:
      appBar:customAppBarForProfile("Profile",  'assets/images/login/user_icon.png'),
      /// Body:
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// Profile Data:
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 10,),
                  /// Profile Image:
                  Stack(
                    children: [
                      userProvider.userData?["image"]!= null
                          && userProvider.userData?["image"].isNotEmpty
                          ? CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 50,
                        backgroundImage: NetworkImage(userProvider.userData?["image"]),
                      ) : CircleAvatar(
                        radius:50 ,
                        backgroundColor: Color(0xFF9CCDF2),
                        child: Icon(Icons.person, size: 60, color: Colors.white),
                      ),
                      Positioned(
                          bottom: 0,
                          right: 3,
                          child: InkWell(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>EditProfile()));
                            },
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                  backgroundColor: Colors.blue.shade100,
                                  radius: 12,
                                  child: Icon(Icons.edit,color: Colors.white,size: 18,)),
                            ),
                          ))
                  ]),
                  const SizedBox(height: 5),
                  /// Username:
                  Text(
                    userProvider.userData?["username"]?? "",
                    style: const TextStyle(
                      fontSize: 15,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 5),
                  /// Phone
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone_outlined,color: Colors.grey,size: 15,),
                      SizedBox(width: 2,),
                      Text(
                        userProvider.userData?["mobile"]??"",
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            /// About User:
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Align(
                    child: Text(
                    "About",
                      style: TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w700,
                          fontSize: 15),),
                    alignment: Alignment.centerLeft,),
                ),
                SizedBox(
                  height: 3,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                      (userProvider.userData?['about'] == null ||
                      userProvider.userData?['about'] == "")?
                      "Tell us a little about yourself, what are your interests, hobbies, or things you enjoy doing. This helps others get to know you better!"
                          :userProvider.userData!['about'],
                      style: TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w300,
                          fontSize: 11)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Divider(
                  thickness: 1,),
                )
              ],
            ),
            /// Change Email:
            customListTile("assets/images/profile/mail.png", "Change Email",(){
             Navigator.push(context,MaterialPageRoute(
                 builder: (context)=>ChangeEmail(
                   oldEmail: userProvider.userData!['email'],
                )));
            }),
            /// Change Password:
            customListTile("assets/images/profile/key.png", "Change Password",(){
              Navigator.push(context,MaterialPageRoute(
                  builder: (context)=>ChangePassword()));
            }),
            /// App Language:
            customListTile("assets/images/profile/country.png", "App Language",(){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>AppLanguage()));
            }),
            /// Delete Account:
            customListTile("assets/images/profile/delete.png", "Delete Account",(){
              _showConfirmationDialog(context);
            }),
            /// Logout:
            customListTile("assets/images/profile/logout.png", "Logout",(){
              _logout();

            }),
          ],
        ),
      ),
    );
  }
}
/// Container:
Container customBox(String text1,String text2){
  return  Container(
    height: 80,
    width: 80,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(
        color: Color(0XFF9CCCF2),
        width: 1,
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          style: TextStyle(
            fontSize: 16,
            fontFamily: "Poppins",
            fontWeight:FontWeight.w500,
          ),
         text1 ,
        ),
        SizedBox(height: 5,),
        Text(text2, style: TextStyle(
          fontSize: 12,
          fontFamily: "Poppins",
          fontWeight:FontWeight.w400,
        ),),
      ],
    ),
  );
}
/// ListTile:
ListTile customListTile(String image,String text,VoidCallback onTap){
  return ListTile(
    leading: Image.asset(image,width: 25,height: 25,),
    title: Text(text,style: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      fontFamily: "Poppins"
    ),),
    trailing: Icon(Icons.arrow_forward_ios,size: 18,color: Colors.grey,),
    onTap: onTap,
  );
}