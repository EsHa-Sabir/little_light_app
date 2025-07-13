import 'package:flutter/material.dart';
import 'package:fyp_project/backend/history/donation_history.dart';

import '../../../widgets/appbar.dart';

class DonationHistory extends StatefulWidget {
  const DonationHistory({super.key});

  @override
  State<DonationHistory> createState() => _DonationHistoryState();
}

class _DonationHistoryState extends State<DonationHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Appbar:
      appBar:  customAppBarForScreens("Donation History"),
      body:Column(
        children: [
          Expanded(child: DonationHistoryList(isPadding: true,)),
        ],
      )
    );
  }
}
