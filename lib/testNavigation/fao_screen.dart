import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:location/location.dart';

import 'navigation_screen.dart';

class FaoScreen extends StatefulWidget {
  const FaoScreen({Key? key}) : super(key: key);

  @override
  State<FaoScreen> createState() => _FaoScreenState();
}

class _FaoScreenState extends State<FaoScreen> {
  LatLng? destLocation = LatLng(37.3161, -121.9195);
  Location location = Location();
  loc.LocationData? _currentPosition;
  final Completer<GoogleMapController?> _controller = Completer();
  String? _address = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Uber'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.navigate_next),
        onPressed: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => NavigationScreen(destLocation!.latitude, destLocation!.longitude)
            ), (route) => false);
        },
      ),
      body: Stack(
        children: [
          GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            initialCameraPosition: CameraPosition(
              target: destLocation!,
              zoom: 16,
            ),
            onCameraMove: (CameraPosition? position) {
              if(destLocation != position!.target) {
                setState(() {
                  destLocation = position.target;
                });
              }
            },
            onCameraIdle: () {
              print('camera idle');
              getAddressFromLatLng();
            },
            onTap: (latLng) {
              print(latLng);
            },
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(bottom: 35.0),
              child: Image.asset('images/pick.png', height: 45, width: 45,),
            ),
          ),

          Positioned(
            top: 40,
            right: 20,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: Colors.white,
              ),
              padding: EdgeInsets.all(20),
              child: Text(_address ?? "Pick your destination address",
                overflow: TextOverflow.visible, softWrap: true
              ),
            ),
          )
        ],
      ),
    );
  }

  getAddressFromLatLng() async {
    try{
      GeoData data = await Geocoder2.getDataFromCoordinates(
          latitude: destLocation!.latitude,
          longitude: destLocation!.longitude,
          googleMapApiKey: 'AIzaSyBOnhnppouT5Zj_jLrFfY5Hwmq_WBmr3JU',
      );
      setState(() {
        _address = data.address;
        print("Address: " + "${_address}");
      });
    }catch(e){
      print(e);
    }
  }

  getCurrentLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    _serviceEnabled = await location.serviceEnabled();
    final GoogleMapController? controller = await _controller.future;

    if(!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if(!_serviceEnabled){
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if(_permissionGranted == PermissionStatus.denied){
      _permissionGranted = await location.requestPermission();
      if(_permissionGranted != PermissionStatus.granted){
        return;
      }
    }

    if(_permissionGranted == loc.PermissionStatus.granted){
      location.changeSettings(accuracy: loc.LocationAccuracy.high);

      _currentPosition = await location.getLocation();
      controller?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!),
        zoom: 16,
      )));

      setState(() {
        destLocation = LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!);
      });
    }
  }
}
