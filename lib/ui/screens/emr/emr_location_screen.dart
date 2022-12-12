import 'dart:async';
import 'dart:collection';

import 'package:agora_flutter_quickstart/model/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:agora_flutter_quickstart/data/app_colors.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
class EmrLocationScreen extends StatefulWidget {
  final a? notif;
  EmrLocationScreen({Key? key,this.notif}) : super(key: key);

  @override
  _EmrLocationScreenState createState() => _EmrLocationScreenState();
}

class _EmrLocationScreenState extends State<EmrLocationScreen> {
   double CAMERA_ZOOM = 15;
   double CAMERA_TILT = 0;
   double CAMERA_BEARING = 40;
   double _originLatitude = 7.6206943000146685, _originLongitude = 4.20355354487431;
   double _destLatitude = 7.6206943000146685, _destLongitude = 4.20355354487431;

  Completer<GoogleMapController> _controller = Completer();
   GoogleMapController? gmController ;
// this set will hold my markers
  Map<MarkerId, Marker> markers = {};

  // for my drawn routes on the map
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints? polylinePoints;

  String googleAPIKey = "AIzaSyAcujoi00fcoumoU_OO7MTU_CavA6U52mk";
// for my custom icons
  BitmapDescriptor? sourceIcon;
  BitmapDescriptor? destinationIcon;
  String _locationMessage = '';

  StreamSubscription? _locationSubsription;
  Location location = new Location();
  Location _locationTracker = Location();

  bool? _serviceEnabled;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;

  Set<Circle> _circles = HashSet<Circle>();

  static final CameraPosition _initialCameraPosition = CameraPosition(
    target:LatLng(37.42796133530664,-122.085749555962),
    zoom:15
  );

