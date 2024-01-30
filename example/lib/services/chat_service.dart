import 'package:example/models/chat.dart';
import 'package:tdlib/td_api.dart' as td;
import 'package:tdlib/td_client.dart';

/// NOTE: this chat service currently utilises Basic Group chats
/// there are three separate types including Super Groups etc. (read more: https://core.telegram.org/tdlib/getting-started)

class ChatService {
  final Client _client;

  const ChatService(this._client);

  /// get user data
  Future<td.User?> getUser(int userId) async {
    final td.User? user = await _client.send(td.GetMe());
    return user;
  }

  /// join chat
  Future<void> joinChat(int chatId) async {
    _client.send(td.JoinChat(chatId: chatId));
  }

  /// leave chat
  Future<void> leaveChat(int chatId) async {
    _client.send(td.LeaveChat(chatId: chatId));
  }

  // send message to a chat
  Future<void> sendMessage(int chatId, String text) async {
    _client.send(
      td.SendMessage(
        chatId: chatId,
        messageThreadId: 0,
        inputMessageContent: td.InputMessageText(
          clearDraft: true,
          text: td.FormattedText(text: text, entities: []),
        ),
      ),
    );
  }

  // paginate and get all messages in a chat
  Future<List<td.Message>> getMessages(
    int chatId,
    int fromMessageId,
    int limit,
  ) async {
    final List<td.Message> messages =
        await _getMessages(chatId, fromMessageId, limit);
    if (messages.isNotEmpty && messages.length != limit) {
      final List<td.Message> additionalMessages = await getMessages(
        chatId,
        messages.last.id,
        limit,
      );
      return messages..addAll(additionalMessages);
    }

    return messages;
  }

  /// get chat messages
  Future<List<td.Message>> _getMessages(
    int chatId,
    int fromMessageId,
    int limit,
  ) async {
    final td.Messages messages = await _client.send(
      td.GetChatHistory(
        chatId: chatId,
        fromMessageId: fromMessageId,
        offset: 0,
        limit: limit,
        onlyLocal: false,
      ),
    );

    return messages.messages ?? [];
  }

  /// create chat
  Future<int> createChat(
      String name, String description, List<int> members) async {
    final td.Chat chat = await _client.send(
      td.CreateNewBasicGroupChat(
        title: name,
        userIds: members,
        messageAutoDeleteTime: 0,
      ),
    );

    return chat.id;
  }

  /// get and load chats into local cache
  Future<void> getChats(int limit) async {
    await _client.send(td.LoadChats(limit: limit));
  }

  /// get specific data about chat messages
  Future<Chat> getChatData(int chatId) async {
    final td.BasicGroup? val =
        await _client.send(td.GetBasicGroup(basicGroupId: chatId));
    return Chat(val?.id, null, val?.memberCount);
  }
}
