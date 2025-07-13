import 'package:flutter/material.dart';
import 'package:fyp_project/widgets/appbar.dart';

import '../../backend/history/request_history.dart';

class History extends StatelessWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBarForScreens("Request History"),
      body:  Column(
        children: [
          SizedBox(height: 20,),
          Expanded(child: RequestHistoryList()),
        ],
      ),
    );
  }
}
