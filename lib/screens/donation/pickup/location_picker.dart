import 'package:flutter/material.dart';
import 'package:fyp_project/widgets/appbar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerScreen extends StatefulWidget {
  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  /// Selected Location:
  LatLng? selectedLocation;
  /// Map Controller:
  GoogleMapController? mapController;
  /// On Tap:
  void _onMapTapped(LatLng latLng) {
    setState(() {
      selectedLocation = latLng;
    });
  }
/// On Save:
  void _onSaveLocation() {
    if (selectedLocation != null) {
      Navigator.pop(context, selectedLocation);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a location")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Appbar:
      appBar:customAppBarForScreens("Location Picker"),
      /// Map:
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: LatLng(31.5204, 74.3587), zoom: 12),
        onTap: _onMapTapped,
        markers: selectedLocation != null
            ? {Marker(markerId: MarkerId("selected"), position: selectedLocation!)}
            : {},
        onMapCreated: (controller) {
          setState(() {
            mapController = controller;
          });
        },
      ),
      /// Floating Button:
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onSaveLocation,
        backgroundColor: Color(0XFF09CCCF2),
        label: Text("Confirm Location",style: TextStyle(
          fontFamily: "Poppins",
          fontWeight: FontWeight.w400,
          color: Colors.white,
          fontSize: 13
        ),),
        icon: Icon(Icons.check,color: Colors.white,),
      ),
    );
  }
}
