// ignore_for_file: use_build_context_synchronously, prefer_is_empty

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:talksapp/main.dart';
import 'package:talksapp/models/chatmodel.dart';
import 'package:talksapp/models/usermodel.dart';
import 'package:talksapp/screen/singlechatroom.dart';

import '../models/uihelper.dart';

class Searchscreen extends StatefulWidget {
  Usermodel usermodel;
  User firebaseuser;

  Searchscreen(
      {super.key, required this.firebaseuser, required this.usermodel});
  @override
  State<Searchscreen> createState() => _SearchscreenState();
}

class _SearchscreenState extends State<Searchscreen> {
  final searchcontroller = TextEditingController();
  ChatRoomModel? chatroom;

  getuserdata() {
    FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: searchcontroller.text)
        .where("email", isNotEqualTo: widget.usermodel.email)
        .snapshots();
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      getuserdata();
    });
  }

  Future<ChatRoomModel?> getChatroomModel(Usermodel targetUser) async {
    ChatRoomModel chatRoom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participent.${widget.usermodel.uid}", isEqualTo: true)
        .where("participent.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.length > 0) {
      // Fetch the existing one
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);

      chatRoom = existingChatroom;

      log("allready chat exitst");
    } else {
      // Create a new one
      ChatRoomModel newChatroom = ChatRoomModel(
        chatroomid: uuid.v1(),
        lastmessage: "",
        participent: {
          widget.usermodel.uid.toString(): true,
          targetUser.uid.toString(): true,
        },
      );

      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatroom.chatroomid)
          .set(newChatroom.toMap());

      chatRoom = newChatroom;

      log("New Chatroom Created!");
    }

    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.deepPurple),
        backgroundColor: Colors.white,
        title: TextFormField(
          controller: searchcontroller,
          textAlignVertical: TextAlignVertical.center,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
              suffix: GestureDetector(
                  onTap: () {
                    setState(() {});
                  },
                  child: Icon(Icons.search)),
              hintText: "Search Email...",
              border: InputBorder.none),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .where("email", isEqualTo: searchcontroller.text)
                      .where("email", isNotEqualTo: widget.usermodel.email)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        QuerySnapshot dataSnapshot =
                            snapshot.data as QuerySnapshot;

                        if (dataSnapshot.docs.length > 0) {
                          Map<String, dynamic> userMap = dataSnapshot.docs[0]
                              .data() as Map<String, dynamic>;

                          Usermodel searchedUser = Usermodel.fromMap(userMap);
                          String? imageurl = searchedUser.profilepic.toString();

                          return ListTile(
                            onTap: () async {
                              UIHelper.showLoadingDialog(context, 'loading...');
                              ChatRoomModel? chatroomModel =
                                  await getChatroomModel(searchedUser);

                              if (chatroomModel != null) {
                                log(chatroomModel.lastmessage.toString());
                                Navigator.pop(context);
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return ChatRoomPage(
                                    targetUser: searchedUser,
                                    userModel: widget.usermodel,
                                    firebaseUser: widget.firebaseuser,
                                    chatroom: chatroomModel,
                                  );
                                }));
                              }
                            },
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(imageurl),
                              backgroundColor: Colors.grey[500],
                            ),
                            title: Text(searchedUser.fullname!),
                            subtitle: Text(searchedUser.email!),
                            trailing: Icon(Icons.keyboard_arrow_right),
                          );
                        } else {
                          return Text("No results found!");
                        }
                      } else if (snapshot.hasError) {
                        return Text("An error occured!");
                      } else {
                        return Text("No results found!");
                      }
                    } else {
                      return CircularProgressIndicator();
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
