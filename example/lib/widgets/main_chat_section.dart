import 'package:example/models/chat.dart';
import 'package:example/models/user.dart';
import 'package:example/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:tdlib/td_client.dart';

class MainChatSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User ID:  ${currentUser?.id?.toString()}',
              style: TextStyle(fontSize: 15),
            ),
            Text(
              'Name:  ${currentUser?.firstName?.toString()} ${currentUser?.lastName?.toString()}',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                chatService?.getChats(10);
              },
              child: const Text('get chats'),
            ),
            if (chatList != null) ...[
              const SizedBox(height: 15),
              Container(
                height: 300,
                child: ListView.separated(
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 15);
                  },
                  itemCount: chatList?.chats?.length ?? 0,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () async {
                        await chatService?.getMessages(
                          -1 * chatList!.chats![index].id!,
                          0,
                          10,
                        );
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            color: Colors.amberAccent),
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                                'chat id: ${chatList?.chats?[index].id.toString() ?? ''}'),
                            Text(
                                'member count: ${chatList?.chats?[index].memberCount.toString() ?? ''}'),
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
