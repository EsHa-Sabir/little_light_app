import 'package:flutter/material.dart';

/// Login AppBar:
AppBar customAppBarForLogin(String text, String image, bool isFlag, BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;

  return AppBar(
    centerTitle: false,
    elevation: 0,
    backgroundColor: Colors.white,
    title: Padding(
      padding: EdgeInsets.only(left: screenWidth * 0.02), // Responsive padding
      child: isFlag
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: screenWidth * 0.01), // Responsive spacing
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: screenWidth * 0.045, // Responsive font size
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Outfit',
                ),
              ),
              SizedBox(width: screenWidth * 0.005), // Dynamic spacing
              Image.asset(
                image,
                width: screenWidth * 0.04, // Responsive image width
                height: screenWidth * 0.04, // Responsive image height
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.01), // Responsive spacing
          Text(
            'Welcome,',
            style: TextStyle(
              fontSize: screenWidth * 0.03, // Adjusted font size
              color: Color(0xFF5B5B5B),
              fontFamily: 'Outfit',
            ),
          ),
        ],
      ) : Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            image,
            width: screenWidth * 0.05, // Adjusted image width
            height: screenWidth * 0.05, // Adjusted image height
          ),
          SizedBox(width: screenWidth * 0.006), // Responsive spacing
          Text(
            text,
            style: TextStyle(
              fontSize: screenWidth * 0.045, // Adjusted font size
              fontWeight: FontWeight.w700,
              fontFamily: 'Outfit',
            ),
          ),
        ],
      ),
    ),
  );
}

/// Screen AppBar:
AppBar customAppBarForScreens(String text){
  return AppBar(
    title: Text(text),
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

  );
}
/// Profile AppBar:
customAppBarForProfile(String text, String image){
  return AppBar(
    centerTitle: false,
    elevation: 0,
    backgroundColor: Colors.white,
    title: Padding(
      padding: const EdgeInsets.only(left: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 5,),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(width: 2),
              Image.asset(
                image ,
                width: 15,
                height: 15,
              ),
            ],
          ),


        ],
      ),
    ),
  );
}

