import 'dart:async';
import 'dart:ui';

import 'package:agora_flutter_quickstart/bloc/sign_up/bloc.dart';
import 'package:agora_flutter_quickstart/bloc/sign_up/event.dart';
import 'package:agora_flutter_quickstart/data/app_colors.dart';
import 'package:agora_flutter_quickstart/model/notification_model.dart';
import 'package:agora_flutter_quickstart/repository/user_repository.dart';
import 'package:agora_flutter_quickstart/ui/screens/emr/emr_location_screen.dart';
import 'package:agora_flutter_quickstart/ui/screens/emr/home_screen.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import '../../config/agora.config.dart' as config;
import 'package:geocoder/geocoder.dart' as GeoCoder;

import 'admin_home_screen.dart';



class CallPage extends StatefulWidget {
  /// non-modifiable channel name of the page
  final String? channelName;
  final a? notif;
  /// non-modifiable client role of the page
  final ClientRole? role;
  final  String? category;

  /// Creates a call page with given channel name.
  const CallPage({Key? key, this.channelName, this.role,this.category,this.notif}) : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  late RtcEngine _engine;
  UserRepository? userRepository ;

  StreamSubscription? _locationSubsription;
  Location location = new Location();
  Location _locationTracker = Location();

  bool? _serviceEnabled;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;

  // this keeps the state of the finding agents loader
  bool isFinding = true;
  SignUpBloc? _signUpBloc;

  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    _engine.leaveChannel();
    _engine.destroy();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    initialize();
    _signUpBloc = BlocProvider.of<SignUpBloc>(context);


    userRepository = UserRepository();
    // get the user_id and join channel
    userRepository!.getCurrentUser().then((value) => {

     // _getCurrentLocation(),
    });
  }
// Init firestore and geoFlutterFire
  final geo = Geoflutterfire();
  final _firestore = FirebaseFirestore.instance;


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


  }

  Future<void> initialize() async {
    if (config.appId.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await _engine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(height:1920, width:1080);
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(null, widget.channelName!, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(config.appId);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(widget.role!);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(error: (code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    }, joinChannelSuccess: (channel, uid, elapsed) {
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
        _infoStrings.add(info);
      });
    }, leaveChannel: (stats) {
      setState(() {
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      });
    }, userJoined: (uid, elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        _infoStrings.add(info);
        _users.add(uid);
      });
    }, userOffline: (uid, elapsed) {
      setState(() {
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
        _users.remove(uid);
      });
    }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    }));
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    if (widget.role == ClientRole.Broadcaster) {
      list.add(RtcLocalView.SurfaceView());
    }
    _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
              children: <Widget>[_videoView(views[0])],
            ));
      case 2:
        return Container(
            child: Column(
              children: <Widget>[
                _expandedVideoRow([views[0]]),
                _expandedVideoRow([views[1]])
              ],
            ));
      case 3:
        return Container(
            child: Column(
              children: <Widget>[
                _expandedVideoRow(views.sublist(0, 2)),
                _expandedVideoRow(views.sublist(2, 3))
              ],
            ));
      case 4:
        return Container(
            child: Column(
              children: <Widget>[
                _expandedVideoRow(views.sublist(0, 2)),
                _expandedVideoRow(views.sublist(2, 4))
              ],
            ));
      default:
    }
    return Container();
  }

  /// Toolbar layout
  Widget _toolbar() {
    if (widget.role == ClientRole.Audience) return Container();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
          onPressed: _onSwitchCamera,
          child: Icon(
            Icons.switch_camera,
            color: Colors.grey,
            size: 20.0,
          ),
          shape: CircleBorder(),
          elevation: 2.0,
          fillColor: Colors.white,
          padding: const EdgeInsets.all(12.0),
        ),

          RawMaterialButton(
            onPressed: () async =>  _onCallEnd(context),
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.grey,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.grey : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
        ],
      ),
    );
  }

  /// Info panel to show logs
  Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.isEmpty) {
                return Text("null");  // return type can't be null, a widget was required
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _infoStrings[index],
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onCallEnd (BuildContext context) async{
   await showDialog(
        context: context,
        builder: (context) {
          return chooseLocationDialog(context);
        });
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: <Widget>[

            _viewRows(),
            _panel(),
            _toolbar(),
            Container(
              padding: EdgeInsets.only(top:80,left:50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '- ${widget.category}',
                    style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 35),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
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
                              Navigator.pop(context);
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => EmrLocationScreen(notif:widget.notif!)),
                              );

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

  Widget chooseAction(BuildContext context) {
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

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Choose an action.",
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
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (c) => AdminHomeScreen()),
                                      (route) => false);

                            },
                            child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                child: Text('End call',
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
                              Navigator.pop(context);
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return chooseAction(context);
                                  });
                            },
                            child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                child: Text('End and start journey',
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


}