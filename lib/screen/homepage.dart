// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:talksapp/models/usermodel.dart';
import 'package:talksapp/screen/loginpage.dart';

import 'chatscreen.dart';

class Homepage extends StatefulWidget {
  final Usermodel userModel;
  final User firebaseUser;

  Homepage({Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with TickerProviderStateMixin {
  final controller = PageController(
    initialPage: 3,
  );
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(top: 1.h),
          child: Text(
            "TalksApp",
            style: TextStyle(fontSize: 20.sp),
          ),
        ),
        actions: [
          MenuItemButton(
              child: PopupMenuButton(
            color: Colors.white,
            itemBuilder: (context) {
              return <PopupMenuEntry<int>>[
                PopupMenuItem(
                  child: const Text('Logout'),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.popUntil(context, (route) => route.isFirst);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return Loginpage();
                      }),
                    );
                  },
                ),
              ];
            },
          ))
        ],
        actionsIconTheme: IconThemeData(),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          labelPadding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 15.h),
          indicator: UnderlineTabIndicator(
              insets: EdgeInsets.symmetric(horizontal: 70.w)),
          indicatorSize: TabBarIndicatorSize.label,
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Icon(
              Icons.camera_alt,
              size: 26,
            ),
            Text(
              "Chat",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              "Calls",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Center(
            child: Text("camera"),
          ),
          Chatscreen(
            usermodel: widget.userModel,
            firebaseuser: widget.firebaseUser,
          ),
          Center(
            child: Text("calls"),
          )
        ],
      ),
    );
  }
}
