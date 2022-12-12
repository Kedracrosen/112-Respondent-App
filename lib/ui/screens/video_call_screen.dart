import 'package:flutter/material.dart';
import 'package:agora_flutter_quickstart/data/app_colors.dart';
import 'package:agora_flutter_quickstart/ui/basic/join_channel_video.dart';

class VideoCallScreen extends StatefulWidget {
  VideoCallScreen({Key? key}) : super(key: key);

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool muted = false;
  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Stack(
          children: [

            Container(
              alignment: Alignment.topCenter,
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 90.0, 20.0, 0.0),
                child: SizedBox(
                  height: (MediaQuery.of(context).size.height) / 8,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          children: [
                            Text(
                              'Incoming call from',
                              style: TextStyle(
                                fontSize: 20,
                                color: AppColors.white.withOpacity(0.5),
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            Text(
                              'Ann Rice',
                              style: TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 35),
                            ),
                            Text(
                              'Police',
                              style: TextStyle(
                                color: AppColors.white.withOpacity(0.5),
                                fontWeight: FontWeight.normal,
                              ),
                            )
                          ],
                        ),
//                        RawMaterialButton(
//                          onPressed: null,
//                          child: Icon(
//                            Icons.lightbulb,
//                            color: AppColors.white,
//                            size: 20.0,
//                          ),
//                          shape: CircleBorder(),
//                          elevation: 2.0,
//                          fillColor: AppColors.textCaptionColor.withOpacity(0.73),
//                          padding: const EdgeInsets.all(15.0),
//                        ),
                      ]),
                ),
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Visibility(
                    visible:false,
                    child: RawMaterialButton(
                      onPressed: null,
                      child: Icon(
                        Icons.camera_alt,
                        color: AppColors.textColor,
                        size: 30.0,
                      ),
                      shape: CircleBorder(),
                      elevation: 2.0,
                      fillColor: muted ? AppColors.red : Colors.white,
                      padding: const EdgeInsets.all(15.0),
                    ),
                  ),
                  RawMaterialButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => JoinChannelVideo()),
                    ),
                    child: Icon(
                      Icons.call_end,
                      color: Colors.white,
                      size: 35.0,
                    ),
                    shape: CircleBorder(),
                    elevation: 2.0,
                    fillColor: Colors.green,
                    padding: const EdgeInsets.all(25.0),
                  ),
//                  RawMaterialButton(
//                    onPressed: null,
//                    child: Icon(
//                      muted ? Icons.mic_off : Icons.mic,
//                      color: muted ? Colors.white : AppColors.white,
//                      size: 30.0,
//                    ),
//                    shape: CircleBorder(),
//                    elevation: 2.0,
//                    fillColor:
//                        muted ? AppColors.red : AppColors.textCaptionColor.withOpacity(0.68),
//                    padding: const EdgeInsets.all(15.0),
//                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
