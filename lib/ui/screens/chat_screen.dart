//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
//import 'package:agora_flutter_quickstart/data/app_colors.dart';
//import '../../repository/user_repository.dart';
//import 'package:agora_flutter_quickstart/ui/screens/chat_message_model.dart';
//
//class ChatScreen extends StatefulWidget {
//  final String peerId;
//  final String peerAvatar;
//
//  ChatScreen({Key key, @required this.peerId, @required this.peerAvatar}) : super(key: key);
//
//  @override
//  _ChatScreenState createState() => _ChatScreenState();
//}
//
//class _ChatScreenState extends State<ChatScreen> {
//  UserRepository repository;
//  bool isAttach = false;
//  List<ChatMessageModel> messages = [
//    ChatMessageModel(messageContent: "Hello!", messageType: "sender"),
//    ChatMessageModel(
//        messageContent: "Hi. Can we help you?", messageType: "receiver"),
//  ];
//
//  @override
//  void initState() {
//    repository = UserRepository();
//    repository.getCurrentUser().then((value) => {
//      registerUserForChat(value.id)
//    });
//
//    super.initState();
//  }
// void registerUserForChat(uid) async{
//   final QuerySnapshot result =
//       await FirebaseFirestore.instance.collection('users').where('id', isEqualTo: uid).get();
//   final List < DocumentSnapshot > documents = result.docs;
//   if (documents.length == 0) {
//     // Update data to server if new user
//     FirebaseFirestore.instance.collection('users').doc(uid).set(
//         {
//           'id': uid,
//           'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
//         }
//         );
//   }
// }
//
//  @override
//  Widget build(BuildContext context) {
//    final double height = MediaQuery.of(context).size.height;
//    final double width = MediaQuery.of(context).size.width;
//
//    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//        statusBarColor: AppColors.textfieldColor,
//        statusBarIconBrightness: Brightness.dark));
//    return Scaffold(
//      backgroundColor: AppColors.white,
//      appBar: AppBar(
//        toolbarHeight: height / 6.5,
//        iconTheme: IconThemeData(
//          color: AppColors.grey, //change your color here
//        ),
//        backgroundColor: AppColors.textfieldColor,
//        elevation: 0,
//        leading: GestureDetector(
//          onTap: () {
//            Navigator.pop(context);
//          },
//          child: Icon(
//            Icons.navigate_before, size: 30, // add custom icons also
//          ),
//        ),
//        title: Row(
//          children: [
//            CircleAvatar(
//                backgroundColor: AppColors.red,
//                radius: 16.0,
//                child: Icon(
//                  Icons.medical_services_outlined,
//                  color: AppColors.white,
//                  size: 20,
//                )),
//            SizedBox(
//              width: 14,
//            ),
//            Column(
//              crossAxisAlignment: CrossAxisAlignment.start,
//              children: [
//                RichText(
//                  text: TextSpan(
//                    children: [
//                      TextSpan(
//                        text: "911 ",
//                        style: TextStyle(
//                            fontWeight: FontWeight.bold,
//                            color: AppColors.deepGrey.withOpacity(0.93),
//                            fontSize: 23),
//                      ),
//                      TextSpan(
//                          text: 'Health Care',
//                          style: TextStyle(
//                              color: AppColors.red,
//                              fontWeight: FontWeight.normal)),
//                    ],
//                  ),
//                ),
//                Text(
//                  'Online',
//                  style: TextStyle(
//                      color: AppColors.offWhiteColor.withOpacity(0.93),
//                      fontSize: 14,
//                      fontWeight: FontWeight.normal),
//                ),
//              ],
//            ),
//          ],
//        ),
//      ),
//      body: Stack(
//        children: <Widget>[
//          ListView.builder(
//            itemCount: messages.length,
//            shrinkWrap: true,
//            padding: EdgeInsets.only(top: 10, bottom: 10),
//            physics: NeverScrollableScrollPhysics(),
//            itemBuilder: (context, index) {
//              return Container(
//                padding:
//                    EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
//                child: Align(
//                  alignment: (messages[index].messageType == "receiver"
//                      ? Alignment.topLeft
//                      : Alignment.topRight),
//                  child: Container(
//                    decoration: BoxDecoration(
//                      borderRadius: BorderRadius.circular(40),
//                      color: (messages[index].messageType == "receiver"
//                          ? AppColors.receiverChatColor
//                          : AppColors.textfieldColor),
//                    ),
//                    padding: EdgeInsets.fromLTRB(40, 16, 40, 16),
//                    child: Text(
//                      messages[index].messageContent,textAlign:messages[index].messageType == "receiver" ? TextAlign.end : TextAlign.start,
//                      style: TextStyle(fontSize: 15),
//                    ),
//                  ),
//                ),
//              );
//            },
//          ),
//          Align(
//            alignment: Alignment.bottomLeft,
//            child: Column(
//              crossAxisAlignment: CrossAxisAlignment.center,
//              mainAxisSize: MainAxisSize.max,
//              mainAxisAlignment: MainAxisAlignment.end,
//              children: [
//                isAttach
//                    ? Container(
//                        padding: EdgeInsets.symmetric(horizontal: 20),
//                        height: 95,
//                        width: width,
//                        color: AppColors.greyShadow,
//                        child: Row(
//                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                          children: <Widget>[
//                            Column(
//                                mainAxisAlignment: MainAxisAlignment.center,
//                                children: [
//                                  CircleAvatar(
//                                    child: Icon(Icons.camera_alt,
//                                        color: AppColors.red),
//                                    backgroundColor: AppColors.white,
//                                  ),
//                                  SizedBox(
//                                    height: 5,
//                                  ),
//                                  Text(
//                                    'Camera',
//                                    style: TextStyle(
//                                        color: AppColors.textCaptionColor
//                                            .withOpacity(0.54)),
//                                  )
//                                ]),
//                            Column(
//                                mainAxisAlignment: MainAxisAlignment.center,
//                                children: [
//                                  CircleAvatar(
//                                    child: Icon(Icons.file_present_sharp,
//                                        color: AppColors.blue),
//                                    backgroundColor: AppColors.white,
//                                  ),
//                                  SizedBox(
//                                    height: 5,
//                                  ),
//                                  Text(
//                                    'Document',
//                                    style: TextStyle(
//                                        color: AppColors.textCaptionColor
//                                            .withOpacity(0.54)),
//                                  )
//                                ]),
//                            Column(
//                                mainAxisAlignment: MainAxisAlignment.center,
//                                children: [
//                                  CircleAvatar(
//                                    child: Icon(Icons.photo_album,
//                                        color: AppColors.purple),
//                                    backgroundColor: AppColors.white,
//                                  ),
//                                  SizedBox(
//                                    height: 5,
//                                  ),
//                                  Text(
//                                    'Gallery',
//                                    style: TextStyle(
//                                        color: AppColors.textCaptionColor
//                                            .withOpacity(0.54)),
//                                  )
//                                ]),
//                            Column(
//                                mainAxisAlignment: MainAxisAlignment.center,
//                                children: [
//                                  CircleAvatar(
//                                    child: Icon(Icons.headphones,
//                                        color: AppColors.teal),
//                                    backgroundColor: AppColors.white,
//                                  ),
//                                  SizedBox(
//                                    height: 5,
//                                  ),
//                                  Text(
//                                    'Audio',
//                                    style: TextStyle(
//                                        color: AppColors.textCaptionColor
//                                            .withOpacity(0.54)),
//                                  )
//                                ]),
//                          ],
//                        ),
//                      )
//                    : SizedBox.shrink(),
//                SizedBox(
//                  height: 3,
//                ),
//                Container(
//                  padding: EdgeInsets.symmetric(horizontal: 20),
//                  height: 80,
//                  width: MediaQuery.of(context).size.width,
//                  color: AppColors.textfieldColor,
//                  child: Row(
//                    children: <Widget>[
//                      IconButton(
//                        onPressed: () {
//                          setState(() {
//                            !isAttach ? (isAttach = true) : (isAttach = false);
//                          });
//                        },
//                        icon: Transform.rotate(
//                          alignment: Alignment.center,
//                          angle: 45,
//                          child: Icon(
//                            Icons.attach_file,
//                            color: AppColors.offWhiteColor,
//                            size: 30,
//                          ),
//                        ),
//                      ),
//                      SizedBox(
//                        width: 15,
//                      ),
//                      Expanded(
//                        child: TextField(
//                          maxLines: null,
//                          decoration: InputDecoration(
//                              hintText: "Report an emergency",
//                              hintStyle: TextStyle(
//                                  color: AppColors.textCaptionColor
//                                      .withOpacity(0.54)),
//                              border: InputBorder.none),
//                        ),
//                      ),
//                      IconButton(
//                        onPressed: () {},
//                        icon: Transform.rotate(
//                          alignment: Alignment.center,
//                          angle: -45,
//                          child: Icon(
//                            Icons.send_sharp,
//                            color: AppColors.red,
//                            size: 26,
//                          ),
//                        ),
//                      ),
//                    ],
//                  ),
//                ),
//              ],
//            ),
//          ),
//        ],
//      ),
//    );
//  }
//}
