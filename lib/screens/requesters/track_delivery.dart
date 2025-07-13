import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fyp_project/screens/chat/chat_room.dart';
import 'package:fyp_project/widgets/appbar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class LiveTrackingScreen extends StatefulWidget {
  /// Get Id:
  final String pickupId;
  LiveTrackingScreen({required this.pickupId});

  @override
  _LiveTrackingScreenState createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  /// Position:
  StreamSubscription<Position>? positionStream;
  /// Map Controller:
  GoogleMapController? _mapController;
  /// Locations:
  LatLng? _volunteerLocation;
  LatLng? _deliveryLocation;
  /// Polyline:
  List<LatLng> polylineCoordinates = [];
  /// Location Stream:
  Stream<DocumentSnapshot>? locationStream;
  /// Volunteer details from pickup_requests and users collection
  String? volunteerId;
  String? volunteerName;
  String? volunteerImageUrl;

  @override
  void initState() {
    super.initState();
    /// Fetch Pickup Data:
    _fetchPickupData();

  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }
/// Fetch Pickup Data:
  void _fetchPickupData() {
    locationStream = FirebaseFirestore.instance
        .collection('pickup_requests')
        .doc(widget.pickupId)
        .snapshots();

    locationStream!.listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        var data = snapshot.data() as Map<String, dynamic>;

        /// Extract volunteer and delivery locations
        LatLng? newVolunteerLocation = (data['volunteerLocation'] != null)
            ? LatLng(data['volunteerLocation']['lat'], data['volunteerLocation']['lng'])
            : null;

        LatLng? newDeliveryLocation = (data['deliveryLatitude'] != null &&
            data['deliveryLongitude'] != null)
            ? LatLng(data['deliveryLatitude'], data['deliveryLongitude'])
            : null;

        /// Extract volunteer id from pickup_requests (assumed key 'volunteerId')
        if (data.containsKey('volunteerId')) {
          volunteerId = data['volunteerId'];
          /// Fetch volunteer details from users collection
          FirebaseFirestore.instance
              .collection('users')
              .doc(volunteerId)
              .get()
              .then((userDoc) {
            if (userDoc.exists && userDoc.data() != null) {
              var userData = userDoc.data() as Map<String, dynamic>;
              setState(() {
                volunteerName = userData['username'] ?? "Volunteer";
                volunteerImageUrl = userData['image'] ?? "";
              });
            }
          });
        }

        if (newVolunteerLocation != null) {
          setState(() {
            _volunteerLocation = newVolunteerLocation;
            _deliveryLocation = newDeliveryLocation;
          });

          if (_mapController != null) {
            _mapController!.animateCamera(CameraUpdate.newLatLng(_volunteerLocation!));
          }

          if (_deliveryLocation != null) {
            _fetchPolylineOSRM(); // Fetch route using OSRM
          }
        }
      }
    });
  }
/// Fetch Polyline:
  Future<void> _fetchPolylineOSRM() async {
    if (_volunteerLocation == null || _deliveryLocation == null) return;
    /// OSRM expects coordinates as longitude,latitude
    String url =
        "http://router.project-osrm.org/route/v1/driving/"
        "${_volunteerLocation!.longitude},${_volunteerLocation!.latitude};"
        "${_deliveryLocation!.longitude},${_deliveryLocation!.latitude}"
        "?overview=full&geometries=polyline";
    print("Fetching OSRM Directions API: $url");
    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);
    if (data['code'] == "Ok") {
      List<LatLng> newPolylineCoordinates = [];
      var points = data['routes'][0]['geometry'];
      List decodedPoints = _decodePolyline(points);
      decodedPoints.forEach((point) {
        newPolylineCoordinates.add(LatLng(point[0], point[1]));
      });

      setState(() {
        polylineCoordinates = newPolylineCoordinates;
      });
    } else {
      print("OSRM API Error: ${data['code']}");
    }
  }
  /// Decode polyline string into list of latitude,longitude pairs
  List<List<double>> _decodePolyline(String encoded) {
    List<List<double>> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);
      int deltaLat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += deltaLat;

      shift = 0;
      result = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);
      int deltaLng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += deltaLng;

      polyline.add([lat / 1E5, lng / 1E5]);
    }
    return polyline;
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      /// Appbar:
      appBar: customAppBarForScreens("Track Delivery"),
      /// Body:
      body: _volunteerLocation == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          /// Map:
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _volunteerLocation!,
              zoom: 14,
            ),
            markers: {
              Marker(
                markerId: MarkerId("volunteer"),
                position: _volunteerLocation!,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              ),
              if (_deliveryLocation != null)
                Marker(
                  markerId: MarkerId("destination"),
                  position: _deliveryLocation!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                ),
            },
            polylines: {
              if (polylineCoordinates.isNotEmpty)
                Polyline(
                  polylineId: PolylineId("route"),
                  points: polylineCoordinates,
                  color: Colors.blue,
                  width: 5,
                ),
            },
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
          ),
          /// Bottom overlay displaying volunteer details and chat icon
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.only(topLeft:Radius.circular(15),topRight: Radius.circular(15)),

              ),

              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  volunteerImageUrl != null && volunteerImageUrl!.isNotEmpty
                      ? CircleAvatar(
                  backgroundColor: Color(0xFF9CCCF2),
                    backgroundImage: NetworkImage(volunteerImageUrl!),
                    radius: 24,
                  )
                      : CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFF9CCCF2),
                    child: Icon(Icons.person,color: Colors.white,),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      volunteerName ?? "Volunteer",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,fontFamily: "Poppins"),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.chat, color: Color(0xFF9CCCF2)),
                    onPressed: () {
                      if (volunteerId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(userName:  volunteerName!, userId:volunteerId !, imageurl: volunteerImageUrl )
                        ));
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

