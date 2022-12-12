import 'dart:async';
import 'dart:collection';

import 'package:agora_flutter_quickstart/ui/screens/set_location_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:agora_flutter_quickstart/data/app_colors.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoder/geocoder.dart' as GeoCoder;

class MyLocationScreen extends StatefulWidget {
  MyLocationScreen({Key? key}) : super(key: key);

  @override
  _MyLocationScreenState createState() => _MyLocationScreenState();
}

class _MyLocationScreenState extends State<MyLocationScreen> {
   bool isLocationSet = false;
   double? long;
   double? lat;
   String? address='';

   double CAMERA_ZOOM = 17;
   double CAMERA_TILT = 0;
   double CAMERA_BEARING = 30;
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
    setSourceAndDestinationIcons();
  }

  void setSourceAndDestinationIcons() async {

    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        "assets/destination_map_marker.png");
    setState(() {

    });

     _showPickLocationDialog(context);
  }
  void onMapCreated(GoogleMapController controller) {

    //_getCurrentLocation();
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


    /// destination marker
    _addMarker(LatLng(newLocale.latitude!, newLocale.longitude!), "destination",
      destinationIcon!);


  }

  _updateMarkerWithLong(double lat,double  lng) async{
    CameraPosition? cameraPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      bearing: CAMERA_BEARING,
      tilt: CAMERA_TILT,
      target: LatLng(lat, lng),
    );



    await gmController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition!));
    /// destination marker
    _addMarker(LatLng(lat, lng), "destination",
        destinationIcon!);
    setState(() {

    });
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

   await gmController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition!));
    _updateMarker(_locationData!);

    if(_locationSubsription!=null){
      _locationSubsription!.cancel();
    }

    long = _locationData!.longitude!;
    lat =   _locationData!.latitude!;

    setState(() {

    });
    // get a readable address
    final coordinates =  GeoCoder.Coordinates(
      lat!,long! );
    var addresses = await GeoCoder.Geocoder.local.findAddressesFromCoordinates(
        coordinates);
    var first = addresses.first;
    print('the address ${first.locality}, ${first.adminArea},${first.subLocality}, ${first.subAdminArea},${first.addressLine}, ${first.featureName},${first.thoroughfare}, ${first.subThoroughfare}');
    address =  addresses.first.locality!+' '+first.subAdminArea ;

    setState(() {
      isLocationSet=true;
    });
    // set the route lines on the map from source to destination
    // for more info follow this tutorial
