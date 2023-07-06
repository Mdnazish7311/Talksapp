import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talksapp/models/uihelper.dart';
import 'package:talksapp/models/usermodel.dart';
import 'package:talksapp/screen/homepage.dart';

class Completprofile extends StatefulWidget {
  final Usermodel usermodel;
  final User firebaseuser;

  const Completprofile(
      {super.key, required this.usermodel, required this.firebaseuser});

  @override
  State<Completprofile> createState() => _CompletprofileState();
}

class _CompletprofileState extends State<Completprofile> {
  File? imageFile;
  final fullnamecontroller = TextEditingController();
  void showPhotoOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Upload Profile Picture"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.gallery);
                  },
                  leading: Icon(Icons.photo_album),
                  title: Text("Select from Gallery"),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.camera);
                  },
                  leading: Icon(Icons.camera_alt),
                  title: Text("Take a photo"),
                ),
              ],
            ),
          );
        });
  }

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      imagecrop(pickedFile);
    }
  }

  Future<void> imagecrop(XFile? file) async {
    CroppedFile? crpedimage = await ImageCropper().cropImage(
      sourcePath: file!.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Set image',
            toolbarColor: Colors.deepPurple,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );
    if (crpedimage != null) {
      setState(() {
        imageFile = imageFile = File(crpedimage.path);
      });
    }
  }

  void checkvalue() {
    String fullname = fullnamecontroller.text.trim();

    if (fullname == '' || imageFile == null) {
      UIHelper.showAlertDialog(context, 'Incompleted', 'Please Fill all field');
      print("please fill allfield");
    } else {
      Uploaddata();
    }
  }

  void Uploaddata() async {
    UIHelper.showLoadingDialog(context, 'Signing...');
    UploadTask? uploadTask = FirebaseStorage.instance
        .ref("profilepics")
        .child(widget.usermodel.uid.toString())
        .putFile(imageFile!);

    final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {
      print("data uploaded");
    });
    print("nazish");
    String? imageurl = await taskSnapshot.ref.getDownloadURL();
    String? fullname = fullnamecontroller.text.trim();
    widget.usermodel.fullname = fullname;
    widget.usermodel.profilepic = imageurl;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.usermodel.uid)
        .set(widget.usermodel.toMap())
        .then((value) {
      print("data uploaded success");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) {
          return Homepage(
            userModel: widget.usermodel,
            firebaseUser: widget.firebaseuser,
          );
        },
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Complet Profile "),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 30.h,
            ),
            InkWell(
              onTap: () {
                showPhotoOptions();
              },
              child: Center(
                child: CircleAvatar(
                  backgroundImage:
                      imageFile != null ? FileImage(imageFile!) : null,
                  radius: 70,
                  child: imageFile != null
                      ? null
                      : Icon(
                          Icons.person,
                          size: 70,
                        ),
                ),
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            TextFormField(
              controller: fullnamecontroller,
              decoration: InputDecoration(
                hintText: "Enter Your Name ",
                label: Text("Enter Your Name"),
              ),
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
                  child: Text("Submit"),
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
