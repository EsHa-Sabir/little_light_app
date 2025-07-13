import 'package:flutter/material.dart';

class SignupPrompt extends StatelessWidget {
  final String prompt;
  final String text;
  final VoidCallback onPressed;

  const SignupPrompt({
    Key? key,
    required this.prompt,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // Get screen width

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        /// Signup Prompt Text:
        Text(
          text,
          style: TextStyle(
            color: Color(0x99000000),
            fontSize: screenWidth * 0.03, // Responsive font size
            fontWeight: FontWeight.w300,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(width: screenWidth * 0.015), // Responsive spacing
        /// Clickable Text:
        InkWell(
          onTap: onPressed,
          child: Text(
            prompt,
            style: TextStyle(
              color: Colors.black,
              fontSize: screenWidth * 0.03, // Responsive font size
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }
}
