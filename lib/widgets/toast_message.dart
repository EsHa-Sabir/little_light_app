import 'dart:ui';

import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


/// Flutter Toast Function (Responsive)
void showToast({required String message, BuildContext? context}) {
  if (context == null) {
    print("⚠️ Toast not shown: Context is null.");
  }

  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: const Color(0xFF9CCCF2),
    textColor: Colors.white,
    fontSize: 13,
    // ✅ Fixed font size, no MediaQuery needed
  );
}

/// DelightToast Function (Responsive)
void showDelightToast({required BuildContext context, required String text}) {
  double screenWidth = MediaQuery.of(context).size.width;

  DelightToastBar(
    builder: (context) => ToastCard(
      leading: Icon(
        Icons.flutter_dash,
        size: screenWidth * 0.07, // Responsive icon size
      ),
      color: Color(0XFF9CCCF2),
      title: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: screenWidth * 0.04, // Responsive font size
        ),
      ),
    ),
  ).show(context);
}

