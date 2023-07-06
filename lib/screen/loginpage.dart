import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:talksapp/models/usermodel.dart';
import 'package:talksapp/screen/homepage.dart';
import 'package:talksapp/screen/singuppage.dart';

import '../models/uihelper.dart';

class Loginpage extends StatefulWidget {
  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  final emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();

  void checkvalue() {
    String email = emailcontroller.text.trim();
    String password = passwordcontroller.text.trim();

    if (email == '' || password == '') {
      UIHelper.showAlertDialog(context, 'Incompleted', 'Please fill all field');
      print("Please fill all field");
    } else {
      Login(email, password);
    }
  }

  void Login(String email, String password) async {
    UIHelper.showLoadingDialog(context, 'Loding...');
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);
      UIHelper.showAlertDialog(context, 'Error Accqure', ex.message.toString());
      print(ex.message.toString());
    }

    if (credential != null) {
      String uid = credential.user!.uid;
      DocumentSnapshot userdata =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();
      Usermodel? usermodel =
          Usermodel.fromMap(userdata.data() as Map<String, dynamic>);
      print("userlogin");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) {
          return Homepage(
            userModel: usermodel,
            firebaseUser: credential!.user!,
          );
        },
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 100.h,
              ),
              Center(
                child: Text(
                  " Welcome Talks App",
                  style:
                      TextStyle(fontSize: 25.sp, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(
                height: 70.h,
              ),
              TextFormField(
                controller: emailcontroller,
                decoration: InputDecoration(
                    label: Text("Email",
                        style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.black,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w300)),
                    hintText: "Enter Your Email",
                    contentPadding: EdgeInsets.symmetric(horizontal: 5.w),
                    hintStyle: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.black,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w300)),
              ),
              SizedBox(
                height: 20.h,
              ),
              TextFormField(
                controller: passwordcontroller,
                decoration: InputDecoration(
                    label: Text("password",
                        style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.black,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w300)),
                    hintText: "Enter Your password",
                    contentPadding: EdgeInsets.symmetric(horizontal: 5.w),
                    hintStyle: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.black,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w300)),
              ),
              SizedBox(
                height: 30.h,
              ),
              Row(
                children: [
                  Text(
                    " you  haven't Account ",
                    style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w300,
                        color: Colors.black),
                  ),
                  SizedBox(
                    width: 5.w,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return Singupage();
                        },
                      ));
                    },
                    child: Text(
                      "singup",
                      style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w300,
                          color: Colors.blueAccent),
                    ),
                  ),
                ],
              ),
              Expanded(
                  child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 40.h,
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () {
                        checkvalue();
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                            fontSize: 20.sp,
                            color: Colors.black,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w400),
                      )),
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
