import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoder/geocoder.dart' as GeoCoder;
import 'package:location/location.dart';
import 'package:agora_flutter_quickstart/bloc/sign_up/bloc.dart';
import 'package:agora_flutter_quickstart/bloc/sign_up/event.dart';
import 'package:agora_flutter_quickstart/data/app_colors.dart';
import 'package:agora_flutter_quickstart/data/app_strings.dart';
import '../../repository/user_repository.dart';
import 'package:agora_flutter_quickstart/ui/screens/location_screen.dart';
import '../config/agora.config.dart' as config;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as Perm;
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// MultiChannel Example
class JoinChannelVideo extends StatefulWidget {
  String? category;
  JoinChannelVideo({this.category});
  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<JoinChannelVideo> {
  UserRepository? userRepository ;
    late RtcEngine _engine;
  String channelId = config.channelId;
  bool isJoined = false, switchCamera = true, switchRender = true;
  List<int> remoteUid = [];
  TextEditingController? _controller;

    StreamSubscription? _locationSubsription;
    Location location = new Location();
    Location _locationTracker = Location();

    bool? _serviceEnabled;
    PermissionStatus? _permissionGranted;
    LocationData? _locationData;

    // this keeps the state of the finding agents loader
    bool isFinding = true;

    SignUpBloc? _signUpBloc;

// Init firestore and geoFlutterFire
  final geo = Geoflutterfire();
  final _firestore = FirebaseFirestore.instance;

 void _findNearbyEmrs(double mylat,double mylng,myaddress) async{

    // Create a geoFirePoint
    // this will also be the users location
    GeoFirePoint center = geo.point(latitude: mylat, longitude: mylng);

    // get the collection reference or query
    var collectionReference = _firestore.collection('locations');

    double radius = 50;
    String field = 'position';

    Stream<List<DocumentSnapshot>> stream = geo.collection(collectionRef: collectionReference)
        .within(center: center, radius: radius, field: field);

    // we want to chech the results and check if any user is found.

    stream.listen((List<DocumentSnapshot> documentList) async {
      setState(() {
        isFinding=false;
      });
      // doSomething()
      if(documentList.isNotEmpty){
        GeoPoint agentPoint = documentList.first['position']['geopoint'];
        String agentId = documentList.first['id'];
        // get a readable address
        final coordinates =  GeoCoder.Coordinates(
            agentPoint.latitude, agentPoint.longitude);
        var addresses = await GeoCoder.Geocoder.local.findAddressesFromCoordinates(
            coordinates);
        var agentAddress = addresses.first;
     //   print('the address ${agentAddress.locality}, ${first.adminArea},${first.subLocality}, ${first.subAdminArea},${first.addressLine}, ${first.featureName},${first.thoroughfare}, ${first.subThoroughfare}');

        _createCall(mylat, mylng, myaddress,agentPoint.latitude,agentPoint.longitude,agentAddress.addressLine,agentId);

      }else{
       await showDialog(
            context: context,
            builder: (context) {
              return useChatFeature(context);
            });
      }


      GeoPoint point = documentList.first['position']['geopoint'];
      print('found points '+ point.latitude.toString() + ' long' +point.longitude.toString());

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

    // get a readable address
    final coordinates =  GeoCoder.Coordinates(
        _locationData!.latitude, _locationData!.longitude);
    var addresses = await GeoCoder.Geocoder.local.findAddressesFromCoordinates(
        coordinates);
    var first = addresses.first;
    print('the address ${first.locality}, ${first.adminArea},${first.subLocality}, ${first.subAdminArea},${first.addressLine}, ${first.featureName},${first.thoroughfare}, ${first.subThoroughfare}');

    // find nearby agents
    _findNearbyEmrs(_locationData!.latitude!,_locationData!.longitude!,first.addressLine);

  }

  void _createCall(mylat,mylong,myaddress,agentlat,agentlng,agentaddress,agentId){
   print("about to create call");
    _signUpBloc!.add(CreateCallEvent(
        long: mylong.toString(),
        lat:mylat.toString(),
        type:'video',
        category:widget.category!,
        address: myaddress,
        emrLat:agentlat.toString(),
        emrLong:agentlng.toString(),
      emrAddress:agentaddress,
      emrId: agentId.toString()
    ));
  }

  @override
  void initState()  {
    super.initState();
     initialize();

    _signUpBloc = BlocProvider.of<SignUpBloc>(context);
    _controller = TextEditingController(text: channelId);


    userRepository = UserRepository();
    // get the user_id and join channel
    userRepository!.getCurrentUser().then((value) => {

    _getCurrentLocation(),
    });

  }

  @override
  void dispose() {
    super.dispose();
    _engine.destroy();
  }

  _initEngine() async {

      // We didn't ask for permission yet or the permission has been denied before but not permanently.
      _engine = await RtcEngine.create(config.appId);
      await _engine.enableVideo();
      await _engine.startPreview();
      await _engine.setChannelProfile(ChannelProfile.Communication);
      await _engine.setClientRole(ClientRole.Broadcaster);
      this._addListeners();
      _joinChannel();
  }
  Future<void> initialize() async {
 //   if (APP_ID.isEmpty) {
//      setState(() {
//        _infoStrings.add(
//          'APP_ID missing, please provide your APP_ID in settings.dart',
//        );
//        _infoStrings.add('Agora Engine is not starting');
//      });
//      return;
//    }

    await _initAgoraRtcEngine();
    _addListeners();
    await _engine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(width:1920, height:1080);
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(config.token, 'demo', null, 0);
  }
  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(config.appId);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(ClientRole.Broadcaster);
  }
  _addListeners() {

    _engine.setEventHandler(RtcEngineEventHandler(
      error: (errorCode){
        print('AGOMPH:joinChannelFaiiliure${errorCode}');

      },

      cameraReady: (){
        print('AGOMPH:camera ready ');

      },
      joinChannelSuccess: (channel, uid, elapsed) {
        print('AGOMPH:joinChannelSuccess ${channel} ${uid} ${elapsed}');
        setState(() {
          isJoined = true;
        });
      },
      userJoined: (uid, elapsed) {
        print('AGOMPH:userJoined  ${uid} ${elapsed}');
        setState(() {
          remoteUid.add(uid);
        });
      },
      userOffline: (uid, reason) {
        print('AGOMPH:userOffline  $uid $reason');
        setState(() {
          remoteUid.removeWhere((element) => element == uid);
        });
      },
      leaveChannel: (stats) {
        print('AGOMPH:leaveChannel ${stats.toJson()}');
        setState(() {
          isJoined = false;
          remoteUid.clear();
        });
      },
    ));
  }

  _joinChannel() async {
   // print('AGOMPH:tyingToJoin ' + id);

    if (defaultTargetPlatform == TargetPlatform.android) {
      await [Perm.Permission.microphone, Perm.Permission.camera].request();

//     bool isPermisionGranted = await c;
//     print("isPermisionGranted :" + isPermisionGranted.toString());
    }
    try{
      if(await Perm.Permission.camera.isGranted){
    await _engine.joinChannel(config.token, "demo", null, 6);
      }else{
        print('permission not granded');
      }
    }catch(e){
      print('AGOMPH:cantJoin ${e.toString()}');

    }
  }

  _leaveChannel() async {
    await _engine.leaveChannel().then((value) => {
      Navigator.pop(context)

    });

  }

  _switchCamera() {
    _engine.switchCamera().then((value) {
      setState(() {
        switchCamera = !switchCamera;
      });
    }).catchError((err) {
      log('switchCamera $err');
    });
  }

  _switchRender() {
    setState(() {
      switchRender = !switchRender;
      remoteUid = List.of(remoteUid.reversed);
    });
  }
    Widget chooseLocationDialog(BuildContext context) {
      return StatefulBuilder(
        builder: (context, buider) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: AlertDialog(

              backgroundColor: Theme.of(context).cardColor,
              contentPadding: EdgeInsets.zero ,
              titlePadding: EdgeInsets.symmetric(horizontal: 7),
              insetPadding: EdgeInsets.all(10),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.start,
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
                      Icon(
                        Icons.add_location,
                        color: AppColors.red,
                        size: 70,
                      ),
                    ],
                  ),


                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Select your preferred location mode to attend to the request.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color:Colors.black38,fontSize: 15)),
                  ),
                ],
              ),
              content:  Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 15.0, 15, 15),
                    child: Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          FractionallySizedBox(
                            widthFactor: 0.8,
                            child: RaisedButton(
                              color: AppColors.red,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32.0)),
                              onPressed: ()  {


                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                child: Text('Pick location Automatically',
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
                              onPressed: ()  {


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
              ),
            ),
          );
        },
      );
    }

  Widget useChatFeature(BuildContext context) {
    return StatefulBuilder(
      builder: (context, buider) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            contentPadding: EdgeInsets.zero ,
            titlePadding: EdgeInsets.symmetric(horizontal: 7),
            insetPadding: EdgeInsets.all(10),
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
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
//                    Icon(
//                      Iconsperson,
//                      color: AppColors.red,
//                      size: 70,
//                    ),
                  ],
                ),


                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Sorry, there are no users near your location at this time. Please use our chat feature",
                      textAlign: TextAlign.center,
                      style: TextStyle(color:Colors.black38,fontSize: 15)),
                ),
              ],
            ),
            content:  Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 15.0, 15, 15),
                  child: Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FractionallySizedBox(
                          widthFactor: 0.8,
                          child: RaisedButton(
                            color: AppColors.red,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32.0)),
                            onPressed: ()  {


                            },
                            child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                child: Text('Return to home',
                                    style: TextStyle(color: Colors.white))
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
//                        FractionallySizedBox(
//                          widthFactor: 0.8,
//                          child: RaisedButton(
//                            color: AppColors.white,
//                            shape: RoundedRectangleBorder(
//                                side: BorderSide(width: 1,color: AppColors.red),
//                                borderRadius: BorderRadius.circular(32.0)),
//                            onPressed: ()  {
//
//
//                            },
//                            child: Padding(
//                                padding: const EdgeInsets.symmetric(vertical: 16.0),
//                                child: Text('Set location manually',
//                                    style: TextStyle(color:AppColors.grey))
//                            ),
//                          ),
//                        ),
//                        SizedBox(
//                          height: 15,
//                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(
        children: [
//          Positioned(
//            left: 0,
//            right: 0,
//            child: Padding(
//              padding: const EdgeInsets.symmetric(horizontal: 20.0),
//              child: Container(
//                decoration: BoxDecoration(
//                    color: AppColors.white,
//                    borderRadius: BorderRadius.all(Radius.circular(10))),
//                child: Padding(
//                  padding: const EdgeInsets.fromLTRB(0, 15.0, 15, 15),
//                  child: Expanded(
//                    child: Row(
//                        mainAxisAlignment: MainAxisAlignment.spaceAround,
//                        children: [
//                          Expanded(
//                            child: IconButton(
//                              icon: Icon(Icons.close),
//                              color: AppColors.grey,
//                              onPressed: () {
//                                Navigator.pop(context);
//                              },
//                            ),
//                          ),
//                          Expanded(
//                            child: Icon(
//                              Icons.location_on,
//                              color: AppColors.red,
//                              size: 45,
//                            ),
//                          ),
//                          Column(
//                            mainAxisSize: MainAxisSize.min,
//                            crossAxisAlignment: CrossAxisAlignment.start,
//                            children: [
//                              Text('Your Location',
//                                  style: TextStyle(
//                                      color:
//                                      AppColors.textColor.withOpacity(0.93),
//                                      fontWeight: FontWeight.bold)),
//                              SizedBox(
//                                height: 5,
//                              ),
//                              Text('Hills Avenue NW',
//                                  style: TextStyle(
//                                      color: AppColors.red.withOpacity(0.93),
//                                      fontWeight: FontWeight.normal)),
//                            ],
//                          ),
//                          Expanded(
//                            child: RichText(textAlign: TextAlign.right,
//                              text: TextSpan(
//                                children: [
//                                  TextSpan(
//                                      text: "Edit",
//                                      style: TextStyle(
//                                          color: AppColors.textCaptionColor,
//                                          fontWeight: FontWeight.normal)),
//                                  WidgetSpan(
//                                    child: Padding(
//                                      padding: const EdgeInsets.only(left: 5.0),
//                                      child: Icon(
//                                        Icons.edit_outlined,
//                                        size: 15,
//                                        color: AppColors.red,
//                                      ),
//                                    ),
//                                  ),
//                                ],
//                              ),
//                            ),
//                          ),
//                        ]),
//                  ),
//                ),
//              ),
//            ),
//          ),
          _renderVideo(),
          Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RawMaterialButton(
                  onPressed: this._switchCamera,
                  child: Icon(
                    Icons.camera_alt,
                    color: AppColors.textColor,
                    size: 30.0,
                  ),
                  shape: CircleBorder(),
                  elevation: 2.0,
                  fillColor:  Colors.white,
                  padding: const EdgeInsets.all(15.0),
                ),
                RawMaterialButton(
                  onPressed:this._leaveChannel,
                  child: Icon(
                    Icons.call_end,
                    color: Colors.white,
                    size: 35.0,
                  ),
                  shape: CircleBorder(),
                  elevation: 2.0,
                  fillColor: AppColors.red,
                  padding: const EdgeInsets.all(25.0),
                ),
                RawMaterialButton(
                  onPressed: null,
                  child: Icon(
                    Icons.mic,
                    color: AppColors.white,
                    size: 30.0,
                  ),
                  shape: CircleBorder(),
                  elevation: 2.0,
                  fillColor:
                   AppColors.textCaptionColor.withOpacity(0.68),
                  padding: const EdgeInsets.all(15.0),
                )
              ],
            ),
          ),
          Visibility(
            visible: isFinding,
            child: Positioned(
              top:100,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20.0, 15, 20),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left:15.0),
                            child: SizedBox(height:20,width:20,child: CircularProgressIndicator()),
                          ),
                         SizedBox(width:20),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('reaching the nearest agents.',
                                  style: TextStyle(
                                      color:
                                      AppColors.textColor.withOpacity(0.93),
                                      fontWeight: FontWeight.bold)),
                              SizedBox(
                                height: 5,
                              ),

                            ],
                          ),

                        ]),
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  _renderVideo() {
    return Expanded(
      child: Stack(
        children: [
          RtcLocalView.SurfaceView(),
          Align(
            alignment: Alignment.topLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.of(remoteUid.map(
                  (e) => GestureDetector(
                    onTap: this._switchRender,
                    child: Container(
                      width: 120,
                      height: 120,
                      child: RtcRemoteView.SurfaceView(
                        uid: e,
                      ),
                    ),
                  ),
                )),
              ),
            ),
          )
        ],
      ),
    );
  }
}
