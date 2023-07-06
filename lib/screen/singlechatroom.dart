import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:talksapp/main.dart';
import 'package:talksapp/models/chatmodel.dart';
import 'package:talksapp/models/messegemodel.dart';
import 'package:talksapp/models/usermodel.dart';

import 'Videocallpage.dart';

class ChatRoomPage extends StatefulWidget {
  final Usermodel targetUser;
  final ChatRoomModel chatroom;
  final Usermodel userModel;
  final User firebaseUser;

  const ChatRoomPage(
      {super.key,
      required this.targetUser,
      required this.chatroom,
      required this.userModel,
      required this.firebaseUser});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final messagecontroller = TextEditingController();

  void sendmessage() {
    String msg = messagecontroller.text.trim();
    messagecontroller.clear();

    if (msg != null) {
      Massegemodel newmessage = Massegemodel(
          messageid: uuid.v1(),
          sender: widget.userModel.uid,
          createdon: DateTime.now(),
          text: msg,
          seen: false);
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(newmessage.messageid)
          .set(newmessage.toMap());
      log("messege sent");
      DateTime date = DateTime.now();
      ;

      widget.chatroom.lastmessage = msg;
      widget.chatroom.lastmessagetime = date;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.targetUser.profilepic != null
                  ? NetworkImage(widget.targetUser.profilepic.toString())
                  : null,
            ),
            SizedBox(
              width: 12.w,
            ),
            Text(widget.targetUser.fullname.toString()),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(CupertinoIcons.video_camera_solid),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return Videocallpage(
                              targetUser: widget.targetUser,
                              firebaseuser: widget.firebaseUser,
                            );
                          },
                        ));
                      },
                    ),
                    SizedBox(
                      width: 20.w,
                    ),
                    Icon(CupertinoIcons.phone_fill)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("chatrooms")
                    .doc(widget.chatroom.chatroomid)
                    .collection("messages")
                    .orderBy("createdon", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot dataSnapshot =
                          snapshot.data as QuerySnapshot;

                      return ListView.builder(
                        reverse: true,
                        itemCount: dataSnapshot.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> message =
                              dataSnapshot.docs[index].data()
                                  as Map<String, dynamic>;
                          Massegemodel currentMessage =
                              Massegemodel.fromMap(message);

                          return Row(
                            mainAxisAlignment:
                                (currentMessage.sender == widget.userModel.uid)
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                            children: [
                              Container(
                                  margin: EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (currentMessage.sender ==
                                            widget.userModel.uid)
                                        ? Colors.grey
                                        : Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    currentMessage.text.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  )),
                            ],
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                            "An error occured! Please check your internet connection."),
                      );
                    } else {
                      return Center(
                        child: Text("Say hi to your new friend"),
                      );
                    }
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ),
          Container(
            color: Colors.grey[200],
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Row(
              children: [
                Flexible(
                    child: TextFormField(
                  maxLines: null,
                  controller: messagecontroller,
                  decoration: InputDecoration(
                      hintText: "Enter message", border: InputBorder.none),
                )),
                IconButton(
                  onPressed: () {
                    sendmessage();
                  },
                  icon: Icon(
                    Icons.send,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
