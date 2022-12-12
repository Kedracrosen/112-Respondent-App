import 'dart:io';
import 'dart:ui';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_flutter_quickstart/bloc/sign_up/bloc.dart';
import 'package:agora_flutter_quickstart/bloc/sign_up/event.dart';
import 'package:agora_flutter_quickstart/bloc/sign_up/state.dart';
import 'package:agora_flutter_quickstart/data/app_colors.dart';
import 'package:agora_flutter_quickstart/data/app_strings.dart';
import 'package:agora_flutter_quickstart/model/user.dart';
import '../../repository/user_repository.dart';
import 'package:agora_flutter_quickstart/ui/basic/another_video.dart';
import 'package:agora_flutter_quickstart/ui/basic/join_channel_video.dart';
import 'package:agora_flutter_quickstart/ui/screens/edit_profile_screen.dart';
import 'package:agora_flutter_quickstart/ui/screens/location_screen.dart';
import 'package:agora_flutter_quickstart/ui/screens/video_call_screen.dart';
import 'package:agora_flutter_quickstart/ui/screens/voice_call_screen.dart';

import 'my_location_screen.dart';

class DashboardScreen extends StatefulWidget {
  DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Map> allergiesList = [];
  SignUpBloc? _signUpBloc;
  User? currentUser;
  String? height='',age='',blood='',weight='',date='YYYY-MM-DD',allergies='';
  UserRepository  repository = UserRepository();
  var address='not set';
  @override
  void initState() {
    _signUpBloc = BlocProvider.of<SignUpBloc>(context);
    _signUpBloc!.add(FetchUserDataEvent());
    //  _signUpBloc!.add(FetchUserDataEvent());
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      body:BlocListener<SignUpBloc, SignUpState>(
        listener: (context, state) {
          if (state is PostingState) {
          } else if (state is PostingError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.error!,
                  style: TextStyle(color: Colors.black87)),
              backgroundColor: Colors.white,
            ));

          } else if (state is PostedSuccess) {

            setState(() {
              currentUser=state.user;
            });

          } else {
          }
        }, child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal:8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(children: [
                  InkWell(
                    onTap: () => _userProfileDialog(context),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(0.0, 7.0, 9.0, 0.0),
                          child:     ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child:currentUser==null?Container(): Image.file(
                              File(currentUser!.image!),
                              height:60,
                              width: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (
                                  BuildContext? context,
                                  Object? error,
                                  StackTrace? stackTrace,
                                  ) {
                                return Container(
                                  color: Colors.grey,
                                  width: 60,
                                  height: 60,
                                  child: const Center(
                                    child: const Text('no image', textAlign: TextAlign.center),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: CircleAvatar(
                            backgroundColor: AppColors.red,
                            radius: 8.0,
                            child: null,
                          ),
                        ),
                      ],
                    ),
                  ),
          BlocBuilder<SignUpBloc, SignUpState>(
              builder: (context, state) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // only show this text if the user has been fetched
                             state is PostedSuccess?
                              Text("Hello " +currentUser!.firstname! +"!",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textColor,
                                      fontSize: 14)):
                              SizedBox(height: 20,width:20,child: CircularProgressIndicator(),),


                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // if the user has been fetched
                                  state is PostedSuccess?Text(
                                    currentUser!.registrationStatus!=null? 'profile '+ currentUser!.registrationStatus! :'',
                                    style: TextStyle(
                                        color: AppColors.red, fontSize: 14),
                                  ):Text(''),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: address,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textColor,
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
                                ],
                              ),
                            ]),
                      ),
                    );
  })
                ]),
              ),
              SizedBox(height: height * 0.03),
              ButtonTheme(
                  minWidth: 25.0,
                  //height: 44.0,
                  child: OutlineButton(
                      borderSide: BorderSide(color: AppColors.red),
                      textColor: Colors.blue,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text('See your location',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.textColor,
                                fontWeight: FontWeight.normal)),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      onPressed: () async {
                        Map result = await  Navigator.push(context, MaterialPageRoute(
                            builder: (context) => MyLocationScreen()
                        ));
                        if (result != null && result.containsKey('address')) {
                          setState(() {
                            address = result['address'];
                          });
                        }
                                })),
              SizedBox(height: height * 0.04),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text('Emergency help \n needed?',
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textCaptionColor,
                    )),
              ),
              Text('Just tap the button to call',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textColor, fontSize: 14)),
              SizedBox(height: height * 0.04),
              Align(
                alignment: Alignment.bottomCenter,
                child: InkWell(
                  onTap: () => showDialog(
                      context: context,
                      builder: (context) {
                        return categoryAlertDialog(context);
                      }),
                  child: Image.asset(
                      "assets/icon_call.png",
                      height: 250,
                      width: 250,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ),
    );
  }
  Future<void> onJoin(String text) async {
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
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
        BlocProvider<SignUpBloc>(
            create: (context) => SignUpBloc(repository: UserRepository()),
            child: CallPage(
            channelName: 'chanz'+currentUser!.id.toString(),
            role: ClientRole.Broadcaster,
            category: text,
          ),
        ),)
      );

  }
  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
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
                                  onPressed: () => showDialog(
                                      context: context,
                                      builder: (context) {
                                        return selectCallModeAlertDialog(context,"Health","assets/health.svg");
                                      }),
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset("assets/health.svg",color: AppColors.red,),
                                        SizedBox(height: 5,),
                                        Text('Health Care',style: TextStyle(color: Colors.black54),)
                                      ]),
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: FlatButton(
                                  color: AppColors.textfieldColor,
                                  highlightColor: AppColors.red,
                                  splashColor: AppColors.red,
                                  onPressed: () => showDialog(
                                      context: context,
                                      builder: (context) {
                                        return selectCallModeAlertDialog(context,"Police","assets/police.svg");
                                      }),
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset("assets/police.svg",color: Colors.black87,),
                                        SizedBox(height: 10,),
                                        Text('Police',style: TextStyle(color: Colors.black54),)
                                      ]),
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: FlatButton(
                                  color: AppColors.textfieldColor,
                                  highlightColor: AppColors.red,
                                  splashColor: AppColors.red,
                                  onPressed: () => showDialog(
                                      context: context,
                                      builder: (context) {
                                        return selectCallModeAlertDialog(context,"Fire","assets/fire.svg");
                                      }),
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset("assets/fire.svg",color: Colors.orangeAccent,),
                                        SizedBox(height: 10,),
                                        Text('Fire',style: TextStyle(color: Colors.black54),)
                                      ]),
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: FlatButton(
                                  color: AppColors.textfieldColor,
                                  highlightColor: AppColors.red,
                                  splashColor: AppColors.red,
                                  onPressed: () => showDialog(
                                      context: context,
                                      builder: (context) {
                                        return selectCallModeAlertDialog(context,"Accident","assets/outline.svg");
                                      }),
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset("assets/outline.svg",color: Colors.redAccent,),
                                        SizedBox(height: 10,),
                                        Text('Accident',style: TextStyle(color: Colors.black54),)
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
                            SizedBox(height: 10,),
                            SvgPicture.asset('assets/swipe_arrow.svg',width: 30,height: 30,color: Colors.red,),

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

  Widget selectCallModeAlertDialog(BuildContext context,String text,String iconPath) {
    return StatefulBuilder(
      builder: (context, buider) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            backgroundColor: Theme.of(context).cardColor,
            contentPadding: EdgeInsets.symmetric(horizontal: 5.0),
            content: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox.fromSize(
                      size: Size(120, 120), // button width and height
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: FlatButton(
                          color: AppColors.red,
                          highlightColor: AppColors.red,
                          splashColor: AppColors.red,
                          onPressed: () {},
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  iconPath,
                                  color: AppColors.white,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  text,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.white,
                                      fontWeight: FontWeight.normal),
                                )
                              ]),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text('Select Call Mode',
                      style: TextStyle(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 40,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox.fromSize(
                        size: Size(100, 100), // button width and height
                        child: ClipOval(
                          child: Material(
                            color: AppColors.textfieldColor, // button color
                            child: InkWell(
                              splashColor: AppColors.red, // splash color
                              onTap: () {
                                  onJoin(text);
//                                Navigator.push(
//                                  context,
//                                  MaterialPageRoute(
//                                    builder: (context) => BlocProvider<SignUpBloc>(
//                                      create: (context) => SignUpBloc(repository: UserRepository()),
//                                      child: JoinChannelVideo(category: text,),
//                                    ),
//                                  ),
//                                );

                              }, // button pressed
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.video_call), // icon
                                  Text(
                                    "Video Call",
                                    style: TextStyle(fontSize: 10),
                                  ), // text
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox.fromSize(
                        size: Size(100, 100), // button width and height
                        child: ClipOval(
                          child: Material(
                            color: AppColors.textfieldColor, // button color
                            child: InkWell(
                              splashColor: AppColors.red, // splash color
                              onTap: () {
                                Navigator.of(context).push(PageRouteBuilder(
                                    fullscreenDialog: true,
                                    opaque: false,
                                    pageBuilder:
                                        (BuildContext context, _, __) =>
                                            VoiceCallScreen()));
                              }, // button pressed
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.call), // icon
                                  Text(
                                    "Voice Call",
                                    style: TextStyle(fontSize: 10),
                                  ), // text
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 50),
                ]),
          ),
        );
      },
    );
  }

  void _userProfileDialog(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        builder: (BuildContext context) {
          double modalBottomSheetHeight = 0.80;
          return DraggableScrollableSheet(
              initialChildSize: modalBottomSheetHeight, //set this as you want
              maxChildSize: modalBottomSheetHeight, //set this as you want
              minChildSize: modalBottomSheetHeight, //set this as you want
              expand: true,
              builder: (context, scrollController) {
                final double closeButtonheight = 40;
                final double closeButtonwidth = 100;
                return Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: (MediaQuery.of(context).size.height *
                                modalBottomSheetHeight) -
                            (closeButtonheight / 2),
                        color: AppColors.white,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18.0),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 50,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: Column(children: [
                                        Text('Profile Data:',
                                            style: TextStyle(
                                                color:
                                                    AppColors.textCaptionColor,
                                                fontWeight: FontWeight.normal)),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              WidgetSpan(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10.0),
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        AppColors.red,
                                                    radius: 8.0,
                                                    child: null,
                                                  ),
                                                ),
                                              ),
                                              TextSpan(
                                                  text: "60% ",
                                                  style: TextStyle(
                                                      color: AppColors
                                                          .textCaptionColor,
                                                      fontWeight:
                                                          FontWeight.normal)),
                                            ],
                                          ),
                                        ),
                                      ]),
                                    ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(currentUser!.image!),
                                height:70,
                                width: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (
                                    BuildContext? context,
                                    Object? error,
                                    StackTrace? stackTrace,
                                    ) {
                                  return Container(
                                    color: Colors.grey,
                                    width: 70,
                                    height: 70,
                                    child: const Center(
                                      child: const Text('no image', textAlign: TextAlign.center),
                                    ),
                                  );
                                },
                              ),
                            ),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                                                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BlocProvider<SignUpBloc>(
                                      create: (context) => SignUpBloc(repository: UserRepository()),
                                      child:  EditProfileScreen(),
                                    ),
                                  ),
                                );

                                        },
                                        child: Center(
                                          child: RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                    text: "Edit",
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .textCaptionColor,
                                                        fontWeight:
                                                            FontWeight.normal)),
                                                WidgetSpan(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 5.0),
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
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(currentUser!.firstname!+' '+currentUser!.lastname!,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 27,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          AppColors.deepGrey.withOpacity(0.93),
                                    )),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(currentUser!.dob!,
                                    style: TextStyle(
                                        color: AppColors.textCaptionColor,
                                        fontWeight: FontWeight.normal)),
                                SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Container(
                                    color: AppColors.grey.withOpacity(0.2),
                                    child: GridView(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 1.0),
                                      shrinkWrap: true,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisSpacing: 1,
                                              mainAxisSpacing: 1,
                                              crossAxisCount: 2,
                                              childAspectRatio: 1.5),
                                      children: <Widget>[
                                        InkWell(
                                          onTap: () {},
                                          child: Container(
                                            color: AppColors.white,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10.0),
                                              child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text('Age:',
                                                              style: TextStyle(
                                                                  color: AppColors
                                                                      .textCaptionColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal)),
                                                          RichText(
                                                            text: TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                    text: "26",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          27,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: AppColors
                                                                          .deepGrey
                                                                          .withOpacity(
                                                                              0.93),
                                                                    )),
                                                                WidgetSpan(
                                                                    child:
                                                                        SizedBox(
                                                                  width: 5,
                                                                )),
                                                                TextSpan(
                                                                    text:
                                                                        "years",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: AppColors
                                                                          .deepGrey
                                                                          .withOpacity(
                                                                              0.93),
                                                                    )),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Icon(
                                                        Icons
                                                            .calendar_today_outlined,
                                                        color: AppColors
                                                            .blueIconColor,
                                                        size: 27,
                                                      ),
                                                    )
                                                  ]),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {},
                                          child: Container(
                                            color: AppColors.white,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10.0),
                                              child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text('Blood type:',
                                                              style: TextStyle(
                                                                  color: AppColors
                                                                      .textCaptionColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal)),
                                                          SizedBox(height: 5),
                                                          RichText(
                                                            text: TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                    text: currentUser!.bloodType!,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          27,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: AppColors
                                                                          .deepGrey
                                                                          .withOpacity(
                                                                              0.93),
                                                                    )),
                                                                WidgetSpan(
                                                                    child:
                                                                        SizedBox(
                                                                  width: 5,
                                                                )),
                                                                TextSpan(
                                                                    text: "+",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: AppColors
                                                                          .deepGrey
                                                                          .withOpacity(
                                                                              0.93),
                                                                    )),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: SvgPicture.asset(
                                                       'assets/blood-drop.svg',
                                                        color: AppColors
                                                            .redIconColor,
                                                        width: 27,
                                                      ),
                                                    )
                                                  ]),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {},
                                          child: Container(
                                            color: AppColors.white,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10.0),
                                              child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text('Height:',
                                                              style: TextStyle(
                                                                  color: AppColors
                                                                      .textCaptionColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal)),
                                                          SizedBox(height: 5),
                                                          RichText(
                                                            text: TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                    text: currentUser!.height!,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          27,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: AppColors
                                                                          .deepGrey
                                                                          .withOpacity(
                                                                              0.93),
                                                                    )),
                                                                WidgetSpan(
                                                                    child:
                                                                        SizedBox(
                                                                  width: 5,
                                                                )),
                                                                TextSpan(
                                                                    text: "cm",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: AppColors
                                                                          .deepGrey
                                                                          .withOpacity(
                                                                              0.93),
                                                                    )),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: SvgPicture.asset(
                                                        'assets/height.svg',
                                                        color: AppColors
                                                            .yellowIconColor,
                                                        width: 27,
                                                      ),
                                                    )
                                                  ]),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {},
                                          child: Container(
                                            color: AppColors.white,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10.0),
                                              child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text('Weight:',
                                                              style: TextStyle(
                                                                  color: AppColors
                                                                      .textCaptionColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal)),
                                                          SizedBox(height: 5),
                                                          RichText(
                                                            text: TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                    text: currentUser!.weight!,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          27,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: AppColors
                                                                          .deepGrey
                                                                          .withOpacity(
                                                                              0.93),
                                                                    )),
                                                                WidgetSpan(
                                                                    child:
                                                                        SizedBox(
                                                                  width: 5,
                                                                )),
                                                                TextSpan(
                                                                    text: "kg",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: AppColors
                                                                          .deepGrey
                                                                          .withOpacity(
                                                                              0.93),
                                                                    )),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: SvgPicture.asset(
                                                        'assets/weight-scale.svg',
                                                        color: AppColors
                                                            .skyBlueIconColor,
                                                        width: 27,
                                                      ),
                                                    )
                                                  ]),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text('Allergies',
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          AppColors.deepGrey.withOpacity(0.93),
                                    )),

                                // Container(
                                //   child: GridView.builder(
                                //     itemCount: allergiesList.length,
                                //     gridDelegate:
                                //         SliverGridDelegateWithFixedCrossAxisCount(
                                //       crossAxisCount:
                                //           MediaQuery.of(context).orientation ==
                                //                   Orientation.landscape
                                //               ? 3
                                //               : 2,
                                //       crossAxisSpacing: 1,
                                //       mainAxisSpacing: 1,
                                //       childAspectRatio: (2 / 1),
                                //     ),
                                //     itemBuilder: (
                                //       context,
                                //       index,
                                //     ) {
                                //       return GestureDetector(
                                //         onTap: () {},
                                //         child: Container(
                                //           color: AppColors.white,
                                //           child: Column(
                                //             mainAxisAlignment:
                                //                 MainAxisAlignment.spaceEvenly,
                                //             children: [
                                //               Text('Grape',
                                //                   maxLines: 2,
                                //                   textAlign: TextAlign.center,
                                //                   style: TextStyle(
                                //                     fontSize: 14,
                                //                     fontWeight: FontWeight.bold,
                                //                     color: AppColors.deepGrey
                                //                         .withOpacity(0.93),
                                //                   )),
                                //             ],
                                //           ),
                                //         ),
                                //       );
                                //     },
                                //   ),
                                // )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                          decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          height: closeButtonheight,
                          width: closeButtonwidth,
                          child: IconButton(
                            icon: Icon(Icons.close),
                            color: AppColors.grey,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          )),
                    ),
                  ],
                ); //whatever you're returning, does not have to be a Container
              });
        });
  }
}
