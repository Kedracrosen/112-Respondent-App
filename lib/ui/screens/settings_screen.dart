import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agora_flutter_quickstart/data/app_colors.dart';
import '../../repository/user_repository.dart';
class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserRepository rep = UserRepository();
  int valueHolder = 40;
  @override
  void initState(){

  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: AppColors.textfieldColor,
        statusBarIconBrightness: Brightness.dark));
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
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
        title: GestureDetector(
          onTap: (){
            rep.signOut();
          },
          child: Text(
            'SETTINGS',
            style: TextStyle(
                color: AppColors.deepGrey.withOpacity(0.93),
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: height / 8,
            ),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13.0), //or 15.0
                child: GestureDetector(
                  onTap: (){
                    rep.signOut();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child:Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Center(
                                child:   Text('Aa',style: TextStyle(fontSize: 40,fontWeight: FontWeight.bold),),

                              ),
                            ),
                            SizedBox(width: 30,),
                            Text('Increase the app text size',style: TextStyle(fontSize: 18,color: Colors.black54),),

                          ],
                        ),
                        SizedBox(height: 30,),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('A',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),

                            Expanded(
                              child: Slider(
                                  value: valueHolder.toDouble(),
                                  min: 1,
                                  max: 100,
                                  divisions: 100,
                                  activeColor: Colors.red,
                                  inactiveColor: Colors.grey[300],
                                  label: '${valueHolder.round()}',
                                  onChanged: (double newValue) {
                                    setState(() {
                                      valueHolder = newValue.round();
                                    });
                                  },
                                  semanticFormatterCallback: (double newValue) {
                                    return '${newValue.round()}';
                                  }
                              ),
                            ),
                            Text('A',style: TextStyle(fontSize: 50,fontWeight: FontWeight.bold),),

                          ],
                        ),
                     //   Text('$valueHolder', style: TextStyle(fontSize: 22),),

                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
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
                onPressed: ()  {

                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child:  Text('Save Text Size',
                      style: TextStyle(color: Colors.white))

                ),
              ),
            ),

            SizedBox(
              height: height / 8,
            ),
//            Icon(
//              Icons.download_done,
//              size: 100,
//              color: AppColors.red,
//            ),
//            SizedBox(
//              height: 20,
//            ),
//            Text('Profile Saved!',
//                maxLines: 1,
//                textAlign: TextAlign.center,
//                style: TextStyle(
//                  fontSize: 31,
//                  fontWeight: FontWeight.normal,
//                  color: AppColors.deepGrey,
//                )),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
