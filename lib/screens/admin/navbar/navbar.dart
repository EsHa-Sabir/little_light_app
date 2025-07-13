import 'package:flutter/material.dart';
import 'package:fyp_project/screens/admin/home/home.dart';
import 'package:fyp_project/screens/chat/inbox.dart';
import '../../profile/profile.dart';


class AdminNavigationBar extends StatefulWidget {


  const AdminNavigationBar({super.key});

  @override
  State<AdminNavigationBar> createState() => _AdminNavigationBarState();
}

class _AdminNavigationBarState extends State<AdminNavigationBar> {
  /// Use for Index:
  int _selectedIndex = 0;
  /// List:
  late List<Widget> _screens;
  @override
  void initState() {
    super.initState();
    /// Screens
    _screens = [
      AdminDashboard(),
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
