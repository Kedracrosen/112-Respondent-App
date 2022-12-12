import 'package:flutter/material.dart';
import 'package:agora_flutter_quickstart/data/app_colors.dart';
import 'package:agora_flutter_quickstart/data/app_strings.dart';

class NotificationScreen extends StatefulWidget {
  NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: height / 10.5,
        iconTheme: IconThemeData(
          color: AppColors.grey, //change your color here
        ),
        backgroundColor: AppColors.textfieldColor,
        elevation: 0,
        leading: Icon(Icons.navigate_before),
        title: RichText(
          text: TextSpan(
            children: [
              WidgetSpan(
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child:    Image.asset(
                    'assets/icon_notifications.png',
                    height: 20,
                    width:20,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              TextSpan(
                  text: "Notifications ",
                  style: TextStyle(
                      color: AppColors.deepGrey,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
              child: Container(
                decoration: BoxDecoration(
                    color: AppColors.notificationGreyColor,
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 17, horizontal: 30),
                  child: Column(
                    children: [
                      Text(
                        'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At',
                        style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: 11,
                            height: 15 / 11),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '10:20am',
                            style: TextStyle(
                                color: AppColors.red,
                                fontSize: 10,
                                height: 14 / 10),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            '10/6/2021',
                            style: TextStyle(
                                color: AppColors.red,
                                fontSize: 10,
                                height: 14 / 10),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
              child: Container(
                decoration: BoxDecoration(
                    color: AppColors.notificationGreyColor,
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 17, horizontal: 30),
                  child: Column(
                    children: [
                      Text(
                        'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At',
                        style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: 11,
                            height: 15 / 11),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '10:20am',
                            style: TextStyle(
                                color: AppColors.red,
                                fontSize: 10,
                                height: 14 / 10),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            '10/6/2021',
                            style: TextStyle(
                                color: AppColors.red,
                                fontSize: 10,
                                height: 14 / 10),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        )),
   );
  }
}
