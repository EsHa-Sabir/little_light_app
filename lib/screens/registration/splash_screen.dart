
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_project/backend/user/check_user.dart';
import 'package:fyp_project/screens/registration/slider.dart';



class SplashScreen extends StatefulWidget{
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();


    User? user = FirebaseAuth.instance.currentUser;
    Timer(Duration(seconds: 2),(){
      if(user!=null){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>RoleBasedRedirect()));
      }else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SliderScreen()));
      }
    });
  }
  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
/// Body:
      body: Image.asset("assets/images/splash_screens/splash_screen_1.jpg",
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        fit: BoxFit.cover,) ,
    );
  }
}