import 'dart:io';

import 'package:agora_flutter_quickstart/bloc/sign_up/bloc.dart';
import 'package:agora_flutter_quickstart/bloc/sign_up/event.dart';
import 'package:agora_flutter_quickstart/model/user.dart';
import 'package:agora_flutter_quickstart/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:agora_flutter_quickstart/data/app_colors.dart';
import 'package:agora_flutter_quickstart/ui/model/emergency_history_model.dart';

class HistoryScreen extends StatefulWidget {
  HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
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
        toolbarHeight: height / 6.5,
        iconTheme: IconThemeData(
          color: AppColors.grey, //change your color here
        ),
        backgroundColor: AppColors.textfieldColor,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.navigate_before, size: 30, // add custom icons also
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
          Text('EMERGENCY HISTORY',
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
                    ));
              },
            ),
          )
        ],
      )),
    );
  }
}
