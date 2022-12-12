import 'dart:io';

import 'package:agora_flutter_quickstart/bloc/sign_up/bloc.dart';
import 'package:agora_flutter_quickstart/bloc/sign_up/event.dart';
import 'package:agora_flutter_quickstart/model/user.dart';
import 'package:agora_flutter_quickstart/repository/user_repository.dart';
import 'package:agora_flutter_quickstart/ui/screens/emr/emergency_victim_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:agora_flutter_quickstart/data/app_colors.dart';
import 'package:agora_flutter_quickstart/ui/model/emergency_history_model.dart';

class EmergencyScreen extends StatefulWidget {
  EmergencyScreen({Key? key}) : super(key: key);

  @override
  _EmergencyScreenState createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  //SignUpBloc? _signUpBloc;
 // User? currentUser ;
  //UserRepository  repository = UserRepository();
//  @override
//  void initState() {
//   // _signUpBloc = BlocProvider.of<SignUpBloc>(context);
//    //_signUpBloc!.add(FetchUserDataEvent());
//    //  _signUpBloc!.add(FetchUserDataEvent());
//    repository.getCurrentUser().then((value) => (){
//      setState(() {
//        currentUser = value;
//      });
//    });
//    super.initState();
//  }
  List<EmergencyHistoryModel> history = [
    EmergencyHistoryModel(
        emergencyTitle: "Health Care",
        time: DateFormat('hh:mm a').format(DateTime.now()),
        date: DateFormat('yMMMMd').format(DateTime.now())),
    EmergencyHistoryModel(
        emergencyTitle: "Fire",
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
          SingleChildScrollView(
            child: ListView.builder(
              itemCount: history.length,
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 10, bottom: 10),
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap:(){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider<SignUpBloc>(
                          create: (context) => SignUpBloc(repository: UserRepository()),
                          child: EmergencyVictimScreen(),
                        ),
                      ),
                    );
                  },
                  child: Container(
                      color: AppColors.white,
                      margin: EdgeInsets.only(bottom: 2),
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
                      )),
                );
              },
            ),
          )
        ],
      )),
    );
  }
}