//    _locationSubsription = _locationTracker.onLocationChanged.listen((newLocalData) {
//      if(_controller!=null){
//        CameraPosition newCameraPosition = CameraPosition(
//          zoom: CAMERA_ZOOM,
//          bearing: CAMERA_BEARING,
//          tilt: CAMERA_TILT,
//          target: LatLng(newLocalData.latitude, newLocalData.longitude),
//        );
//        gmController.animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
//        setPolylines(newLocalData.latitude, newLocalData.longitude);
//        _updateMarker(newLocalData);
//      }
//    });
  }


  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;


    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop({'address': address});

        return false;
      },
      child: Scaffold(
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
            isLocationSet==false?Container():
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: IconButton(
                                icon: Icon(Icons.close),
                                color: AppColors.grey,
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            Flexible(
                              child: Icon(
                                Icons.location_on,
                                color: AppColors.red,
                                size: 45,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Your Location',
                                    style: TextStyle(
                                        color:
                                            AppColors.textColor.withOpacity(0.93),
                                        fontWeight: FontWeight.bold)),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(address!,
                                    style: TextStyle(
                                        color: AppColors.red.withOpacity(0.93),
                                        fontWeight: FontWeight.normal)),
                              ],
                            ),
                            Expanded(
                              child: RichText(textAlign: TextAlign.right,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text: "Edit",
                                        style: TextStyle(
                                            color: AppColors.textCaptionColor,
                                            fontWeight: FontWeight.normal)),
                                    WidgetSpan(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 5.0),
                                        child: Icon(
                                          Icons.edit_outlined,
                                          size: 15,
                                          color: AppColors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ]),
                    ),
                  ),
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }

  void _showPickLocationDialog(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        builder: (BuildContext context) {
          double modalBottomSheetHeight = 0.50;
          return DraggableScrollableSheet(
              initialChildSize: modalBottomSheetHeight, //set this as you want
              maxChildSize: modalBottomSheetHeight, //set this as you want
              minChildSize: modalBottomSheetHeight, //set this as you want
              expand: true,
              builder: (context, scrollController) {
                final double closeButtonheight = 40;
                final double closeButtonwidth = 100;
                return Column(
                  children: [

                   Container(
                     color: Colors.white,
                            child: Padding(
                       padding: const EdgeInsets.fromLTRB(0, 0.0, 0, 30),
                       child: Expanded(
                         child: Column(
                           mainAxisSize: MainAxisSize.min,
                           crossAxisAlignment: CrossAxisAlignment.center,
                           children: [
                             Column(
                               mainAxisAlignment: MainAxisAlignment.start,
                               children: [
                                 Row(
                                   mainAxisAlignment: MainAxisAlignment.end,
                                   children: [
                                     IconButton(
                                       icon: Icon(Icons.close),
                                       color: AppColors.grey,
                                       onPressed: () {
                                         Navigator.pop(context);
                                       },
                                     ),
                                   ],
                                 ),
                                 Container(
                                     decoration: BoxDecoration(
                                         boxShadow: [
//                                           BoxShadow(
//                                             color: Colors.grey.withOpacity(0.1),
//                                             blurRadius: 5.0,
//                                           ),
                                         ]
                                     ),
                                     child:   Icon(
                                       Icons.add_location,
                                       color: AppColors.red,
                                       size: 70,
                                     ),
                                 ),

                               ],
                             ),

                             Padding(
                               padding: const EdgeInsets.all(8.0),
                               child: Text("Where are you?",
                                   textAlign: TextAlign.center,
                                   style: TextStyle(color:Colors.black87,fontSize: 15)),
                             ),
                             Padding(
                               padding: const EdgeInsets.all(20.0),
                               child: Text("Set your location to get an emergency response dirrected to you.",
                                   textAlign: TextAlign.center,
                                   style: TextStyle(color:Colors.black38,fontSize: 15)),
                             ),
                             FractionallySizedBox(
                               widthFactor: 0.8,
                               child: RaisedButton(
                                 color: AppColors.red,
                                 shape: RoundedRectangleBorder(
                                     borderRadius: BorderRadius.circular(32.0)),
                                 onPressed: ()  {
                                   _getCurrentLocation();
                                    Navigator.pop(context);
                                 },
                                 child: Padding(
                                     padding: const EdgeInsets.symmetric(vertical: 16.0),
                                     child: Text('Set location Automatically',
                                         style: TextStyle(color: Colors.white))
                                 ),
                               ),
                             ),
                             SizedBox(
                               height: 15,
                             ),
                             FractionallySizedBox(
                               widthFactor: 0.8,
                               child: RaisedButton(
                                 color: AppColors.white,
                                 shape: RoundedRectangleBorder(
                                     side: BorderSide(width: 1,color: AppColors.red),
                                     borderRadius: BorderRadius.circular(32.0)),
                                 onPressed: () async {
                                Navigator.of(context).pop();
                               Map result = await  Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => SetLocationScreen()
                                  ));
                               if (result != null && result.containsKey('address')) {
                                 setState(() {
                                  address = result['address'];
                                  long = result['long'];
                                  lat = result['lat'];
                                  isLocationSet = true;
                                 });
                                 _updateMarkerWithLong(lat!, long!);
                               }

                                 },
                                 child: Padding(
                                     padding: const EdgeInsets.symmetric(vertical: 16.0),
                                     child: Text('Set location manually',
                                         style: TextStyle(color:AppColors.grey))
                                 ),
                               ),
                             ),
                             SizedBox(
                               height: 15,
                             ),
                           ],
                         ),
                       ),
                     ),
                   ),
                  ],
                ); //whatever you're returning, does not have to be a Container
              });
        });
  }

}
