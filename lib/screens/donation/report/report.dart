import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_project/widgets/appbar.dart';
import 'package:pie_chart/pie_chart.dart';

class DonorReportScreen extends StatefulWidget {
  final String donorId;
  final String donorName;

  DonorReportScreen({required this.donorId, required this.donorName});

  @override
  _DonorReportScreenState createState() => _DonorReportScreenState();
}

class _DonorReportScreenState extends State<DonorReportScreen> {
  Map<String, double> categoryCounts = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDonationData();
  }

  void fetchDonationData() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('donations')
        .where('donorId', isEqualTo: widget.donorId)
        .get();

    Map<String, double> tempCounts = {};

    snapshot.docs.forEach((doc) {
      String category = doc['category'];
      tempCounts[category] = (tempCounts[category] ?? 0) + 1;
    });

    setState(() {
      categoryCounts = tempCounts;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBarForScreens('My Donation Report'),
      backgroundColor: Color(0xFFF6F9FC),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: Color(0xFF9CCCF2),
        ),
      )
          : categoryCounts.isEmpty
          ? Column(

        children: [
          Center(child: SizedBox(height: 80,)),
          Center(child: Image.asset('assets/images/donation/history/report.png',height: 100,width: 100,)),
          SizedBox(height: 20),
          Text(
            "No donations report found.",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontFamily: "Poppins",
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      )
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(16),
              child: PieChart(
                dataMap: categoryCounts,
                chartRadius: MediaQuery.of(context).size.width / 2.2,
                chartType: ChartType.ring,
                baseChartColor: Colors.grey.shade200,
                colorList: [
                  Color(0xFF9CCCF2),
                  Color(0xFFD1C4E9),
                  Color(0xFFC8E6C9),
                  Color(0xFFFFCCBC),
                  Color(0xFFFFE0B2),
                  Color(0xFFFFCDD2),
                ],
                chartValuesOptions: ChartValuesOptions(
                  showChartValues: true,
                  showChartValuesInPercentage: true,
                  showChartValueBackground: false,
                  chartValueStyle: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                legendOptions: LegendOptions(
                  showLegends: true,
                  legendTextStyle: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  legendPosition: LegendPosition.bottom,
                  showLegendsInRow: true,
                ),
                centerText: "My\nDonations",
                animationDuration: Duration(milliseconds: 1000),
              ),
            ),
            SizedBox(height: 30),
            Text(
              "Donations Breakdown",
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A4A4A),
              ),
            ),
            SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: categoryCounts.length,
              itemBuilder: (context, index) {
                String key = categoryCounts.keys.elementAt(index);
                double value = categoryCounts[key]!;
                return Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: Icon(
                      Icons.volunteer_activism,
                      color: Colors.blue.shade200,
                    ),
                    title: Text(
                      key,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),
                    trailing: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFFE1F5FE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