  @override
  void initState(){
    super.initState();
    polylinePoints = PolylinePoints();
    _getCurrentLocation();
    setSourceAndDestinationIcons();
  }

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(100,100)),
        "assets/driving_pin.png");
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(100,100)),
        "assets/destination_map_marker.png");
    setState(() {

    });
  }
  void onMapCreated(GoogleMapController controller) {

   // _getCurrentLocation();
    _controller.complete(controller);
    gmController = controller;

  }


  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
    Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  _updateMarker(LocationData newLocale){
    /// origin marker
    _addMarker(LatLng(_originLatitude, _originLongitude), "origin",
       sourceIcon!);

    /// destination marker
    _addMarker(LatLng(newLocale.latitude!, newLocale.longitude!), "destination",
      destinationIcon!);


  }

  void setPolylines() async {
    PolylineResult result = await polylinePoints!.getRouteBetweenCoordinates(
        googleAPIKey,
        PointLatLng(_originLatitude, _originLongitude),
        PointLatLng(_destLatitude, _destLongitude),
        travelMode: TravelMode.driving,


    );
    if(result.points.isNotEmpty){
      result.points.forEach((PointLatLng point){
        print('the points'+point.toString());
        polylineCoordinates.add(
            LatLng(point.latitude,point.longitude)
        );
      });
      setState(() {
        _polylines.add(Polyline(
            width: 5, // set the width of the polylines
            polylineId: PolylineId("poly"),
            color: AppColors.redIconColor,
            points: polylineCoordinates
        ));
      });
    }else{
      print('result is empty');
      print('values '+ _originLatitude.toString()+"  "+_originLongitude.toString());
      print('values '+ _destLatitude.toString()+"  "+_destLongitude.toString());

    }
  }




  void _getCurrentLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled!) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled!) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

   _locationData = await Location().getLocation();

    CameraPosition? cameraPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      bearing: CAMERA_BEARING,
      tilt: CAMERA_TILT,
      target: LatLng(_locationData!.latitude!, _locationData!.longitude!),
    );

    _originLatitude = _locationData!.latitude!;
    _originLongitude = _locationData!.longitude!;

    print('we got the destination long and lat');
    _destLatitude = double.parse(widget.notif!.lattitude!);
    _destLongitude = double.parse(widget.notif!.longitude!);
    print('we got the destination long and lat' +_destLatitude.toString());

    await gmController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition!));
    _updateMarker(_locationData!);

    if(_locationSubsription!=null){
     await _locationSubsription!.cancel();
    }
    setState(() {

    });
    // set the route lines on the map from source to destination
    // for more info follow this tutorial
    setPolylines();
    _locationSubsription = _locationTracker.onLocationChanged.listen((newLocalData) {
      if(_controller!=null){
        var newCameraPosition = CameraPosition(
          zoom: CAMERA_ZOOM,
          bearing: CAMERA_BEARING,
          tilt: CAMERA_TILT,
          target: LatLng(newLocalData.latitude!, newLocalData.longitude!),
        );
        gmController!.animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
        _originLatitude=newLocalData.latitude!;
        _originLongitude=newLocalData.longitude!;
        setPolylines();
        _updateMarker(newLocalData);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;


    return Scaffold(
      body: SafeArea(
        top: false,
        child: Stack(children: [
          GoogleMap(
              myLocationEnabled: false,
              circles:   _circles,
              zoomControlsEnabled: true,
              tiltGesturesEnabled: false,
              markers: Set<Marker>.of(markers.values),
              polylines: _polylines,
              mapType: MapType.normal,
              initialCameraPosition: _initialCameraPosition,
              onMapCreated: onMapCreated
          ),
          Positioned(
            top: height / 10,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 15.0, 15, 15),
                  child: Expanded(
                    child: Row(
                        children: [
                          SizedBox(width:20),
                          Icon(
                            Icons.send,
                            color: AppColors.red,
                            size: 30,
                          ),
                          SizedBox(width:30),

                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Help is on its way to:',
                                  style: TextStyle(
                                      color:
                                          AppColors.textColor.withOpacity(0.93),
                                      fontWeight: FontWeight.bold)),
                              SizedBox(
                                height: 5,
                              ),
                              Text('Hills Avenue NW',
                                  style: TextStyle(
                                      color: AppColors.red.withOpacity(0.93),
                                      fontWeight: FontWeight.normal)),
                            ],
                          ),

                        ]),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: height / 1.5,
            left: 0,
            right: 0,
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 15.0, 15, 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,

                  children: [
                    SizedBox(height:20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.phone,
                            color: AppColors.red,
                            size: 20,
                          ),
                          SizedBox(width:30),
                          Text('0701-2057-4548',
                              style: TextStyle(
                                  color:
                                  AppColors.textColor.withOpacity(0.93),
                                  fontWeight: FontWeight.bold)),


                        ]),
                    SizedBox(height:20),

                    Text('Location Arrived!',
                        style: TextStyle(
                          fontSize: 18,
                            color:
                            AppColors.textColor.withOpacity(0.93),
                            fontWeight: FontWeight.bold)),
                    SizedBox(height:20),
                    Container(height: 1.5,color: Colors.grey[100],),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Destination',
                            style: TextStyle(
                                fontSize: 13,
                                color:
                                AppColors.textColor.withOpacity(0.93),
                                fontWeight: FontWeight.bold)),
                          SvgPicture.asset('assets/demacate_arrow.svg',height: 30,width: 30,color: Colors.grey[100],),
                        Text('Venture Crossfit',
                            style: TextStyle(
                                fontSize: 13,
                                color:
                                AppColors.textColor.withOpacity(0.93),
                            )),
                      ],
                    ),
                    Container(height: 1.5,color: Colors.grey[100],),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Destination',
                            style: TextStyle(
                                fontSize: 13,
                                color:
                                AppColors.textColor.withOpacity(0.93),
                                fontWeight: FontWeight.bold)),
                        SvgPicture.asset('assets/demacate_arrow.svg',height: 30,width: 30,color: Colors.grey[100],),
                        Text('Venture Crossfit',
                            style: TextStyle(
                              fontSize: 13,
                              color:
                              AppColors.textColor.withOpacity(0.93),
                            )),
                      ],
                    ),
                    Container(height: 1.5,color: Colors.grey[100],),

                  ],

                ),
              ),
            ),
          ),

        ]),
      ),
    );
  }
}
