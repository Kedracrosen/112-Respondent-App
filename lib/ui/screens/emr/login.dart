import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agora_flutter_quickstart/bloc/sign_up/bloc.dart';
import 'package:agora_flutter_quickstart/bloc/sign_up/event.dart';
import 'package:agora_flutter_quickstart/bloc/sign_up/state.dart';
import 'package:agora_flutter_quickstart/data/app_colors.dart';
import '../../../repository/user_repository.dart';
import 'package:agora_flutter_quickstart/ui/screens/enter_otp.dart';

import 'admin_home_screen.dart';
import 'home_screen.dart';

class LoginEmr extends StatefulWidget {

  @override
  _LoginEmrState createState() => _LoginEmrState();
}

class _LoginEmrState extends State<LoginEmr> {
  SignUpBloc? _signUpBloc;
  bool isloading = false;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _passwordTextEditingController =
      TextEditingController();
  final TextEditingController _emailTextEditingController =
      TextEditingController();

  @override
  void dispose() {
    super.dispose();
  }

  void showloader(loading) {
    setState(() {
      isloading = loading;
    });
  }

  @override
  void initState() {
    _signUpBloc = BlocProvider.of<SignUpBloc>(context);
    //_emailController.text = "BUI/ACAD/282";
    // _passwordController.text = "Ezekiel79";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor:Colors.white ,
      appBar:AppBar(backgroundColor: Colors.white,elevation: 0,),

      body: BlocListener<SignUpBloc, SignUpState>(
        listener: (context, state) {
          if (state is PostingState) {
            showloader(true);
          } else if (state is PostingError) {
            showloader(false);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.error!,
                  style: TextStyle(color: Colors.black87)),
              backgroundColor: Colors.white,
            ));
            showloader(false);

          } else if (state is PostedSuccess) {
            showloader(false);
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider<SignUpBloc>(
                  create: (context) => SignUpBloc(repository: UserRepository()),
                  child: AdminHomeScreen(),
                ),
              ),
            );
          } else {
            showloader(false);
          }
        },
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Center(
                    child: Container(
                      //alignment: Alignment.center,

                      child:   Container(
                        child: Image.asset(
                          'assets/logo.png',
                        ),
                        height: 66.29,
                        width: 66.29,
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.05,),

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
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                alignment: Alignment.center,
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          width: 1.5,
                                          color: AppColors.textfieldShadow,
                                          style: BorderStyle.solid)),
                                  child: TextFormField(
                                    controller: _emailTextEditingController,
                                    keyboardType: TextInputType.name,
                                    decoration: InputDecoration(
                                        fillColor: AppColors.textfieldColor,
                                        filled: false,
                                        hintText: 'ID',
                                        contentPadding: EdgeInsets.all(15),
                                        focusedBorder: InputBorder.none,
                                        border: InputBorder.none),
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    style: TextStyle(color: AppColors.textColor),
                                  ),
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
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                alignment: Alignment.center,
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          width: 1.5,
                                          color: AppColors.textfieldShadow,
                                          style: BorderStyle.solid)),
                                  child: TextFormField(
                                    controller: _passwordTextEditingController,
                                    keyboardType: TextInputType.emailAddress,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                        fillColor: AppColors.textfieldColor,
                                        filled: false,
                                        hintText: 'Password',

                                        contentPadding: EdgeInsets.all(15),
                                        focusedBorder: InputBorder.none,
                                        border: InputBorder.none),
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    style: TextStyle(color: AppColors.textColor),
                                  ),
                                ),
                              )),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: height * 0.05,
                  ),
                  FractionallySizedBox(
                    widthFactor: 0.8,
                    child: RaisedButton(
                      color: AppColors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.0)),
                      onPressed: ()  {
                        _signUpBloc!.add(
                          LoginEmrEvent(
                            id: _emailTextEditingController.text,
                            password: _passwordTextEditingController.text,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: isloading == false? Text('Sign In',
                            style: TextStyle(color: Colors.white)): SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                            new AlwaysStoppedAnimation<
                                Color>(Colors.white),
                            strokeWidth: 3,
                          ),
                        ),
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
      ),
    );
  }
}
