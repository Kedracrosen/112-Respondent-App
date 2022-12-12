import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agora_flutter_quickstart/bloc/sign_up/bloc.dart';
import '../../../repository/user_repository.dart';
import 'package:agora_flutter_quickstart/ui/screens/emr/admin_home_screen.dart';
import 'package:agora_flutter_quickstart/ui/screens/emr/home_screen.dart';
import 'package:agora_flutter_quickstart/ui/screens/welcome_screen.dart';

import 'login.dart';
class EmrSplashScreen extends StatefulWidget {

  @override
  _EmrSplashScreenState createState() => _EmrSplashScreenState();
}

class _EmrSplashScreenState extends State<EmrSplashScreen> {  final splashDelay = 1;
UserRepository? _userRepository;
bool isUserLoggedIn = false;
  @override
  void initState() {
    _userRepository = UserRepository();
    _userRepository!.isEmrLoggedIn().then((value) => {
      setState(() {
        isUserLoggedIn = value;
      }),
    _loadWidget()

    });
    super.initState();

  }

  _loadWidget() async {
    var _duration = Duration(seconds: splashDelay);
    return Timer(_duration, navigationPage);
  }

  void navigationPage() {
    if(!isUserLoggedIn){

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider<SignUpBloc>(
            create: (context) => SignUpBloc(repository: UserRepository()),
            child: LoginEmr(),
          ),
        ),
      );
    }else{
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider<SignUpBloc>(
            create: (context) => SignUpBloc(repository: UserRepository()),
            child: AdminHomeScreen(),
          ),
        ),
      );
    }
  }
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/group194.png'),
              fit: BoxFit.cover),
        ),
        //child: Image.asset('assets/group194.png'),
      ),
    );
  }
}
