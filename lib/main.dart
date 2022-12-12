// @dart=2.9
import 'dart:convert';
import 'dart:io';

import 'package:agora_flutter_quickstart/ui/screens/emr/another_video.dart';
import 'package:agora_flutter_quickstart/utility/global_navigator.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:agora_flutter_quickstart/ui/screens/emr/join_channel_video.dart';
import 'package:agora_flutter_quickstart/ui/screens/emr/splash_screen.dart';
import 'package:agora_flutter_quickstart/ui/screens/splash_screen.dart' ;
import 'package:permission_handler/permission_handler.dart';

import 'bloc/sign_up/bloc.dart';
import 'model/notification_model.dart';
import 'repository/user_repository.dart';
import 'ui/screens/video_call_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase.
  await Firebase.initializeApp();
  runApp(MyApp());
  if (Platform.isAndroid) {
    //Set the navigation bar of the Android head to be transparent
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, //Set transparent globally
        statusBarIconBrightness: Brightness.light
      //light: black icon dark: white icon
      //Set statusBarIconBrightness here as a global setting
    );
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void initState() {
    super.initState();
    OneSignal.shared.setAppId('aece1e0b-b05c-4405-bc3e-4b3d8b6f3e78');

    //in case of iOS --- see below
//     OneSignal.shared.init("your_app_id_here", {
//       OSiOSSettings.autoPrompt: false,
//       OSiOSSettings.inAppLaunchUrl : true
//     });


    OneSignal.shared.disablePush(false);
    //  OneSignal.shared.sendTag("appId", "0bdcV1_punch_flutter");
    //  OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.none);
    OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      // print ("clicked notification" + result.notification.jsonRepresentation());
      //var data = json.decode( result.notification.jsonRepresentation());
      // NotificationModel notif = NotificationModel.fromJson(data);

      print('action' +result.action.actionId);
      try{
        String jsonEncoded = json.encode(result.notification.additionalData);
        print("encoded json"+jsonEncoded);
        var data = json.decode(jsonEncoded);
        a payload = a.fromJson(data);
        if(result.action.actionId=="id2"){
          print('decline was clicked' );
        }else if(result.action.actionId=="id1"){
          print('accept   was clicked' + json.encode(payload));

          onJoin(payload);
        }else{
          print('default was clicked');
        }


      }catch(e){
        print('the error' + e.toString());
      }
    });



  }
  Future<void> onJoin(a notif) async {
    // update input validation
//    setState(() {
//      _channelController.text.isEmpty
//          ? _validateError = true
//          : _validateError = false;
//    });

    // await for camera and mic permissions before pushing video page
    await _handleCameraAndMic(Permission.camera);
    await _handleCameraAndMic(Permission.microphone);

//                                    ),
    // push video page with given channel name
    await    Navigator.of( GlobalVariable.navState.currentContext).push(
        MaterialPageRoute(
          builder: (context) =>
              BlocProvider<SignUpBloc>(
                create: (context) => SignUpBloc(repository: UserRepository()),
                child: CallPage(
                  channelName: notif.channelId,
                  role: ClientRole.Broadcaster,
                  category: notif.name,
                  notif:notif
                ),
              ),)
    );

  }
  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: GlobalVariable.navState,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home:EmrSplashScreen(),
    );
  }
}

