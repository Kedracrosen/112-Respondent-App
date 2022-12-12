import 'package:flutter/material.dart';
import 'package:agora_flutter_quickstart/data/app_colors.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idNumberTextEditingController =
      TextEditingController();
  final TextEditingController _passwordTextEditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(color: AppColors.white,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                SizedBox(
                  height: height * 0.15,
                ),
                Center(
                  child: Container(
                    //alignment: Alignment.center,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                      //begin: Alignment.topRight,
                      //end: Alignment.bottomLeft,
                      colors: [
                        AppColors.lightPrimaryColor,
                        AppColors.darkPrimaryColor,
                      ],
                    )),
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Text('Logo'),
                    ),
                  ),
                ),
                SizedBox(
                  height: height * 0.1,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: AppColors.red,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.redAccent.withOpacity(0.4),
                                spreadRadius: 2,
                                blurRadius: 7,
                                offset: Offset(0, 3), // changes position of shadow
                              ),
                            ]
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Container(
                              alignment: Alignment.center,
                              child: TextFormField(
                                controller: _idNumberTextEditingController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  fillColor: AppColors.textfieldColor,
                                  filled: true,
                                  hintText: 'ID Number',
                                  hintStyle: TextStyle(
                                      color: AppColors.textColor
                                          .withOpacity(0.46)),
                                  contentPadding: EdgeInsets.all(15),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: AppColors.textfieldShadow),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: AppColors.textfieldColor),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  border: InputBorder.none,
                                ),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                style: TextStyle(color: AppColors.textColor),
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: AppColors.red,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.lock,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Container(
                              alignment: Alignment.center,
                              child: TextFormField(
                                controller: _passwordTextEditingController,
                                keyboardType: TextInputType.visiblePassword,
                                obscureText: true,
                                decoration: InputDecoration(
                                    fillColor: AppColors.textfieldColor,
                                    filled: true,
                                    hintText: 'Password',
                                    hintStyle: TextStyle(
                                        color: AppColors.textColor
                                            .withOpacity(0.46)),
                                    contentPadding: EdgeInsets.all(15),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppColors.textfieldShadow),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppColors.textfieldColor),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    border: InputBorder.none),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                style: TextStyle(color: AppColors.textColor),
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: height * 0.1,
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
                                    borderRadius: BorderRadius.circular(32.0),
                                    side: BorderSide(color: AppColors.red)))),
                    onPressed: () async {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text('Sign In',
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
    );
  }
}
