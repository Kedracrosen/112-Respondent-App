import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agora_flutter_quickstart/bloc/sign_up/bloc.dart';
import 'package:agora_flutter_quickstart/data/app_colors.dart';
import '../../repository/user_repository.dart';
import 'package:agora_flutter_quickstart/ui/screens/enter_phone_screen.dart';

// This class holds the information to be displayed in each of the welcome screens

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  PageController? _pageController;
  int currentIndex = 0;

  int i = 0;
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController!.dispose();
    super.dispose();
  }

  void onChangedFunction(int newIndex) {
    setState(() {
      currentIndex = newIndex;
    });
  }

  void _navigateToNextScreen() {
    // pushAndRemoveUntil is used here, to clear the entire Navigation stack after onboarding
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => EnterPhoneScreen(),
        ),
        (Route<dynamic> route) => false);
  }

  bool isCurrentPageLast() {
    bool isCurrentPageLast = currentIndex == 2;

    return isCurrentPageLast;
  }

  void handleButtonTap() {
    if (isCurrentPageLast()) {
      _navigateToNextScreen();
    } else {
      int nextPage = currentIndex + 1;

      _pageController!.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void handlePageSwipe({@required int? newIndex}) => onChangedFunction(newIndex!);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    Expanded(
                      child: PageView(
                        onPageChanged: (int i) {
                          handlePageSwipe(newIndex: i);
                        },
                        controller: _pageController,
                        children: <Widget>[
                          Container(
                            constraints: BoxConstraints.expand(),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('assets/group195.png'),
                                  fit: BoxFit.cover),
                            ),
                            child: Container(
                              margin: EdgeInsets.only(top: 120,left: 20),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('Lorem \nIpsum.', style: TextStyle( fontSize: 40,fontWeight: FontWeight.w400,color: Colors.grey),)),
                            ),
                            //child: Image.asset('assets/group194.png'),
                          ),
                          Container(
                            constraints: BoxConstraints.expand(),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('assets/group196.png'),
                                  fit: BoxFit.cover),
                            ),
                            child: Container(
                              margin: EdgeInsets.only(top: 120,right: 30),
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text('Lorem \nIpsum.', style: TextStyle( fontSize: 40,fontWeight: FontWeight.w400,color: Colors.grey),)),
                            ),
                          ),
                          Container(
                            constraints: BoxConstraints.expand(),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('assets/group197.png'),
                                  fit: BoxFit.cover),
                            ),
                            child: Container(
                              margin: EdgeInsets.only(top: 120),
                              child: Align(
                                  alignment: Alignment.center,
                                  child: Text('Lorem \nIpsum.', style: TextStyle( fontSize: 40,fontWeight: FontWeight.w400,color: Colors.grey),)),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 40),
                            child:Stack(
                              children: [
                                Image.asset('assets/group194.png',fit: BoxFit.cover,),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: RaisedButton(
                                            color: AppColors.white,
                                            shape: RoundedRectangleBorder(
                                                side: BorderSide(color:AppColors.red),
                                                borderRadius: BorderRadius.circular(32.0)),
                                            onPressed: () async {},
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                                              child: Text('Report Emergency',
                                                  style: TextStyle( color: Colors.black54,
                                                  )),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20,),
                                    Text('OR',style: TextStyle(color: AppColors.red,fontWeight: FontWeight.bold),),
                                    SizedBox(height: 20,),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: RaisedButton(
                                            color: AppColors.red,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(32.0)),
                                            onPressed: () async {
                                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) =>
                                                  BlocProvider<SignUpBloc>(
                                                create: (context) => SignUpBloc(repository: UserRepository()),
                                                child: EnterPhoneScreen(),
                                              ),));

                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                                              child: Text('Sign Up',
                                                  style: TextStyle(color: Colors.white)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Indicator(
                          positionIndex: 0,
                          currentIndex: currentIndex,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Indicator(
                          positionIndex: 1,
                          currentIndex: currentIndex,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Indicator(
                          positionIndex: 2,
                          currentIndex: currentIndex,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Indicator extends StatelessWidget {
  final int? positionIndex, currentIndex;
  const Indicator({this.currentIndex, this.positionIndex});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      width: 10,
      decoration: BoxDecoration(
          color: positionIndex == currentIndex
              ? AppColors.darkPrimaryColor
              : AppColors.textfieldShadow,
          borderRadius: BorderRadius.circular(100)),
    );
  }
}
