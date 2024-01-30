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
  Chat? openedChat;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User ID:  ${widget.currentUser?.id?.toString()}',
              style: TextStyle(fontSize: 15),
            ),
            Text(
              'Name:  ${widget.currentUser?.firstName?.toString()} ${widget.currentUser?.lastName?.toString()}',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                widget.chatService?.getChats(10);
              },
              child: const Text('get chats'),
            ),
            if (openedChat != null) ...[
              const SizedBox(height: 15),
              Text(
                'Chat Name:  ${openedChat?.name?.toString()}',
                style: TextStyle(fontSize: 15),
              ),
              if (openedChat?.messages != null) ...[
                for (int i = 0; i < openedChat!.messages!.length; i++) ...[
                  Container(
                    color: Colors.amberAccent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '${openedChat?.messages?[i].content}',
                          style: TextStyle(fontSize: 15),
                        ),
                        Text(
                          'from ${openedChat?.messages?[i].sender}',
                          style: TextStyle(fontSize: 15),
                        ),
                        Text(
                          '@ ${openedChat?.messages?[i].timeSent}',
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ],
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Message',
                  ),
                  onSubmitted: (value) async {
                    await widget.chatService?.sendMessage(
                      (-1 * openedChat!.id!),
                      value,
                    );
                  },
                ),
              ],
            ],
            if (widget.chatList != null) ...[
              const SizedBox(height: 15),
              Container(
                height: 300,
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
                          10,
                        );

                        setState(() {
                          openedChat = widget.chatList?.chats?[index];

                          if (messages != null) {
                            openedChat?.name = messages
                                .map(
                                  (e) => e.content
                                          is api.MessageBasicGroupChatCreate
                                      ? (e.content as api
                                              .MessageBasicGroupChatCreate)
                                          .title
                                      : '',
                                )
                                .toList()
                                .firstWhere((e) => e.isNotEmpty);

                            openedChat?.messages = messages
                                .where((e) => e.content is api.MessageText)
                                .map((e) => ChatItem(
                                    (e.content as api.MessageText).text.text,
                                    (e.senderId as api.MessageSenderUser)
                                        .userId
                                        .toString(),
                                    e.date.toString()))
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
                              ),
                            ),
                            Text(
                                'chat_id: ${widget.chatList?.chats?[index].id.toString() ?? ''}'),
                            Text(
                                'member_count: ${widget.chatList?.chats?[index].memberCount.toString() ?? ''}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
