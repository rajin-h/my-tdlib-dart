import 'package:example/models/chat.dart';
import 'package:example/models/user.dart';
import 'package:example/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:tdlib/td_api.dart' as api;
import 'package:tdlib/td_client.dart';

class MainChatSection extends StatefulWidget {
  const MainChatSection({
    required this.currentUser,
    required this.client,
    required this.chatService,
    required this.chatList,
  });

  final User? currentUser;
  final Client? client;
  final ChatService? chatService;
  final ChatList? chatList;

  @override
  State<MainChatSection> createState() => _MainChatSectionState();
}

class _MainChatSectionState extends State<MainChatSection> {
  int? openedChatId;

  TextEditingController _messageTextController = TextEditingController();
  TextEditingController _chatIdTextController = TextEditingController();

  ScrollController _scrollController = ScrollController();

  Chat? getOpenedChat() {
    final a = widget.chatList?.chats?.firstWhere(
      (e) => e.id == openedChatId,
      orElse: () => Chat(-1, '', 2),
    );

    if (a?.id == -1) {
      return null;
    }

    return a;
  }

  Future<void> sendMessage(String message) async {
    await widget.chatService?.sendMessage(
      (-1 * getOpenedChat()!.id!),
      message,
    );

    _messageTextController.clear();
  }

  Future<void> joinChat(String chatID) async {
    await widget.chatService?.joinChat(int.parse(chatID));
  }

  @override
  void dispose() {
    _messageTextController.dispose();
    _chatIdTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }

    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'User ID: ',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${widget.currentUser?.id?.toString()}',
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'Name: ',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${widget.currentUser?.firstName?.toString()} ${widget.currentUser?.lastName?.toString()}',
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                widget.chatService?.getChats(100);
              },
              child: const Text('Load Chats'),
            ),
            if (getOpenedChat() != null) ...[
              const SizedBox(height: 15),
              Text(
                'Opened Chat',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Chat ID: ${getOpenedChat()?.id.toString()}',
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 15),
              if (getOpenedChat()?.messages?.length != null) ...[
                SizedBox(
                  height: 300,
                  child: ListView.separated(
                      controller: _scrollController,
                      itemBuilder: (context, i) {
                        DateTime timestamp =
                            DateTime.fromMillisecondsSinceEpoch(int.parse(
                                    getOpenedChat()?.messages?[i].timeSent ??
                                        '0') *
                                1000);

                        return MessageBubble(
                            currentUserId: widget.currentUser?.id ?? 0,
                            chatItem: getOpenedChat()?.messages?[i],
                            timestamp: timestamp);
                      },
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 15);
                      },
                      itemCount: getOpenedChat()?.messages?.length ?? 0),
                ),
                const SizedBox(height: 15),
                IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Flexible(
                        flex: 4,
                        child: TextField(
                          controller: _messageTextController,
                          onSubmitted: (value) {
                            sendMessage(_messageTextController.text.trim());
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Message',
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () {
                            sendMessage(_messageTextController.text.trim());
                          },
                          child: const Text('Send'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
            if (widget.chatList != null) ...[
              const SizedBox(height: 30),
              Text(
                'Chats',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Below are some of your recent chats. Tap on any of them to open it.',
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 15),
              Container(
                height: 250,
                child: ListView.separated(
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 15);
                  },
                  itemCount: widget.chatList?.chats?.length ?? 0,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () async {
                        final messages = await widget.chatService?.getMessages(
                          -1 * widget.chatList!.chats![index].id!,
                          0,
                          100,
                        );

                        setState(() {
                          openedChatId = widget.chatList?.chats?[index].id;

                          if (messages != null) {
                            getOpenedChat()?.messages = messages
                                .where((e) => e.content is api.MessageText)
                                .map((e) => ChatItem(
                                    (e.content as api.MessageText).text.text,
                                    (e.senderId as api.MessageSenderUser)
                                        .userId
                                        .toString(),
                                    e.date.toString()))
                                .toList()
                                .reversed
                                .toList();
                          }
                        });
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            color: Colors.blue),
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Chat',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'chat_id: ${widget.chatList?.chats?[index].id.toString() ?? ''}',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'member_count: ${widget.chatList?.chats?[index].memberCount.toString() ?? ''}',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 15),
              IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Flexible(
                      flex: 4,
                      child: TextField(
                        controller: _chatIdTextController,
                        onSubmitted: (value) {
                          joinChat(_chatIdTextController.text.trim());
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Chat ID',
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () {
                          sendMessage(_messageTextController.text.trim());
                        },
                        child: const Text('Join'),
                      ),
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    required this.currentUserId,
    required this.chatItem,
    required this.timestamp,
  });

  final int currentUserId;
  final ChatItem? chatItem;
  final DateTime timestamp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(
          left: currentUserId == int.parse(chatItem?.sender ?? '') ? 100 : 0,
          right: currentUserId == int.parse(chatItem?.sender ?? '') ? 0 : 100),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: currentUserId == int.parse(chatItem?.sender ?? '')
            ? Colors.blue
            : Color.fromARGB(255, 45, 158, 0),
      ),
      child: IntrinsicHeight(
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '${chatItem?.content}',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'from ${chatItem?.sender}',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
                Text(
                  '@ ${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute}',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
