import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:agora_flutter_quickstart/bloc/sign_up/bloc.dart';
import 'package:agora_flutter_quickstart/data/app_colors.dart';
import 'package:agora_flutter_quickstart/data/app_strings.dart';
import '../../repository/user_repository.dart';
import 'package:agora_flutter_quickstart/ui/screens/chat_screen.dart';
import 'package:agora_flutter_quickstart/ui/screens/dashboard_screen.dart';
import 'package:agora_flutter_quickstart/ui/screens/history_screen.dart';
import 'package:agora_flutter_quickstart/ui/screens/location_screen.dart';
import 'package:agora_flutter_quickstart/ui/screens/settings_screen.dart';

import 'chat.dart';
import 'chat_home.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  UserRepository? repository;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool homeSelected = true;
  final Map<int, Widget> _indexToScreenMap = {
    0: IndexedStack(
      //Permet de garder le state des vues même quand on change de vue
      index: 0,
      children: [
        BlocProvider<SignUpBloc>(
                  create: (context) => SignUpBloc(repository: UserRepository()),
                  child: DashboardScreen(),
                ), LocationScreen()],
    ),
    1: HistoryScreen(),
    2: Chat(peerId: "0",),
    3: SettingsScreen()
  };

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
      //  showNotification(message.notification!);
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
      'com.example.video_call_app',
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
    final QuerySnapshot result =
    await FirebaseFirestore.instance.collection('users').where('id', isEqualTo: uid).get();
    final List < DocumentSnapshot > documents = result.docs;
    if (documents.length == 0) {
      // Update data to server if new user
      FirebaseFirestore.instance.collection('users').doc(uid).set(
          {
            'id': uid,
            'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
          }
      );
    }
  }
  @override
  void initState() {
    repository = UserRepository();
    repository!.getCurrentUser().then((value) => {
//      registerUserForChat(value.id),
//      registerNotification(value.id),
//      configLocalNotification()
    });

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:PreferredSize(
        preferredSize: Size.fromHeight(20.0), // here the desired height
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: Text(""),
        ),
      ) ,
      key: _scaffoldKey,
      body: SafeArea(
        child: _indexToScreenMap[_selectedTabIndex]!,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        showUnselectedLabels: true,
        currentIndex: _selectedTabIndex,
        onTap: (newSelection) {
         setState(() {
           homeSelected = newSelection==0;
         });
          if (newSelection != 2) {
            setState(() {
              _selectedTabIndex = newSelection;
            });
          } else {
            showDialog(
                context: context,
                builder: (context) {
                  return categoryAlertDialog(context);
                });

          }
        },
        selectedItemColor: AppColors.red,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
              icon: SvgPicture.asset( "assets/icon_home.svg",color: homeSelected?AppColors.red:Colors.grey,), label: AppStrings.home),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: AppStrings.history),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: AppStrings.chat),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: AppStrings.settings),
        ],
      ),
    );

  }
  Widget categoryAlertDialog(BuildContext context) {
    return StatefulBuilder(
      builder: (context, buider) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            backgroundColor: Theme.of(context).cardColor,
            contentPadding: EdgeInsets.symmetric(horizontal: 5.0),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(AppStrings.selectCategoryTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textColor)),
            ),
            content: SingleChildScrollView(
              child: Container(
                width: double.maxFinite,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            //childAspectRatio: (2 / 1),
                            crossAxisSpacing: 30,
                            mainAxisSpacing: 30,
                            shrinkWrap: true,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: FlatButton(
                                  color: AppColors.textfieldColor,
                                  highlightColor: AppColors.red,
                                  splashColor: AppColors.red,
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => Chat(peerId: "admin",title:"Health")),
                                  ),
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                    SvgPicture.asset("assets/health.svg",color: AppColors.red,),
                                    SizedBox(height: 5,),
                                        Text('Health Care')
                                      ]),
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: FlatButton(
                                  color: AppColors.textfieldColor,
                                  highlightColor: AppColors.red,
                                  splashColor: AppColors.red,
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => Chat(peerId: "admin",title:"Police")),
                                  ),
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset("assets/police.svg",color: Colors.black87,),
                                        SizedBox(height: 10,),
                                        Text('Police')
                                      ]),
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: FlatButton(
                                  color: AppColors.textfieldColor,
                                  highlightColor: AppColors.red,
                                  splashColor: AppColors.red,
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => Chat(peerId: "admin",title:"Fire")),
                                  ),
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset("assets/fire.svg",color: Colors.orangeAccent,),
                                        SizedBox(height: 10,),
                                        Text('Fire')
                                      ]),
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: FlatButton(
                                  color: AppColors.textfieldColor,
                                  highlightColor: AppColors.red,
                                  splashColor: AppColors.red,
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => Chat(peerId: "admin",title:"Accident")),
                                  ),
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset("assets/outline.svg",color: Colors.redAccent,),
                                        SizedBox(height: 10,),
                                        Text('Accident')
                                      ]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.textfieldColor,
                                AppColors.white,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                width: 1.5,
                                color: AppColors.textfieldShadow,
                                style: BorderStyle.none)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('Scroll down to view more',
                                  style: TextStyle(color: AppColors.textColor)),
                              Icon(Icons.keyboard_arrow_down,color: Colors.redAccent,size:50),

                            ],
                          ),
                        ),
                      )
                    ]),
              ),
            ),
          ),
        );
      },
    );
  }
}
