import 'package:flutter/material.dart';

class SocialDivider extends StatelessWidget {
  const SocialDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // Get screen width

    return Container(
      width: screenWidth * 0.85, // Responsive width (85% of screen width)
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// Left Divider:
          Expanded(
            child: Divider(
              color: Color(0xFFA39797), // Line color
              thickness: 1,
                indent: 12,               // Padding from the start
                endIndent: 12// Line thickness
            ),
          ),
          /// "Or" Text:
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02), // Dynamic spacing
            child: Text(
              'Or',
              style: TextStyle(
                color: Color(0xFF757171),
                fontSize: screenWidth * 0.035, // Responsive font size
                fontFamily: 'Poppins',
              ),
            ),
          ),
          /// Right Divider:
          Expanded(
            child: Divider(
              color: Color(0xFFA39797), // Line color
              thickness: 1,
                indent: 12,               // Padding from the start
                endIndent: 12// Line thickness
            ),
          ),
        ],
      ),
    );
  }
}
