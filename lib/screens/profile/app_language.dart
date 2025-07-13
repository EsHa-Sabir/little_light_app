import 'package:flutter/material.dart';

class AppLanguage extends StatelessWidget {
  const AppLanguage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Appbar:
      appBar: AppBar(
        title: const Text("App Language"),
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
      ),
      /// Body:
      body:  Column(
        children: [
          SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Align(
              alignment: Alignment.centerLeft,
                child: Text(
                  "English",
                  style: TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w500,
                      fontSize: 13),)),
          ),
       Padding(
         padding: const EdgeInsets.symmetric(horizontal: 15.0),
         child: Align(
             alignment:Alignment.centerLeft,
             child: Text(
               "(device's language)",
               style: TextStyle(
                   fontFamily: "Poppins",
                   fontWeight: FontWeight.w300,
                   fontSize: 10),)),
       )
        ],
      ),
    );
  }
}
