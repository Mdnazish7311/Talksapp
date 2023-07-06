import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:talksapp/models/uihelper.dart';
import 'package:talksapp/models/usermodel.dart';
import 'package:talksapp/screen/loginpage.dart';

import 'completeprofil.dart';

class Singupage extends StatefulWidget {
  @override
  State<Singupage> createState() => _SingupageState();
}

class _SingupageState extends State<Singupage> {
  final emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  final confirmpasswordcpntroller = TextEditingController();
  void Checkvalue() {
    String email = emailcontroller.text.trim();
    String password = passwordcontroller.text.trim();
    String confirmpassword = confirmpasswordcpntroller.text.trim();
    if (email == '' || password == '' || confirmpassword == '') {
      UIHelper.showAlertDialog(context, 'Incompleted', 'Please Fill all field');
      print("Fill all the field");
    } else if (password != confirmpassword) {
      print("password do not match");
    } else {
      singup(email, password);
    }
  }

  void singup(String email, String password) async {
    UIHelper.showLoadingDialog(context, 'signing...');
    Navigator.pop(context);
    UserCredential? credential;

    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseException catch (e) {
      Navigator.pop(context);
      UIHelper.showAlertDialog(context, 'Error', e.code.toString());

      print(e.code.toString());
    }

    if (credential != null) {
      String uid = credential.user!.uid;
      Usermodel newuser = Usermodel(
        email: email,
        fullname: '',
        profilepic: '',
        uid: uid,
      );
      final data = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newuser.toMap())
          .then((value) {
        print("user create");
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return Completprofile(
              usermodel: newuser,
              firebaseuser: credential!.user!,
            );
          },
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 60.h,
              ),
              Text(
                "Create Your Account",
                style: TextStyle(
                    fontSize: 23.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
              SizedBox(
                height: 50.h,
              ),
              Column(
                children: [
                  TextFormField(
                    controller: emailcontroller,
                    decoration: InputDecoration(
                        label: Text(
                          "Email",
                          style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.black,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w300),
                        ),
                        hintText: "Enter your Eamil",
                        contentPadding: EdgeInsets.symmetric(horizontal: 5.w),
                        hintStyle: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.black,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w300)),
                  ),
                  SizedBox(
                    height: 16.h,
                  ),
                  TextFormField(
                    controller: passwordcontroller,
                    decoration: InputDecoration(
                        label: Text(
                          "Password",
                          style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.black,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w300),
                        ),
                        hintText: "Enter your Password",
                        contentPadding: EdgeInsets.symmetric(horizontal: 5.w),
                        hintStyle: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.black,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w300)),
                  ),
                  SizedBox(
                    height: 16.h,
                  ),
                  TextFormField(
                    controller: confirmpasswordcpntroller,
                    decoration: InputDecoration(
                        label: Text(
                          "Confirm Password",
                          style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.black,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w300),
                        ),
                        hintText: "Enter your Confirm Password",
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
                        "You have An Account ",
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
                              return Loginpage();
                            },
                          ));
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w300,
                              color: Colors.blueAccent),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Expanded(
                  child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  height: 40.h,
                  child: ElevatedButton(
                      onPressed: () {
                        Checkvalue();
                      },
                      child: Text(
                        "singup",
                        style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
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
