import 'package:agora_flutter_quickstart/bloc/sign_up/bloc.dart';
import 'package:agora_flutter_quickstart/ui/screens/notification_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:agora_flutter_quickstart/data/app_colors.dart';
import 'package:agora_flutter_quickstart/data/app_strings.dart';
import '../../../repository/user_repository.dart';
import 'package:agora_flutter_quickstart/ui/widgets/admin_home_screen_button_widget.dart';

class AdminHomeScreen extends StatefulWidget {
  AdminHomeScreen({Key? key}) : super(key: key);

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  UserRepository? repository;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// Init firestore and geoFlutterFire
  final geo = Geoflutterfire();
  final _firestore = FirebaseFirestore.instance;
  Location location = new Location();
  Location _locationTracker = Location();
  UserRepository rep = UserRepository();

  bool? _serviceEnabled;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;

  var isUnAvailable=false;


  void registerNotification(currentUserId) {
    firebaseMessaging.requestPermission();

//    firebaseMessaging.(onMessage: (Map<String, dynamic> message) {
//      print('onMessage: $message');
//      Platform.isAndroid
//          ? showNotification(message['notification'])
//          : showNotification(message['aps']['alert']);
//      return;
//    }, onResume: (Map<String, dynamic> message) {
//      print('onResume: $message');
//      return;
//    }, onLaunch: (Map<String, dynamic> message) {
//      print('onLaunch: $message');
//      return;
//    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('onMessage: '+message.notification!.title!);
      if (message.notification != null) {
        showNotification(message.notification!);
      }
      return;
    });

    firebaseMessaging.getToken().then((token) {
      print('token: $token');
      FirebaseFirestore.instance.collection('users').doc(currentUserId).update({'pushToken': token});
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }

  void configLocalNotification() {
    AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings();
    InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(RemoteNotification remoteNotification) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'com.example.flutterchatdemo',
      '112',
      'Emergency App',
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );
    IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

    print(remoteNotification);

    await flutterLocalNotificationsPlugin.show(
      0,
      remoteNotification.title,
      remoteNotification.body,
      platformChannelSpecifics,
      payload: null,
    );
  }


  int _selectedTabIndex = 0;
  void registerUserForChat(uid) async{
    //   final QuerySnapshot result =
//    await FirebaseFirestore.instance.collection('users').where('id', isEqualTo: uid).get();
//    final List < DocumentSnapshot > documents = result.docs;
//    if (documents.length == 0) {
//      // Update data to server if new user
//      FirebaseFirestore.instance.collection('users').doc(uid).set(
//          {
//            'id': uid,
//            'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
//          }
//      );
//    }
  }
  @override
  void initState() {
    repository = UserRepository();
    repository!.getCurrentUser().then((value) => {
      _getCurrentLocation(value.id,value.firstname! + " " +value.lastname!),
     // registerUserForChat(value.id),
     // registerNotification(value.id),
    //  configLocalNotification()
    });

    super.initState();
  }

  void _getCurrentLocation(user_id,name) async {
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
    print('got tos ave part');
    saveMyLocation(_locationData!.latitude, _locationData!.longitude,user_id,name);

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


  void saveMyLocation(mylat,mylng,user_id,name){

    GeoFirePoint myLocation = geo.point(latitude: mylat, longitude: mylng);
    // save update useer long and lat
    print('got to referece'+mylat.toString());
    var documentReference = FirebaseFirestore.instance
        .collection('locations')
        .doc("agent_"+user_id.toString());
   print(name);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        documentReference,
        {'id':user_id,'role':'emr','name':name,'lat':mylat,'long':mylng, 'position': myLocation.data},
      );
    });

  }


  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar:PreferredSize(
            preferredSize: Size.fromHeight(20.0), // here the desired height
            child: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              leading: Text(""),
            ),
        ) ,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal:20.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: (){
                              rep.signOut();
                            },
                            child: Text('Good\nMorning',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textColor,
                                    fontSize: 15)),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: Image.asset(
                              'assets/logo.png',
                            ),
                            height: 66.29,
                            width: 66.29,
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Atlanta ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textColor
                                            .withOpacity(0.93),
                                        fontSize: 14),
                                  ),
                                  WidgetSpan(
                                    child: Icon(
                                      Icons.place,
                                      color: AppColors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ]),
                ),
                SizedBox(height: 20),
                GridView(
                  padding: EdgeInsets.symmetric(vertical: 1.0),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: 17,
                      mainAxisSpacing: 15,
                      crossAxisCount: 3,
                      childAspectRatio: 0.7),
                  children: <Widget>[
                    AdminHomeScreenButtonWidget(buttonText: "Admin Chat", buttonIcon: "assets/icon_chat.png",),
                    AdminHomeScreenButtonWidget(buttonText: "Emergency",buttonIcon: "assets/icon_emergency.png"),
                    FractionallySizedBox(
                      widthFactor: 1,heightFactor: 1,
                      child: TextButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(isUnAvailable
                                ? AppColors.selectButtonGreyColor
                                : AppColors.textfieldShadow.withOpacity(0.1)),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    side: BorderSide.none))),
                        onPressed: () {
                          setState(() {
                            isUnAvailable = !isUnAvailable;
                          });
                        },
                        child: Padding(
                          padding:
                          const EdgeInsets.symmetric(vertical: 30.0, horizontal: 10),
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/icon_user.png",
                                height: 40,
                                width:40,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Expanded(
                                child: Text(isUnAvailable==true?'Not Available':'Available',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: AppColors.textColor.withOpacity(0.5),
                                        fontSize: 11,
                                        height: 15 / 11)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    AdminHomeScreenButtonWidget(buttonText: "Notifications", buttonIcon: "assets/icon_notifications.png",
                     ),
                    AdminHomeScreenButtonWidget(buttonText: "Settings", buttonIcon: "assets/icon_settings.png",),
                    AdminHomeScreenButtonWidget(buttonText: "Upgrade", buttonIcon: "assets/icon_upgrade.png",),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ));
//        bottomNavigationBar: Container(
//          height: height * 0.1,
//          color: AppColors.textfieldColor,
//          child: Column(
//            children: [
//              Container(
//                height: 6,
//                width: 53,
//                    decoration: BoxDecoration(
//                      borderRadius: BorderRadius.circular(30),
//                      color: AppColors.red,
//                    ),
//                alignment: Alignment.topCenter,
//              ),
//              SizedBox(height: 5,),
//              Icon(
//                Icons.home_outlined,
//                color: AppColors.red,
//              ),
//              Text(
//                AppStrings.home,
//                style: TextStyle(
//                    color: AppColors.textColor.withOpacity(0.5),
//                    fontSize: 13,
//                    height: 17 / 13),
//              )
//            ],
//          ),
//        ));
  }

}
