import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agora_flutter_quickstart/bloc/sign_up/bloc.dart';
import 'package:agora_flutter_quickstart/bloc/sign_up/event.dart';
import 'package:agora_flutter_quickstart/bloc/sign_up/state.dart';
import 'package:agora_flutter_quickstart/data/app_colors.dart';
import '../../repository/user_repository.dart';
import 'package:agora_flutter_quickstart/ui/screens/enter_otp.dart';

import 'home_screen.dart';

class UpdateDataScreen extends StatefulWidget {
  String? phone;
  UpdateDataScreen({Key? key,this.phone}) : super(key: key);

  @override
  _UpdateDataScreenState createState() => _UpdateDataScreenState();
}

class _UpdateDataScreenState extends State<UpdateDataScreen> {
  SignUpBloc? _signUpBloc;
  bool isloading = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameTextEditingController =
      TextEditingController();
  final TextEditingController _lastNameTextEditingController =
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
                  child: HomeScreen(),
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

                      child: Container(
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
                                  BorderRadius.all(Radius.circular(20)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.redAccent.withOpacity(0.1),
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
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                alignment: Alignment.center,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.redAccent.withOpacity(0.1),
                                        spreadRadius: 2,
                                        blurRadius: 7,
                                        offset: Offset(0, 3), // changes position of shadow
                                      ),
                                    ],),
                                  child: TextFormField(
                                    controller: _firstNameTextEditingController,
                                    keyboardType: TextInputType.name,
                                    decoration: InputDecoration(
                                        fillColor: AppColors.textfieldColor,
                                        filled: false,
                                        hintText: 'Firstname',
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
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                alignment: Alignment.center,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.redAccent.withOpacity(0.1),
                                        spreadRadius: 2,
                                        blurRadius: 7,
                                        offset: Offset(0, 3), // changes position of shadow
                                      ),
                                    ],),
                                  child: TextFormField(
                                    controller: _lastNameTextEditingController,
                                    keyboardType: TextInputType.name,
                                    decoration: InputDecoration(
                                        fillColor: AppColors.textfieldColor,
                                        filled: false,
                                        hintText: 'Lastname',
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
                              Icons.email,
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
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.redAccent.withOpacity(0.1),
                                        spreadRadius: 2,
                                        blurRadius: 7,
                                        offset: Offset(0, 3), // changes position of shadow
                                      ),
                                    ],),
                                  child: TextFormField(
                                    controller: _emailTextEditingController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                        fillColor: AppColors.textfieldColor,
                                        filled: false,
                                        hintText: 'Email',
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
                          SigningUpEvent(
                            phone: widget.phone!,
                            firstname: _firstNameTextEditingController.text,
                            lastname: _lastNameTextEditingController.text,
                            email: _emailTextEditingController.text,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: isloading == false? Text('Sign Up',
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
//                  Center(
//                    child: Text(
//                      'Or sign up with:',
//                      style: TextStyle(color: AppColors.textColor),
//                    ),
//                  ),
                  SizedBox(
                    height: 20.0,
                  ),
//                  Center(
//                      child: Padding(
//                        padding: const EdgeInsets.all(10.0),
//                        child: Row(
//                    mainAxisAlignment: MainAxisAlignment.center,
//                    children: <Widget>[
//                        InkWell(
//                          onTap: () {},
//                          child: Container(
//                            height: 30.0,
//                            width: 30.0,
//                            decoration: BoxDecoration(
//                              image: DecorationImage(
//                                  image: AssetImage('assets/fb_logo.jpg'),
//                                  fit: BoxFit.cover),
//                              shape: BoxShape.circle,
//                            ),
//                          ),
//                        ),
//                        SizedBox(width: 20,),
//                        InkWell(
//                          onTap: () {},
//                          child: Container(
//                            height: 30.0,
//                            width: 30.0,
//                            decoration: BoxDecoration(
//                              image: DecorationImage(
//                                  image: AssetImage('assets/google_logo.jpg'),
//                                  fit: BoxFit.cover),
//                              shape: BoxShape.circle,
//                            ),
//                          ),
//                        ),
//                    ],
//                  ),
//                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
