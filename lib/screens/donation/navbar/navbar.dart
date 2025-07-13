import 'package:flutter/material.dart';
import 'package:fyp_project/screens/chat/inbox.dart';
import 'package:sizer/sizer.dart';
import '../../profile/profile.dart';
import '../home/home.dart';

class DonorNavigationBar extends StatefulWidget {


  const DonorNavigationBar({super.key});

  @override
  State<DonorNavigationBar> createState() => _DonorNavigationBarState();
}

class _DonorNavigationBarState extends State<DonorNavigationBar> {
  /// Use for Index:
  int _selectedIndex = 0;
  /// List:
  late List<Widget> _screens;
  @override
  void initState() {
    super.initState();
    /// Screens
     _screens = [
       Sizer(builder: (context,orientation, deviceType){
         return DonorScreen();
       }),
      Inbox(),
       Profile(),
    ];
  }
  void _onItemTapped(int index) {
    /// Change Index:
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body:  IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: [
          /// Home:
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined,size: 19,),
            label: 'Home',


          ),
          /// Chat:
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline,size: 19,),
            label: 'Chat',
          ),
          /// Profile:
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline,size: 19,),
            label: 'Profile',
          ),
        ],
        /// currentIndex:
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF44ADFF),
        unselectedItemColor: Color(0xFF8A8A8C),
        onTap: _onItemTapped,
        selectedLabelStyle: TextStyle(
          fontFamily: "Roboto",
              fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF44ADFF),
        ),
        unselectedLabelStyle: TextStyle(
            fontFamily: "Roboto",
            fontSize: 10,
            fontWeight: FontWeight.w400,
          color: Color(0xFF8A8A8C),
        ),
      ),
    );
  }
}
