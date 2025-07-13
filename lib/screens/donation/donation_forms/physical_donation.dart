import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_project/screens/donation/pickup/pickup_request_form.dart';
import 'package:fyp_project/widgets/toast_message.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/custom_textfield.dart' show CustomTextField;

class PhysicalDonation extends StatefulWidget {
  /// Get Requester Data:
  final String requesterId;
  final String requestId;
  final String category;
  final String name;

  PhysicalDonation({super.key, required this.requesterId, required this.category, required this.name, required this.requestId});

  @override
  State<PhysicalDonation> createState() => _PhysicalDonationState();
}

class _PhysicalDonationState extends State<PhysicalDonation> {
  /// Controllers:
  final TextEditingController donorNameController = TextEditingController();
  final TextEditingController requesterNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  /// Fetch User Id:
  final user = FirebaseAuth.instance.currentUser?.uid;
 /// Category:
  String? _selectedCategory;
  /// Form key
  final _formKey = GlobalKey<FormState>();
  /// Is Submit:
  bool _isSubmit = false;
  /// List:
  final List<String> _categories = ['Food', 'Cloth', 'Book'];
/// Pop Up:
  customPopUp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Image:
              Image.asset("assets/images/popUp/pop.png"),
              SizedBox(height: 15),
              Text(
                "Donation Successfully Submitted. Please Create Pickup Request For Donation",
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              /// Button:
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PickupRequestForm(requesterId: widget.requesterId, requestId: widget.requestId),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0XFF9CCCF2),
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
 /// Submit Function:
  Future<void> _submitDonation() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('donations').add({
      'donorId': userId,
      'requesterId': widget.requesterId,
      'category': _selectedCategory ?? widget.category,
      'description': descriptionController.text,
      'requesterName': requesterNameController.text,
      'requestId':widget.requestId,
      'quantity': quantityController.text,
      'amount': null,
      'timestamp': FieldValue.serverTimestamp(),
      'transactionId': null,
      'paymentStatus': null,
    });
    customPopUp();
    showToast(message: "Donation Successfully Submit!, Please Create Pickup Request", context: context);

    descriptionController.clear();
    donorNameController.clear();
    requesterNameController.clear();
    quantityController.clear();
    setState(() {
      _selectedCategory = null;
    });
  }

  @override
  void initState() {
    super.initState();
    /// Set Data On Field:
    if (_categories.contains(widget.category)) {
      _selectedCategory = widget.category;
    } else {
      _selectedCategory = null;
    }
    requesterNameController.text = widget.name;
  }
  String _getCategoryImage(String category) {
    switch (category) {
      case 'Food':
        return 'assets/images/donation/donation_forms/food.gif';
      case 'Cloth':
        return 'assets/images/donation/donation_forms/cloth.png';
      case 'Book':
        return 'assets/images/donation/donation_forms/book.png';
      default:
        return 'assets/images/donation/donation_forms/book.png'; // fallback image
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Appbar:
      appBar: customAppBarForScreens("Create a Donation"),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.08),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: constraints.maxHeight * 0.02),
                    /// Image:
                    Center(child: Image.asset( _getCategoryImage(_selectedCategory ?? widget.category), height: constraints.maxHeight * 0.27)),
                    SizedBox(height: constraints.maxHeight * 0.02),
                    /// Name:
                    CustomTextField(
                      controller: requesterNameController,
                      icon: Icons.person,
                      label: 'Requester Name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                      onChanged: (value){},
                    ),
                    SizedBox(height: constraints.maxHeight * 0.02),
                    /// Category:
                    CustomTextField(
                      initialValue: _selectedCategory,
                      icon: Icons.category_outlined,
                      label: 'Select Category',
                      isDropdown: true,
                      dropdownItems: _categories,
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },

                    ),
                    SizedBox(height: constraints.maxHeight * 0.02),
                    /// Description:
                    CustomTextField(
                      maxLines: 3,
                      controller: descriptionController,
                      icon: Icons.info_outline,
                      label: 'Description',
                      keyboardType: TextInputType.multiline,
                      validator: (value) => value!.isEmpty ? "Description is required" : null,
                      onChanged: (value){},
                    ),
                    SizedBox(height: constraints.maxHeight * 0.02),
                    /// Quality:
                    CustomTextField(
                      controller: quantityController,
                      icon: Icons.star_border_purple500_outlined,
                      label: 'Quality',
                      validator: (value) => value!.isEmpty ? "Quantity is required" : null,
                      onChanged: (value){},
                    ),
                    SizedBox(height: constraints.maxHeight * 0.04),
                    /// Button:
                    SizedBox(
                      width: 270,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isSubmit = true;
                            });
                            await _submitDonation();
                            setState(() {
                              _isSubmit = false;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9CCCF2),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: _isSubmit ? CircularProgressIndicator(color: Colors.white) :
                        Text('Submit Donation',
                            style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Poppins")),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
