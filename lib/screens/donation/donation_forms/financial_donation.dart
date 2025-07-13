import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fyp_project/backend/payment_service/payment_service.dart';
import 'package:fyp_project/widgets/toast_message.dart';
import 'package:fyp_project/widgets/appbar.dart';
import '../../../widgets/custom_textfield.dart';

class FinancialDonation extends StatefulWidget {
  /// Fetch Data From previous Screen:
  final String requesterId;
  final String category;
  final String name;
  final String requestId;

  FinancialDonation({super.key, required this.requesterId, required this.category, required this.name,required this.requestId});

  @override
  State<FinancialDonation> createState() => _FinancialDonationState();
}

class _FinancialDonationState extends State<FinancialDonation> {
  /// Form key:
  final _formKey = GlobalKey<FormState>();
  /// Controllers:
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController requesterNameController = TextEditingController();
  bool _isSubmit = false;
  /// List:
  final List<String> _categories = ['Wedding', 'Education', 'Health'];
  /// Select Category:
  String? _selectedCategory;
  /// Payment Service:
  Map<String, dynamic>? paymentIntent;
  PaymentService paymentService = PaymentService();

  @override
  void initState() {
    super.initState();
    /// Set Data On Fields:
    _selectedCategory = _categories.contains(widget.category) ? widget.category : null;
    requesterNameController.text = widget.name;
  }
/// Make Payment method:
  Future<void> _makePayment(String amount, String currency, BuildContext context) async {
    try {
      paymentIntent = await paymentService.createPaymentIntent(amount, currency, context);
      if (paymentIntent == null) return;

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          googlePay: PaymentSheetGooglePay(
            merchantCountryCode: "PK",
            testEnv: true,
            currencyCode: 'PKR',
          ),
          merchantDisplayName: 'Little Light',
          billingDetails: BillingDetails(
            name: "",
            email: "",
            phone: "",
            address: Address(
              city: "",
              country: "PK",  // 🇵🇰 Pakistan ka country code
              line1: "",
              line2: "",
              postalCode: "",
              state: "",
            ),
          ),
        ),
      );

      await _displayPaymentSheet();
      await updateTotalFunds(amountController.text);
      requesterNameController.clear();
      descriptionController.clear();
      amountController.clear();

      Navigator.pop(context);
    } catch (e) {
      showToast(message: "Payment Error: $e", context: context);
      print("Error:$e");
    }
  }
/// Display payment Sheet:
  Future<void> _displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();

      await FirebaseFirestore.instance.collection('donations').add({
        'donorId': FirebaseAuth.instance.currentUser!.uid,
        'requesterId': widget.requesterId,
        'category': _selectedCategory,
        'description': descriptionController.text,
        'requesterName': requesterNameController.text,
        'requestId':widget.requestId,
        'amount': amountController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'transactionId': paymentIntent?['id'] ?? 'N/A',
        'paymentStatus': 'Passed',
        'status':'Pending'
      });

      showToast(message: "Payment successful & stored in Firestore!", context: context);
    } catch (e) {
      showToast(message: "Payment Failed: $e", context: context);
      await FirebaseFirestore.instance.collection('donations').add({
        'donorId': FirebaseAuth.instance.currentUser!.uid,
        'requesterId': widget.requesterId,
        'category': _selectedCategory,
        'description': descriptionController.text,
        'requesterName': requesterNameController.text,
        'amount': amountController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'transactionId': paymentIntent?['id'] ?? 'N/A',
        'paymentStatus': 'Failed',
      });
      print("Error:$e");
    }
  }
  /// Update Funds:import 'package:cloud_firestore/cloud_firestore.dart';

  Future<void> updateTotalFunds(String amount) async {
    try {
      // Check if the amount is a valid number
      double amountDouble = double.tryParse(amount) ?? 0.0;

      DocumentReference fundsRef =
          FirebaseFirestore.instance.collection('funds').doc('admin');

      DocumentSnapshot snapshot = await fundsRef.get();

      double currentFunds = snapshot.exists && snapshot.data() != null
          ? double.tryParse(snapshot['totalFunds'].toString()) ?? 0.0
          : 0.0;

      double newTotalFunds = currentFunds + amountDouble;

      await fundsRef.set({'totalFunds': newTotalFunds}, SetOptions(merge: true));

      print('Fund updated successfully');
    } catch (e) {
      print('Error updating fund: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    /// Media query:
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      /// Appbar:
      appBar: customAppBarForScreens("Financial Donation"),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, // 5% screen width
            vertical: screenHeight * 0.02, // 2% screen height
          ),
          child: Form(
            key: _formKey,
            child: Column(
           crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// Image:
                Center(
                  child: Image.asset(
                    "assets/images/donation/donation_forms/financial.png",
                    height: screenHeight * 0.28, // 25% screen height
                    width: screenWidth * 0.8, // 80% screen width

                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                /// Requester Name:
                Center(
                  child: CustomTextField(
                    controller: requesterNameController,
                    icon: Icons.person,
                    label: 'Requester Name',
                    validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
                    onChanged: (value){

                    },
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                /// Description:
                CustomTextField(
                  maxLines: 3,
                  controller: descriptionController,
                  icon: Icons.info_outline,
                  label: 'Description',
                  validator: (value) => value!.isEmpty ? "Description is required" : null,
                  onChanged: (value){

                  },
                ),
                SizedBox(height: screenHeight * 0.02),
                /// Category Dropdown
                CustomTextField(
                  initialValue: _selectedCategory,
                  icon: Icons.category_outlined,
                  label: 'Select Category',
                  isDropdown: true,
                  dropdownItems: _categories,
                  onChanged: (value) => _selectedCategory = value,
                  validator: (value) => value == null ? "Please select a category" : null,
                ),
                SizedBox(height: screenHeight * 0.02),
                /// Amount Field
                CustomTextField(
                  controller: amountController,
                  icon: Icons.money,
                  label: 'Amount (PKR)',
                  validator: (value) => value!.isEmpty ? "Amount is required" : null,
                  onChanged: (value){

                  },
                ),
                SizedBox(height: screenHeight * 0.04),
                /// Submit Button
                SizedBox(
                  width: 270,

                  child: ElevatedButton(
                    onPressed: _isSubmit
                        ? null
                        : () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => _isSubmit = true);
                        await _makePayment(amountController.text, "PKR", context);


                        setState(() => _isSubmit = false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF9CCCF2),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: _isSubmit
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                      'Submit Donation',
                      style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04, fontWeight: FontWeight.w500,fontFamily: "Poppins"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

