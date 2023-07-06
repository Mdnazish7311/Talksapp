// ignore_for_file: prefer_const_constructors, must_be_immutable, unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:talksapp/models/chatmodel.dart';
import 'package:talksapp/models/firebasehelpermodel.dart';
import 'package:talksapp/models/uihelper.dart';
import 'package:talksapp/models/usermodel.dart';
import 'package:talksapp/screen/singlechatroom.dart';

import 'Searchscreen.dart';

class Chatscreen extends StatefulWidget {
  Usermodel usermodel;
  User firebaseuser;

  Chatscreen({super.key, required this.firebaseuser, required this.usermodel});
  @override
  State<Chatscreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends State<Chatscreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          UIHelper.showLoadingDialog(context, 'loading...');
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return Searchscreen(
                usermodel: widget.usermodel,
                firebaseuser: widget.firebaseuser,
              );
            },
          ));
        },
        child: Icon(Icons.search),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 10.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 100.h,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("chatrooms")
                    .where("participent.${widget.usermodel.uid}",
                        isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot chatsnapshot =
                          snapshot.data as QuerySnapshot;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: chatsnapshot.docs.length,
                        itemBuilder: (context, index) {
                          ChatRoomModel chatroommodel = ChatRoomModel.fromMap(
                              chatsnapshot.docs[index].data()
                                  as Map<String, dynamic>);

                          Map<String, dynamic> participent =
                              chatroommodel.participent!;

                          List<String> participentkeys =
                              participent.keys.toList();

                          participentkeys.remove(widget.usermodel.uid);

                          return FutureBuilder(
                            future: FirebaseHelper.getUserModelById(
                                participentkeys[0]),
                            builder: (context, userData) {
                              if (userData.connectionState ==
                                  ConnectionState.done) {
                                if (userData.data != null) {
                                  Usermodel targetUser =
                                      userData.data as Usermodel;

                                  final date = chatroommodel.lastmessagetime;
                                  String formattedTime =
                                      DateFormat.jm().format(date!);

                                  return ListTile(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) {
                                          return ChatRoomPage(
                                            chatroom: chatroommodel,
                                            firebaseUser: widget.firebaseuser,
                                            userModel: widget.usermodel,
                                            targetUser: targetUser,
                                          );
                                        }),
                                      );
                                    },
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          targetUser.profilepic.toString()),
                                    ),
                                    title: Text(targetUser.fullname.toString()),
                                    subtitle:
                                        (chatroommodel.lastmessage.toString() !=
                                                "")
                                            ? Text(chatroommodel.lastmessage
                                                .toString())
                                            : Text(
                                                "Say hi to your new friend!",
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                ),
                                              ),
                                    trailing: Text(formattedTime.toString()),
                                  );
                                } else {
                                  return Container();
                                }
                              } else {
                                return Container();
                              }
                            },
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text("error"),
                      );
                    } else {
                      return Center(child: Text("No Chats"));
                    }
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
