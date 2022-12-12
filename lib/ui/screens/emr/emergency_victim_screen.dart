import 'dart:io';

import 'package:agora_flutter_quickstart/bloc/sign_up/bloc.dart';
import 'package:agora_flutter_quickstart/bloc/sign_up/event.dart';
import 'package:agora_flutter_quickstart/model/user.dart';
import 'package:agora_flutter_quickstart/repository/user_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:agora_flutter_quickstart/data/app_colors.dart';
import 'package:agora_flutter_quickstart/ui/model/emergency_history_model.dart';

class EmergencyVictimScreen extends StatefulWidget {
  EmergencyVictimScreen({Key? key}) : super(key: key);

  @override
  _EmergencyVictimScreenState createState() => _EmergencyVictimScreenState();
}

class _EmergencyVictimScreenState extends State<EmergencyVictimScreen> {
  //SignUpBloc? _signUpBloc;
  User? currentUser ;
  UserRepository  repository = UserRepository();
  @override
  void initState() {
   // _signUpBloc = BlocProvider.of<SignUpBloc>(context);
    //_signUpBloc!.add(FetchUserDataEvent());
    //  _signUpBloc!.add(FetchUserDataEvent());
    repository.getCurrentUser().then((value) => (){
      setState(() {
        currentUser = value;
      });
    });
    super.initState();
  }
  List<EmergencyHistoryModel> history = [
    EmergencyHistoryModel(
        emergencyTitle: "Health Care",
        time: DateFormat('hh:mm a').format(DateTime.now()),
        date: DateFormat('yMMMMd').format(DateTime.now())),

  ];

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: AppColors.textfieldColor,
        statusBarIconBrightness: Brightness.dark));
    return Scaffold(
      backgroundColor: AppColors.textfieldColor,
      appBar: AppBar(
        toolbarHeight: height / 10.5,
        iconTheme: IconThemeData(
          color: AppColors.grey, //change your color here
        ),
        backgroundColor: AppColors.textfieldColor,
        elevation: 0,
        leading: Icon(Icons.navigate_before),
        title: RichText(
          text: TextSpan(
            children: [
              WidgetSpan(
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child:    Image.asset(
                    'assets/icon_emergency.png',
                    height: 20,
                    width:20,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              TextSpan(
                  text: "Emergency ",
                  style: TextStyle(
                      color: AppColors.deepGrey,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
      body: Container(
          child: Column(
        children: [
          SizedBox(
            height: 0,
          ),
          Center(
            child:     Container(
              margin: EdgeInsets.fromLTRB(0.0, 7.0, 9.0, 0.0),
              child:     ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child:currentUser==null?Container(color: Colors.grey,): Image.file(
                  File(currentUser!.image!),
                  height:60,
                  width: 60,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(currentUser==null?'':'Hello ${currentUser!.firstname}',
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: AppColors.offWhiteColor.withOpacity(0.93),
              )),
          SizedBox(
            height: 20,
          ),
          Text('Ann Rice',
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.deepGrey.withOpacity(0.93),
              )),
          SizedBox(
            height: 30,
          ),
          SingleChildScrollView(
            child: ListView.builder(
              itemCount: history.length,
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 10, bottom: 10),
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Container(
                    color: AppColors.white,
                    padding: EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.circle_outlined,
                              color: history[index].emergencyTitle == 'Fire'
                                  ? AppColors.yellowIconColor
                                  : AppColors.red),
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(history[index].emergencyTitle!,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      AppColors.deepGrey.withOpacity(0.93),
                                )),
                                SizedBox(height:5),
                            Text(history[index].time!,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: AppColors.offWhiteColor
                                      .withOpacity(0.93),
                                )),
                          ],
                        ),
                        Spacer(),
                        Text(history[index].date!,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color:
                                  AppColors.offWhiteColor.withOpacity(0.93),
                            )),
                      ],
                    ));
              },
            ),
          ),
          Expanded(
            child: Container(
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
                    Container(height: 1.5,color: Colors.grey[100],),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width:150,
                          padding: EdgeInsets.only(left: 50),
                          child: Text('Destination',
                              style: TextStyle(
                                  fontSize: 17,
                                  color:
                                  AppColors.textColor,
                                  fontWeight: FontWeight.bold)),
                        ),
                        SvgPicture.asset('assets/demacate_arrow.svg',height: 35,width: 35,color: Colors.grey[100],),
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width:150,
                          padding: EdgeInsets.only(left: 50),
                          child: Text('Victim',
                              style: TextStyle(
                                  fontSize: 17,
                                  color:
                                  AppColors.textColor,
                                  fontWeight: FontWeight.bold)),
                        ),
                        SvgPicture.asset('assets/demacate_arrow.svg',height: 35,width: 35,color: Colors.grey[100],),
                        Text('Ann Rice',
                            style: TextStyle(
                              fontSize: 13,
                              color:
                              AppColors.textColor.withOpacity(0.93),
                            )),
                      ],
                    ),
                    Container(height: 1.5,color: Colors.grey[100],),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width:150,
                          padding: EdgeInsets.only(left: 50),
                          child: Text('Rescue time',
                              style: TextStyle(
                                  fontSize: 17,
                                  color:
                                  AppColors.textColor,
                                  fontWeight: FontWeight.bold)),
                        ),
                        SvgPicture.asset('assets/demacate_arrow.svg',height: 35,width: 35,color: Colors.grey[100],),
                        Text('-----',
                            style: TextStyle(
                              fontSize: 13,
                              color:
                              AppColors.textColor.withOpacity(0.93),
                            )),
                      ],
                    ),
                    Container(height: 1.5,color: Colors.grey[100],),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width:150,
                          padding: EdgeInsets.only(left: 50),
                          child: Text('Medium',
                              style: TextStyle(
                                  fontSize: 17,
                                  color:
                                  AppColors.textColor,
                                  fontWeight: FontWeight.bold)),
                        ),
                        SvgPicture.asset('assets/demacate_arrow.svg',height: 35,width: 35,color: Colors.grey[100],),
                        Text('Video Call',
                            style: TextStyle(
                              fontSize: 13,
                              color:
                              AppColors.textColor.withOpacity(0.93),
                            )),
                      ],
                    ),
                    Container(height: 1.5,color: Colors.grey[100],),
                    SizedBox(
                      height: 100.0,
                    ),
                    FractionallySizedBox(
                      widthFactor: 0.8,
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all<Color>(AppColors.red),
                            shadowColor: MaterialStateProperty.all<Color>(
                                AppColors.redShadow),
                            shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                    side: BorderSide(color: AppColors.red)))),
                        onPressed: () async {},
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text('Add Report',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                  ],

                ),
              ),
            ),
          ),
        ],
      )),
    );
  }
}
