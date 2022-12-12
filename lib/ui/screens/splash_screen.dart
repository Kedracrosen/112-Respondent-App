import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agora_flutter_quickstart/bloc/sign_up/bloc.dart';
import '../../repository/user_repository.dart';
import 'package:agora_flutter_quickstart/ui/screens/home_screen.dart';
import 'package:agora_flutter_quickstart/ui/screens/enter_phone_screen.dart';
import 'package:agora_flutter_quickstart/ui/screens/welcome_screen.dart';
class SplashScreen extends StatefulWidget {

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {  final splashDelay = 1;
UserRepository? _userRepository;
bool isUserLoggedIn = false;
  @override
  void initState() {
    _userRepository = UserRepository();
    _userRepository!.isLoggedIn().then((value) => {
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
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => WelcomeScreen()));
    }else{
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider<SignUpBloc>(
            create: (context) => SignUpBloc(repository: UserRepository()),
            child: HomeScreen(),
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
