import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:talksapp/main.dart';
import 'package:talksapp/models/usermodel.dart';
import 'package:uuid/uuid.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class Videocallpage extends StatefulWidget {
  final Usermodel targetUser;
  final User firebaseuser;

  const Videocallpage(
      {super.key, required this.targetUser, required this.firebaseuser});
  @override
  State<Videocallpage> createState() => _VideocallpageState();
}

class _VideocallpageState extends State<Videocallpage> {
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
    onUserLogin();
  }

  void onUserLogin() {
    /// 1.2.1. initialized ZegoUIKitPrebuiltCallInvitationService
    /// when app's user is logged in or re-logged in
    /// We recommend calling this method as soon as the user logs in to your app.
    ZegoUIKitPrebuiltCallInvitationService().init(
      appID: 358770149 /*input your AppID*/,
      appSign:
          "2cdd245df8ba269355062e81da9ed9e50e3652df089994563172e7c983493850" /*input your AppSign*/,
      userID: widget.targetUser.uid!,
      userName: widget.targetUser.fullname!,
      plugins: [ZegoUIKitSignalingPlugin()],
    );
  }

  @override
  Widget build(BuildContext context) {
    log(widget.targetUser.uid!);
    // TODO: implement build
    return SafeArea(
      child: MaterialApp(
        navigatorKey: navigatorKey,
        // home: Scaffold(
        // body: ZegoSendCallInvitationButton(
        //     isVideoCall: true,
        //     resourceID: "zegouikit_call", // For offline call notification
        //     invitees: [
        //   ZegoUIKitUser(
        //     id: widget.targetUser.uid!,
        //     name: widget.targetUser.fullname!,
        //   ),
        //   ZegoUIKitUser(
        //     id: widget.targetUser.uid!,
        //     name: widget.targetUser.fullname!,
        //   )
        // ])

        //     body: ZegoUIKitPrebuiltCall(
        //   appID: 358770149,
        //   appSign:
        //       "2cdd245df8ba269355062e81da9ed9e50e3652df089994563172e7c983493850",
        //   callID: uuid.v1(),
        //   config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
        //     ..onOnlySelfInRoom = (context) {
        //       Navigator.pop(context);
        //     },
        //   userID: widget.targetUser.uid!,
        //   userName: widget.targetUser.fullname!,
        // ),
      ),
      // ),
    );
  }
}
