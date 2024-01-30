class ChatList {
  List<Chat>? chats;
  ChatList(this.chats);
}

class Chat {
  int? id;
  String? name;
  int? memberCount;

  List<ChatItem>? messages;

  Chat(this.id, this.name, this.memberCount);
}

class ChatItem {
  String? content;
  String? sender;
  String? timeSent;

  ChatItem(this.content, this.sender, this.timeSent);
}
