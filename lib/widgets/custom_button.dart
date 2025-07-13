import 'dart:ui';

import 'package:flutter/material.dart';
/// Custom Button:
ElevatedButton customButton({required String text,required VoidCallback onPressed}){
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF9CCCF2),
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    child:Text(text, style: TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w500,
    ),),
  );

}