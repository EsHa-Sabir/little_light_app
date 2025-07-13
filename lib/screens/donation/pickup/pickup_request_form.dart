import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_project/backend/notification/notification.dart';
import 'package:fyp_project/widgets/toast_message.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import '../../../backend/user/user_provider.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/custom_textfield.dart';
import 'location_picker.dart';

class PickupRequestForm extends StatefulWidget {
  /// Get Data From previous Page:
  final String requesterId;
  final String requestId;

  const PickupRequestForm({super.key, required this.requesterId, required this.requestId});

  @override
  State<PickupRequestForm> createState() => _PickupRequestFormState();
}

class _PickupRequestFormState extends State<PickupRequestForm> {
  /// Controller:
  final TextEditingController nameController = TextEditingController();
  final TextEditingController pickupAddressController = TextEditingController();
  final TextEditingController deliveryAddressController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  /// For loading Purpose:
  bool _isSubmit = false;
  /// For location:
  LatLng? pickupLocation;
  LatLng? deliveryLocation;
  /// Get id:
  String? userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    /// User Provider:
    if (userId != null) {
      Provider.of<UserProvider>(context, listen: false).fetchUserData(userId!, context);
    }
  }
/// Location Picker:
  Future<void> pickLocation(bool isPickup) async {
    LatLng? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LocationPickerScreen()),
    );

    if (selectedLocation != null) {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        selectedLocation.latitude, selectedLocation.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = "${place.street}, ${place.locality}, ${place.country}";

        setState(() {
          if (isPickup) {
            pickupLocation = selectedLocation;
            pickupAddressController.text = address;
          } else {
            deliveryLocation = selectedLocation;
            deliveryAddressController.text = address;
          }
        });
      } else {
        showToast(message: "Could not fetch address, try again!", context: context);
      }
    }
  }
/// Submit Request:
  Future<void> submitPickupRequest(String donor) async {
    if (nameController.text.isEmpty ||
        pickupAddressController.text.isEmpty ||
        deliveryAddressController.text.isEmpty) {
      showToast(message: 'Please Fill all Fields', context: context);
      return;
    }

    String pickupId = FirebaseFirestore.instance.collection('pickup_requests').doc().id;
    await FirebaseFirestore.instance.collection('pickup_requests').doc(pickupId).set({
      'pickupId': pickupId,
      'donorId': FirebaseAuth.instance.currentUser?.uid,
      "requesterId": widget.requesterId,
      'requestId': widget.requestId,
      'name': nameController.text,
      'pickupAddress': pickupAddressController.text,
      'deliveryAddress': deliveryAddressController.text,
      'pickupLatitude': pickupLocation!.latitude,
      'pickupLongitude': pickupLocation!.longitude,
      'deliveryLatitude': deliveryLocation!.latitude,
      'deliveryLongitude': deliveryLocation!.longitude,
      'description': descriptionController.text,
      'status': 'Pending',
      'timestamp': FieldValue.serverTimestamp(),
      "delivery_status": "pending"
    });

    sendNotificationToSpecificUsers(
        "PickUp Request Update", "New Pickup request Is arrived by $donor", 'Volunteer');

    showToast(message: "Pickup Request Submitted Successfully", context: context);

    Navigator.pop(context, true);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    /// User Provider:
    final userProvider = Provider.of<UserProvider>(context);
    /// Media Query:
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      /// Appbar:
      appBar: customAppBarForScreens("Create Pickup Request"),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.03),
              /// Image:
              Center(
                child: Image.asset(
                  "assets/images/donation/pickup/pickup.png",
                  height: screenHeight * 0.27,
                  width: screenWidth * 0.6,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              /// Name:
              CustomTextField(controller: nameController, icon: Icons.person, label: 'Enter Your Name',onChanged: (value){

              },),
              SizedBox(height: screenHeight * 0.015),
              /// description:
              CustomTextField(controller: descriptionController, icon: Icons.info_outline, label: 'Enter Description', maxLines: 3,onChanged: (value){

              },),
              SizedBox(height: screenHeight * 0.015),
              /// Pickup Location:
              GestureDetector(
                onTap: () => pickLocation(true),
                child: AbsorbPointer(child: CustomTextField(controller: pickupAddressController, icon: Icons.location_on, label: 'Select Pickup Location',onChanged: (value){

                })),
              ),
              SizedBox(height: screenHeight * 0.015),
              /// Delivery Location:
              GestureDetector(
                onTap: () => pickLocation(false),
                child: AbsorbPointer(child: CustomTextField(controller: deliveryAddressController, icon: Icons.location_on, label: 'Select Delivery Location',onChanged: (value){

                })),
              ),
              SizedBox(height: screenHeight * 0.03),
              /// Button:
              SizedBox(
                width: 270,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF9CCCF2),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  onPressed: () async {
                    setState(() => _isSubmit = true);
                    await submitPickupRequest(userProvider.userData?['username'] ?? "");
                    setState(() => _isSubmit = false);
                  },
                  child: _isSubmit
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Submit Request', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}
