import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:agora_flutter_quickstart/data/app_colors.dart';

class VoiceCallScreen extends StatefulWidget {
  VoiceCallScreen({Key? key}) : super(key: key);

  @override
  _VoiceCallScreenState createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  bool muted = false;
  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 46.0, sigmaY: 46.0),
        child: Scaffold(
          backgroundColor: AppColors.textCaptionColor.withOpacity(0.87),
          body: SafeArea(
            top: false,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 80.0, 20.0, 0.0),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.phone_in_talk,
                          color: AppColors.white,
                          size: 26.0,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          '911',
                          style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 77),
                        ),
                        Text(
                          '- Police',
                          style: TextStyle(
                              color: AppColors.white.withOpacity(0.5),
                              fontWeight: FontWeight.normal,
                              fontSize: 24),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RawMaterialButton(
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
                      RawMaterialButton(
                        onPressed: () => _onCallEnd(context),
                        child: Icon(
                          Icons.call_end,
                          color: Colors.white,
                          size: 35.0,
                        ),
                        shape: CircleBorder(),
                        elevation: 2.0,
                        fillColor: AppColors.red,
                        padding: const EdgeInsets.all(25.0),
                      ),
                      RawMaterialButton(
                        onPressed: null,
                        child: Icon(
                          muted ? Icons.mic_off : Icons.mic,
                          color: muted ? Colors.white : AppColors.white,
                          size: 30.0,
                        ),
                        shape: CircleBorder(),
                        elevation: 2.0,
                        fillColor: muted
                            ? AppColors.red
                            : AppColors.textCaptionColor.withOpacity(0.68),
                        padding: const EdgeInsets.all(15.0),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
