import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agora_flutter_quickstart/bloc/sign_up/bloc.dart';
import 'package:agora_flutter_quickstart/bloc/sign_up/event.dart';
import 'package:agora_flutter_quickstart/bloc/sign_up/state.dart';
import 'package:agora_flutter_quickstart/data/app_colors.dart';
import '../../repository/user_repository.dart';
import 'package:agora_flutter_quickstart/ui/screens/enter_otp.dart';

class EnterPhoneScreen extends StatefulWidget {
  EnterPhoneScreen({Key? key}) : super(key: key);

  @override
  _EnterPhoneScreenState createState() => _EnterPhoneScreenState();
}

class _EnterPhoneScreenState extends State<EnterPhoneScreen> {
  SignUpBloc? _signUpBloc;
  bool isloading = false;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _phoneNumberTextEditingController =
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

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider<SignUpBloc>(
                  create: (context) => SignUpBloc(repository: UserRepository()),
                  child: EnterOtpScreen(number: _phoneNumberTextEditingController.text,),
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
                      child:Container(
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
                              Icons.phone,
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
                                    controller: _phoneNumberTextEditingController,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                        fillColor: AppColors.textfieldColor,
                                        filled: false,
                                        hintText: 'Phone Number',
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
                          SendOtpEvent(
                            phone: _phoneNumberTextEditingController.text
//                            firstname: _firstnameController.text,
//                            lastname: _lastnameController.text,
//                            email: _emailController.text,
//                            password: _passwordController.text,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: isloading == false? Text('Proceed',
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
