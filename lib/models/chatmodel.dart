class ChatRoomModel {
  String? chatroomid;
  Map<String, dynamic>? participent;
  String? lastmessage;
  DateTime? lastmessagetime;

  ChatRoomModel(
      {this.chatroomid,
      this.participent,
      this.lastmessage,
      this.lastmessagetime});

  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatroomid = map['chatroomid'];
    participent = map['participent'];
    lastmessage = map['lastmessage'];
    lastmessagetime = map['lastmessagetime'].toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      'chatroomid': chatroomid,
      'participent': participent,
      'lastmessage': lastmessage,
      'lastmessagetime': lastmessagetime
    };
  }
}
