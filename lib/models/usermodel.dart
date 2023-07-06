class Usermodel {
  String? uid;
  String? fullname;
  String? email;
  String? profilepic;

  Usermodel({this.email, this.fullname, this.profilepic, this.uid});

  Usermodel.fromMap(Map<String, dynamic> map) {
    uid = map["uid"];
    fullname = map["fullname"];
    email = map["email"];
    profilepic = map["Profilpic"];
  }
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "fullname": fullname,
      "email": email,
      "Profilpic": profilepic,
    };
  }
}
