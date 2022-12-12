import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:agora_flutter_quickstart/data/app_colors.dart';
import '../../../repository/user_repository.dart';
import '../../widgets/full_photo.dart';
import '../../widgets/loading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Chat extends StatelessWidget {
  final String? peerId;
  final String? peerAvatar,title;

  Chat({Key? key, @required this.peerId, @required this.peerAvatar,this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        title: Row(
          children: [
            CircleAvatar(
                backgroundColor: AppColors.red,
                radius: 16.0,
                child: Icon(
                  Icons.medical_services_outlined,
                  color: AppColors.white,
                  size: 20,
                )),
            SizedBox(
              width: 14,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "911 ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.deepGrey.withOpacity(0.93),
                            fontSize: 23),
                      ),
                      TextSpan(
                          text: title,
                          style: TextStyle(
                              color: AppColors.red,
                              fontWeight: FontWeight.normal)),
                    ],
                  ),
                ),
                Text(
                  'Online',
                  style: TextStyle(
                      color: AppColors.offWhiteColor.withOpacity(0.93),
                      fontSize: 14,
                      fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ],
        ),
      ),
      body: ChatScreen(
        peerId: peerId!,
        peerAvatar: peerAvatar!,
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String? peerId;
  final String? peerAvatar;

  ChatScreen({Key? key, @required this.peerId, @required this.peerAvatar}) : super(key: key);

  @override
  State createState() => ChatScreenState(peerId: peerId!, peerAvatar: peerAvatar!);
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState({Key? key, @required this.peerId, @required this.peerAvatar});

  String? peerId;
  String? peerAvatar;
  String? id;

  List<QueryDocumentSnapshot> listMessage = new List.from([]);
  int _limit = 20;
  int _limitIncrement = 20;
  String groupChatId = "";
  SharedPreferences? prefs;

  File? imageFile;
  bool isLoading = false;
  bool isShowSticker = false;
  String imageUrl = "";

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  _scrollListener() {
    if (listScrollController.offset >= listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
    listScrollController.addListener(_scrollListener);
    readLocal();
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  readLocal() async {
    UserRepository userRepository = UserRepository();
     userRepository.getCurrentUser().then((value) => {
       id = value.id,
       FirebaseFirestore.instance.collection('users').doc(id).update({'chattingWith': peerId}),
      if (id.hashCode <= peerId.hashCode) {
         groupChatId = '$id-$peerId'
         } else {
         groupChatId = '$peerId-$id'
         },
       setState(() {})
     });



  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile? pickedFile;

    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      if (imageFile != null) {
        setState(() {
          isLoading = true;
        });
        uploadFile();
      }
    }
  }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(imageFile!);

    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();

      var documentReference = FirebaseFirestore.instance
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          {
            'idFrom': id,
            'idTo': peerId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type,
            'isAdmin':false
          },
        );
      });
      listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send', backgroundColor: Colors.black, textColor: Colors.red);
    }
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document != null) {
      if (document.get('idFrom') == id) {
        // Right (my message)
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            document.get('type') == 0
            // Text
                ? Container(
              padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
              width: 200.0,
              decoration: BoxDecoration(color: AppColors.textfieldColor, borderRadius: BorderRadius.circular(40.0)),
              margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
              child: Text(
                document.get('content'),
                style: TextStyle(),
              ),
            )
                : document.get('type') == 1
            // Image
                ? Container(
              margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
              child: OutlinedButton(
                child: Material(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  clipBehavior: Clip.hardEdge,
                  child: Image.network(
                    document.get("content"),
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                        ),
                        width: 200.0,
                        height: 200.0,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.redIconColor,
                            value: loadingProgress.expectedTotalBytes != null &&
                                loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, object, stackTrace) {
                      return Material(
                        child: Image.asset(
                          'images/img_not_available.jpeg',
                          width: 200.0,
                          height: 200.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                      );
                    },
                    width: 200.0,
                    height: 200.0,
                    fit: BoxFit.cover,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullPhoto(
                        url: document.get('content'),
                      ),
                    ),
                  );
                },
                style: ButtonStyle(padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(0))),
              ),
            )
            // Sticker
                : Container(
              margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
              child: Image.asset(
                'images/${document.get('content')}.gif',
                width: 100.0,
                height: 100.0,
                fit: BoxFit.cover,
              ),
            ),
          ],
        );
      } else {
        // Left (peer message)
        return Container(
          margin: EdgeInsets.only(bottom: 10.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  isLastMessageLeft(index)
                      ? Material(
                    borderRadius: BorderRadius.all(
                      Radius.circular(18.0),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child:    CircleAvatar(
                        backgroundColor: document.get('idFrom') == "0"? Colors.black87:AppColors.red,
                        radius: 16.0,
                        child: Icon(
                          document.get('idFrom') == "0"? Icons.person_pin:Icons.medical_services_outlined,
                          color: AppColors.white,
                          size: 20,
                        )),
                  )
                      : Container(width: 35.0),
                  document.get('type') == 0
                      ? Container(
                    padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    width: 200.0,
                    decoration: BoxDecoration(color: AppColors.receiverChatColor, borderRadius: BorderRadius.circular(40.0)),
                    margin: EdgeInsets.only(left: 10.0),
                    child: Text(
                      document.get('content'),
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                      : document.get('type') == 1
                      ? Container(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => FullPhoto(url: document.get('content'))));
                      },
                      style: ButtonStyle(padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(0))),
                      child: Material(
                        child: Image.network(
                          document.get('content'),
                          loadingBuilder:
                              (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                              width: 200.0,
                              height: 200.0,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.redIconColor,
                                  value: loadingProgress.expectedTotalBytes != null &&
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, object, stackTrace) => Material(
                            child: Image.asset(
                              'images/img_not_available.jpeg',
                              width: 200.0,
                              height: 200.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                            clipBehavior: Clip.hardEdge,
                          ),
                          width: 200.0,
                          height: 200.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        clipBehavior: Clip.hardEdge,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 10.0),
                  )
                      : Container(
                    margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
                    child: Image.asset(
                      'images/${document.get('content')}.gif',
                      width: 100.0,
                      height: 100.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),

              // Time
              isLastMessageLeft(index)
                  ? Container(
                margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                child: Text(
                  DateFormat('dd MMM kk:mm')
                      .format(DateTime.fromMillisecondsSinceEpoch(int.parse(document.get('timestamp')))),
                  style: TextStyle(color: Colors.grey, fontSize: 12.0, fontStyle: FontStyle.italic),
                ),
              )
                  : Container()
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        );
      }
    } else {
      return SizedBox.shrink();
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 && listMessage[index - 1].get('idFrom') == id) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 && listMessage[index - 1].get('idFrom') != id) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      FirebaseFirestore.instance.collection('users').doc(id).update({'chattingWith': null});
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            // List of messages
            buildListMessage(),


            // Input content
            buildInput(),
          ],
        ),

        // Loading
        buildLoading()
      ],
    );
  }


  Widget buildLoading() {
    return Positioned(
      child: isLoading ? const Loading() : Container(),
    );
  }

  Widget buildInput() {
    return Container(
      height: 80,
      width: MediaQuery.of(context).size.width,
      color: AppColors.textfieldColor,
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            color: Colors.transparent,

            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Transform.rotate(
                    angle: 45,
                    alignment: Alignment.center,
                    child: Icon(Icons.attach_file)),
                onPressed: getImage,
                color: AppColors.grey,
              ),
            ),
          ),


          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                onSubmitted: (value) {
                  onSendMessage(textEditingController.text, 0);
                },
                style: TextStyle(color: AppColors.redIconColor, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Report an emergency...',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                focusNode: focusNode,
              ),
            ),
          ),

          // Button send message
          Material(
            color: Colors.transparent,

            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Transform.rotate(
                    angle: -45,
                    alignment: Alignment.center,
                    child: Icon(Icons.send_sharp,)),

                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: AppColors.redIconColor,
              ),
            ),
          ),
        ],
      ),

    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .doc(groupChatId)
            .collection(groupChatId)
            .orderBy('timestamp', descending: true)
            .limit(_limit)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            listMessage.addAll(snapshot.data!.docs);
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) => buildItem(index, snapshot.data!.docs[index]),
              itemCount: snapshot.data?.docs.length,
              reverse: true,
              controller: listScrollController,
            );
          } else {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.redIconColor),
              ),
            );
          }
        },
      )
          : Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.redIconColor),
        ),
      ),
    );
  }
}
