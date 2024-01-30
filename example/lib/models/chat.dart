class ChatList {
  List<Chat>? chats;
  ChatList(this.chats);
}

class Chat {
  int? id;
  String? name;
  int? memberCount;

  List<String>? messages;

  Chat(this.id, this.name, this.memberCount);
}
