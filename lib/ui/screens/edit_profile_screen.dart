import 'dart:io';
import 'dart:ui';

import 'package:agora_flutter_quickstart/bloc/sign_up/bloc.dart';
import 'package:agora_flutter_quickstart/bloc/sign_up/event.dart';
import 'package:agora_flutter_quickstart/bloc/sign_up/state.dart';
import 'package:agora_flutter_quickstart/model/user.dart';
import 'package:agora_flutter_quickstart/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:agora_flutter_quickstart/data/app_colors.dart';
import 'package:agora_flutter_quickstart/ui/screens/settings_screen.dart';

class EditProfileScreen extends StatefulWidget {
  EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool isloading = false;
  String? height='',age='',blood='',weight='',date='YYYY-MM-DD',allergies='';
  SignUpBloc? _signUpBloc;
  UserRepository  repository = UserRepository();
  User? currentUser;
  PickedFile? _image;
  final ImagePicker _picker = ImagePicker();
  _imgFromCamera() async {
    PickedFile? image =await _picker.getImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
  }
  _imgFromGallery() async {
    PickedFile? image =await _picker.getImage(source: ImageSource.gallery);


    setState(() {
      _image = image;
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                      leading: Icon(Icons.photo_library),
                      title: Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  ListTile(
                    leading: Icon(Icons.photo_camera),
                    title: Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  var address='not set';
  void showloader(loading) {
    setState(() {
      isloading = loading;
    });
  }
  @override
  void initState() {
    _signUpBloc = BlocProvider.of<SignUpBloc>(context);
    repository.getCurrentUser().then((value) {
      setState(() {
        currentUser = value;
        height = value.height;
        weight= value.weight;
        blood = value.bloodType;
        date = date!.isEmpty?'YYY_MM_DD' :value.dob;
        allergies = value.allergies;
      });

    //  age=value.;
    });

  //  _signUpBloc!.add(FetchUserDataEvent());
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var _allergyTextController;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: AppColors.textCaptionColor, //change your color here
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Edit Profile',
          style: TextStyle(
              color: AppColors.textCaptionColor.withOpacity(0.93),
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                      text: "Profile data:  ",
                      style: TextStyle(
                          color: AppColors.textCaptionColor,
                          fontWeight: FontWeight.normal)),
                  WidgetSpan(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: CircleAvatar(
                        backgroundColor: AppColors.red,
                        radius: 8.0,
                        child: null,
                      ),
                    ),
                  ),
                  TextSpan(
                      text: "60% ",
                      style: TextStyle(
                          color: AppColors.textCaptionColor,
                          fontWeight: FontWeight.normal)),
                ],
              ),
            ),
          ),
        ],
      ),
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


          } else {
            showloader(false);
          }
        },
        child: SingleChildScrollView(
          child: Container(
              color: AppColors.white,
              child: Column(
                children: [
                  if (_image != null) InkResponse(
                      onTap: (){
                        _showPicker(context);
                      },
                      child:
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(_image!.path),
                              height:100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          ClipRRect(
                              borderRadius: BorderRadius.only(bottomRight: Radius.circular(10),bottomLeft:Radius.circular(10)),
                              child: Container(
                                color: Colors.black87.withOpacity(0.7),
                                height: 30,
                                width: 100,
                                child: Center(child: Text("Change Photo",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600,fontSize:12),)),
                              )
                          ),

                        ],
                      )) else InkResponse(
                    onTap: (){
                      _showPicker(context);
                    },
                    child:
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Colors.white.withOpacity(0.9),
                          border: Border.all(
                            width:1,
                            color: Colors.grey,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            height: 40,

                            child: Text("Add Photo",style: TextStyle(fontSize: 12),),
                          ),
                        ),
                      ),
                    ),),


                  InkResponse(
                    onTap: () async {
                      DateTime newDateTime = await showRoundedDatePicker(
                        context: context,
                        theme: ThemeData(primarySwatch: Colors.red),
                      );
                      setState(() {
                        date = newDateTime.year.toString() +'-' +newDateTime.month.toString() +'-'+ newDateTime.day.toString();

                      });
                    },
                    child: Text(date!,
                        style: TextStyle(
                            color: AppColors.textCaptionColor,
                            fontWeight: FontWeight.normal,
                            fontSize: 22)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      color: AppColors.grey.withOpacity(0.2),
                      child: GridView(
                        padding: EdgeInsets.symmetric(vertical: 1.0),
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisSpacing: 1,
                            mainAxisSpacing: 1,
                            crossAxisCount: 2,
                            childAspectRatio: 1.5),
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              _displayDialog(context,'Age');

                            },
                            child: Container(
                              color: AppColors.white,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Age:',
                                                style: TextStyle(
                                                    color: AppColors
                                                        .textCaptionColor,
                                                    fontWeight:
                                                        FontWeight.normal)),
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                      text: "26",
                                                      style: TextStyle(
                                                        fontSize: 27,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors.deepGrey
                                                            .withOpacity(0.93),
                                                      )),
                                                  WidgetSpan(
                                                      child: SizedBox(
                                                    width: 5,
                                                  )),
                                                  TextSpan(
                                                      text: "years",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors.deepGrey
                                                            .withOpacity(0.93),
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Icon(
                                          Icons.calendar_today_outlined,
                                          color: AppColors.blueIconColor,
                                          size: 27,
                                        ),
                                      )
                                    ]),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              _displayDialog(context,'blood type');

                            },
                            child: Container(
                              color: AppColors.white,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Blood type:',
                                                style: TextStyle(
                                                    color: AppColors
                                                        .textCaptionColor,
                                                    fontWeight:
                                                        FontWeight.normal)),
                                            SizedBox(height: 5),
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                      text: blood,
                                                      style: TextStyle(
                                                        fontSize: 27,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors.deepGrey
                                                            .withOpacity(0.93),
                                                      )),
                                                  WidgetSpan(
                                                      child: SizedBox(
                                                    width: 5,
                                                  )),
                                                  TextSpan(
                                                      text: "+",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors.deepGrey
                                                            .withOpacity(0.93),
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: SvgPicture.asset(
                                          'assets/blood-drop.svg',
                                          color: AppColors
                                              .redIconColor,
                                          width: 27,
                                        ),
                                      )
                                    ]),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              _displayDialog(context,'height');

                            },
                            child: Container(
                              color: AppColors.white,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Height:',
                                                style: TextStyle(
                                                    color: AppColors
                                                        .textCaptionColor,
                                                    fontWeight:
                                                        FontWeight.normal)),
                                            SizedBox(height: 5),
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                      text: height,
                                                      style: TextStyle(
                                                        fontSize: 27,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors.deepGrey
                                                            .withOpacity(0.93),
                                                      )),
                                                  WidgetSpan(
                                                      child: SizedBox(
                                                    width: 5,
                                                  )),
                                                  TextSpan(
                                                      text: "cm",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors.deepGrey
                                                            .withOpacity(0.93),
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: SvgPicture.asset(
                                          'assets/height.svg',
                                          color: AppColors
                                              .yellowIconColor,
                                          width: 27,
                                        ),
                                      )
                                    ]),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              _displayDialog(context,'weight');
                            },
                            child: Container(
                              color: AppColors.white,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Weight:',
                                                style: TextStyle(
                                                    color: AppColors
                                                        .textCaptionColor,
                                                    fontWeight:
                                                        FontWeight.normal)),
                                            SizedBox(height: 5),
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                      text: weight ,
                                                      style: TextStyle(
                                                        fontSize: 27,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors.deepGrey
                                                            .withOpacity(0.93),
                                                      )),
                                                  WidgetSpan(
                                                      child: SizedBox(
                                                    width: 5,
                                                  )),
                                                  TextSpan(
                                                      text: "kg",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors.deepGrey
                                                            .withOpacity(0.93),
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: SvgPicture.asset(
                                          'assets/weight-scale.svg',
                                          color: AppColors
                                              .skyBlueIconColor,
                                          width: 27,
                                        ),
                                      )
                                    ]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Allergies',
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.deepGrey.withOpacity(0.93),
                            )),
                        InkResponse(onTap: (){
                          _displayDialog(context, 'allergies');
                        },    child: Text(' + Add',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),)),

                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
