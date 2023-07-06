import 'dart:async';

class Massegemodel {
  String? sender;
  String? messageid;
  String? text;
  bool? seen;
  DateTime? createdon;

  Massegemodel(
      {this.sender, this.text, this.createdon, this.seen, this.messageid});

  Massegemodel.fromMap(Map<String, dynamic> map) {
    sender = map['sender'];
    messageid = map['messageid'];
    seen = map['seen'];
    text = map['text'];
    createdon = map['createdon']!.toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      "sender": sender,
      'messageid': messageid,
      "seen": seen,
      "text": text,
      "createdon": createdon
    };
  }
}
