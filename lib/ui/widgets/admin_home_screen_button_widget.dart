import 'package:agora_flutter_quickstart/bloc/sign_up/bloc.dart';
import 'package:agora_flutter_quickstart/repository/user_repository.dart';
import 'package:agora_flutter_quickstart/ui/screens/emr/emergency_screen.dart';
import 'package:agora_flutter_quickstart/ui/screens/emr/settings_screen.dart';
import 'package:agora_flutter_quickstart/ui/screens/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/app_colors.dart';

class AdminHomeScreenButtonWidget extends StatefulWidget {
  final String? buttonText;
  final String? buttonIcon;

  const AdminHomeScreenButtonWidget(
      {Key? key, @required this.buttonText, @required this.buttonIcon})
      : super(key: key);

  @override
  _AdminHomeScreenButtonWidgetState createState() => _AdminHomeScreenButtonWidgetState();
}

class _AdminHomeScreenButtonWidgetState extends State<AdminHomeScreenButtonWidget> {
  @override
  Widget build(BuildContext context) {
    bool select = false;
    return Stack(
      children: [
        FractionallySizedBox(
          widthFactor: 1,heightFactor: 1,
          child: TextButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(select
                    ? AppColors.selectButtonGreyColor
                    : AppColors.textfieldShadow.withOpacity(0.1)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: BorderSide.none))),
            onPressed: () {
              if(widget.buttonText!.toLowerCase().contains('notif')){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider<SignUpBloc>(
                    create: (context) => SignUpBloc(repository: UserRepository()),
                    child: NotificationScreen(),
                  ),
                ),
              );
              }


              if(widget.buttonText!.toLowerCase().contains('emergency')){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider<SignUpBloc>(
                      create: (context) => SignUpBloc(repository: UserRepository()),
                      child: EmergencyScreen(),
                    ),
                  ),
                );
              }
              if(widget.buttonText!.toLowerCase().contains('settings')){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider<SignUpBloc>(
                      create: (context) => SignUpBloc(repository: UserRepository()),
                      child: SettingsScreen(),
                    ),
                  ),
                );
              }
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 30.0, horizontal: 10),
              child: Column(
                children: [
                  Image.asset(
                    widget.buttonIcon!,
                    height: 40,
                    width:40,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Expanded(
                    child: Text(widget.buttonText!,
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
        select
            ? Align(
                alignment: Alignment.topRight,
                child: CircleAvatar(
                  backgroundColor: AppColors.red,
                  radius: 8.0,
                  child: null,
                ),
              )
            : SizedBox.shrink(),
      ],
    );
  }
}
