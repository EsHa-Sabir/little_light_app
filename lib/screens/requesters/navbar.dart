import 'package:flutter/material.dart';
import 'package:fyp_project/screens/notification/notification.dart';
import 'package:fyp_project/screens/requesters/request_form.dart';
import 'package:fyp_project/screens/requesters/home.dart';

import '../chat/inbox.dart';
import '../profile/profile.dart';

class RequesterNavBar extends StatefulWidget {
  const RequesterNavBar({super.key});

  @override
  State<RequesterNavBar> createState() => _RequesterNavBarState();
}

class _RequesterNavBarState extends State<RequesterNavBar> {
  /// Index:
  int _selectedIndex = 0;
  /// List of screens
  late List<Widget> _screens;
  @override
  void initState() {
    super.initState();
    /// Screens:
    _screens = [
      RequesterScreen(),
      RequestForm(),
      Inbox(),
      Profile(),
    ];
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  IndexedStack(
        /// Index:
        index: _selectedIndex, // Maintain the state of selected screen
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
          /// Request:
          BottomNavigationBarItem(
            icon: ColorFiltered(
              colorFilter: ColorFilter.mode(
                _selectedIndex == 1? Color(0xFF44ADFF) : Color(0xFF8A8A8C),
                BlendMode.srcIn,
              ),
              child: Image.asset(
                'assets/images/navBar/request.png',
                width: 35,
                height: 19,
              ),
            ),
            label: 'Request',
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