//                Padding(
//                  padding: const EdgeInsets.all(30.0),
//                  child: Container(
//                    color: AppColors.grey.withOpacity(0.2),
//                    child: GridView.count(
//                      padding: EdgeInsets.symmetric(vertical: 1.0),
//                      shrinkWrap: true,
//                      crossAxisSpacing: 1,
//                      mainAxisSpacing: 1,
//                      crossAxisCount: 2,
//                      childAspectRatio: 3.0,
//                      children: List.generate(2, (index) {
//                        return TextField(
//                          controller: _allergyTextController,
//                          decoration: InputDecoration(
//                            filled: true,
//                            fillColor: AppColors.white,
//                            border: OutlineInputBorder(
//                              borderSide: BorderSide(
//                                width: 0,
//                                style: BorderStyle.none,
//                              ),
//                            ),
//                            contentPadding: EdgeInsets.all(8.0),
//                            hintText: '---',
//                          ),
//                        );
//                      }),
//                      // children: <Widget>[
//                      //   TextField(
//                      //     controller: _allergyTextController,
//                      //     decoration: InputDecoration(
//                      //       filled: true,
//                      //       fillColor: AppColors.white,
//                      //       border: OutlineInputBorder(
//                      //         borderRadius: BorderRadius.circular(4),
//                      //         borderSide: BorderSide(
//                      //           width: 0,
//                      //           style: BorderStyle.none,
//                      //         ),
//                      //       ),
//                      //       contentPadding: EdgeInsets.all(8.0),
//                      //       hintText: '---',
//                      //     ),
//                      //   ),
//                      //   TextField(
//                      //     controller: _allergyTextController,
//                      //     decoration: InputDecoration(
//                      //       filled: true,
//                      //       fillColor: AppColors.white,
//                      //       border: OutlineInputBorder(
//                      //         borderRadius: BorderRadius.circular(4),
//                      //         borderSide: BorderSide(
//                      //           width: 0,
//                      //           style: BorderStyle.none,
//                      //         ),
//                      //       ),
//                      //       contentPadding: EdgeInsets.all(8.0),
//                      //       hintText: '---',
//                      //     ),
//                      //   ),
//                      //   TextField(
//                      //     controller: _allergyTextController,
//                      //     decoration: InputDecoration(
//                      //       filled: true,
//                      //       fillColor: AppColors.white,
//                      //       border: OutlineInputBorder(
//                      //         borderRadius: BorderRadius.circular(4),
//                      //         borderSide: BorderSide(
//                      //           width: 0,
//                      //           style: BorderStyle.none,
//                      //         ),
//                      //       ),
//                      //       contentPadding: EdgeInsets.all(8.0),
//                      //       hintText: '---',
//                      //     ),
//                      //   ),
//                      //   TextField(
//                      //     controller: _allergyTextController,
//                      //     decoration: InputDecoration(
//                      //       filled: true,
//                      //       fillColor: AppColors.white,
//                      //       border: OutlineInputBorder(
//                      //         borderRadius: BorderRadius.circular(4),
//                      //         borderSide: BorderSide(
//                      //           width: 0,
//                      //           style: BorderStyle.none,
//                      //         ),
//                      //       ),
//                      //       contentPadding: EdgeInsets.all(8.0),
//                      //       hintText: '---------------',
//                      //     ),
//                      //   ),
//                      // ],
//                    ),
//                  ),
//
                InkResponse(onTap: (){
                  _displayDialog(context, 'allergies');
                },    child: Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount:allergies!.split(',').length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(allergies!.split(',')[index],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.black54),),
                      );
                    },
                  ),
                ),),
                SizedBox(height: 10),
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
                      onPressed: ()  {
                          _signUpBloc!.add(UpdateProfileEvent(
                            dob: date,
                            weight: weight,
                            allergies: allergies,
                            height: height,
                            blood: blood,
                            image:_image!.path
                          ));
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: isloading == false? Text('Submit',
                            style: TextStyle(color: Colors.white)): SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                            AlwaysStoppedAnimation<
                                Color>(Colors.white),
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                ],
              )),
        ),
      ),
    );
  }



  _displayDialog(BuildContext context,String title) async {
    TextEditingController _textFieldController = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Enter ${title}'),
            content: TextField(
              controller: _textFieldController,
              textInputAction: TextInputAction.go,
              keyboardType:title=='blood type' || title == 'allergies'? TextInputType.text : TextInputType.numberWithOptions(),
              decoration: InputDecoration(hintText: title=='allergies'?'grape , cheese' :"Enter here"),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Done',style: TextStyle(color: AppColors.redIconColor),),
                onPressed: () {
                  switch(title){
                    case 'weight': weight=_textFieldController.text; break;
                    case 'height': height=_textFieldController.text;break;
                    case 'blood type': blood=_textFieldController.text;break;
                    case 'allergies': allergies=_textFieldController.text;break;
                    default:{}
                  }
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }


}
