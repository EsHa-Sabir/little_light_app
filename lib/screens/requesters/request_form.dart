import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_project/screens/requesters/request_detail.dart';
import 'package:fyp_project/widgets/appbar.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../backend/notification/notification.dart';
import '../../backend/user/user_provider.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/toast_message.dart';

class RequestForm extends StatefulWidget {
  const RequestForm({super.key});

  @override
  State<RequestForm> createState() => _RequestFormState();
}

class _RequestFormState extends State<RequestForm> {
  /// Form Key:
  final _formKey = GlobalKey<FormState>();
  /// User Id:
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  /// For Loading Purpose:
  bool isSubmit = false;
  /// Controllers:
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  /// For Category
  String? selectedRequestType;
  /// Location:
  LatLng? location;
  /// Map Controller:
  GoogleMapController? mapController;
  /// Address into map:
  Future<void> _getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        setState(() {
          location = LatLng(locations[0].latitude, locations[0].longitude);
        });
        if (mapController != null) {
          mapController!.animateCamera(
            CameraUpdate.newLatLng(location!),
          );
        }
      }
    } catch (e) {
      print("Error geocoding address: $e");
    }
  }
 /// Submit Request:
  Future<void> _submitRequest(String requester) async {
    if (!_formKey.currentState!.validate() || location == null) {
      showToast(message: "Please Validate The Address", context: context);
      return;
    }
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final requestRef = await FirebaseFirestore.instance.collection('requests').add({
      'requesterId': userId,
      'name': nameController.text,
      'description': descriptionController.text,
      'phone': phoneController.text,
      'email': emailController.text,
      'requestType': selectedRequestType,
      'address': addressController.text,
      'location': {
        'latitude': location!.latitude,
        'longitude': location!.longitude,
      },
      'status': 'Pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    showToast(message: "Request Submitted Successfully", context: context);
    sendNotificationToSpecificUsers("New Request Update",'New Request is arrived by $requester','Donor');
    sendNotificationToSpecificUsers1("New Request Update",'New Request is arrived by $requester','Donor');
    _resetForm();
    customPopUp(requestRef.id);
  }
/// Reset Form:
  void _resetForm() {
    nameController.clear();
    descriptionController.clear();
    phoneController.clear();
    emailController.clear();
    addressController.clear();
    setState(() {
      selectedRequestType = null;
    });
  }
/// Pop Up:
  customPopUp(String requestId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Image:
              Image.asset("assets/images/popUp/pop.png"),
              const SizedBox(height: 15),
              const Text(
                "Request Successfully Submitted",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RequestDetail(requestId: requestId)),
                  );
                },
                child: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0XFF9CCCF2),
                  child: Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    /// Fetch User Data:
    if (userId != null) {
      Provider.of<UserProvider>(context, listen: false).fetchUserData(userId!, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    /// User Provider:
    final userProvider = Provider.of<UserProvider>(context);
    /// Media Query:
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      /// Appbar:
      appBar: customAppBarForScreens("Create Request"),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              /// Name:
              Center(
                child: CustomTextField(
                  controller: nameController,
                  icon: Icons.person_outline,
                  label: 'Name',
                  onChanged:(value){

                  },
                  validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                ),
              ),
              const SizedBox(height: 15),
              /// Description:
              CustomTextField(
                controller: descriptionController,
                icon: Icons.info_outline,
                label: 'Description',
                maxLines: 3,
                onChanged:(value){

              },
                validator: (value) => value!.isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 10),
              /// Mobile:
              CustomTextField(
                keyboardType: TextInputType.number,
                controller: phoneController,
                icon: Icons.phone_outlined,
                onChanged:(value){

                },
                label: 'Mobile',
                validator: (value) => value!.isEmpty ? 'Please enter a Mobile Number' : null,
              ),
              const SizedBox(height: 10),
              /// Email:
              CustomTextField(
                controller: emailController,
                icon: Icons.email_outlined,
                onChanged:(value){

                },
                label: 'E-mail',
                validator: (value) => !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!) ? 'Enter a valid email' : null,
              ),
              const SizedBox(height: 10),
              /// Category:
              CustomTextField(
                icon: Icons.category_outlined,
                label: 'Select Type',
                isDropdown: true,
                dropdownItems: ['Cloth', 'Food', 'Book', 'Health', 'Education', 'Wedding'],
                onChanged: (value) => selectedRequestType = value,
                validator: (value) => value == null || value.isEmpty ? 'Please Select a Type' : null,
              ),
              const SizedBox(height: 10),
              /// Address:
              CustomTextField(
                controller: addressController,
                icon: Icons.home_outlined,
                label: 'Address',
                onChanged: _getCoordinatesFromAddress,
                validator: (value) => value!.isEmpty ? 'Please enter an address' : null,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              /// Button:
              SizedBox(
                width: 270,

                child: ElevatedButton(
                  onPressed: () async {
                    setState(() => isSubmit = true);
                    await _submitRequest(userProvider.userData?['username']);
                    setState(() => isSubmit = false);
                  },
                  child: isSubmit ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : Text("Submit Request",  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9CCCF2),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
