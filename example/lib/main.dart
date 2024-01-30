import 'dart:async';
import 'dart:io';
import 'package:example/models/chat.dart';
import 'package:example/models/user.dart';
import 'package:example/services/chat_service.dart';
import 'package:example/widgets/code_verification_section.dart';
import 'package:example/widgets/main_chat_section.dart';
import 'package:example/widgets/mobile_number_section.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tdlib/td_api.dart' as td;
import 'package:tdlib/td_client.dart';

Future<void> main() async {
  runApp(
    const MaterialApp(
      home: MyApp(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Client? _client;

  StreamSubscription<td.TdObject>? _eventsSubscription;

  td.TdObject? _lastEvent;
  td.AuthorizationState? _authorizationState;
  td.ConnectionState? _connectionState;

  ChatService? _chatService;

  User? _userData;
  ChatList? _chatData;

  @override
  void dispose() {
    _destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('event: _chatData ${_chatData}');
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: <Widget>[
              ListTile(
                title: ListBody(
                  children: [
                    if (_userData != null) ...[
                      MainChatSection(
                        currentUser: _userData,
                        client: _client,
                        chatService: _chatService,
                        chatList: _chatData,
                      ),
                    ],
                    if (_authorizationState
                        is td.AuthorizationStateWaitPhoneNumber) ...[
                      MobileNumberSection(
                        client: _client,
                        authorizationState: _authorizationState,
                      ),
                      const SizedBox(height: 15),
                    ],
                    if (_authorizationState is td.AuthorizationStateWaitCode)
                      CodeVerificationSection(
                        client: _client,
                        authorizationState: _authorizationState,
                      ),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text('last event'),
                subtitle: Text('${_lastEvent?.toJson()}'),
              ),
              ListTile(
                title: const Text('authorizationState'),
                subtitle: Text('${_authorizationState?.runtimeType}'),
              ),
              ListTile(
                title: const Text('connectionState'),
                subtitle: Text('${_connectionState?.runtimeType}'),
              ),
              const Divider(),
              ListTile(
                title: const Text('initialize'),
                onTap: _initialize,
              ),
              ListTile(
                title: const Text('destroy'),
                onTap: _destroy,
              ),
              const Divider(),
              ListTile(
                title: const Text('set network none'),
                onTap: () {
                  _client?.send(
                    const td.SetNetworkType(type: td.NetworkTypeNone()),
                  );
                },
              ),
              ListTile(
                title: const Text('set network wifi'),
                onTap: () {
                  _client?.send(
                    const td.SetNetworkType(type: td.NetworkTypeWiFi()),
                  );
                },
              ),
              ListTile(
                title:
                    const Text('logout', style: TextStyle(color: Colors.red)),
                onTap: () {
                  _client?.send(const td.LogOut());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onNewEvent(td.TdObject event) async {
    if (event is td.UpdateConnectionState) {
      setState(() {
        _connectionState = event.state;
      });
    }

    if (event is td.UpdateBasicGroup) {
      if (_chatData?.chats == null) {
        setState(() {
          _chatData = ChatList([]);
        });
      }

      if (_chatData!.chats!.every((e) => e.id != event.basicGroup.id)) {
        final chatdata = await _chatService?.getChatData(event.basicGroup.id);

        if (chatdata != null) {
          setState(() {
            _chatData!.chats!.add(chatdata);
          });
        }
      }
    }

    if (event is td.UpdateUser) {
      final user = await _chatService?.getUser(event.user.id);

      setState(() {
        _userData = User(user?.id, user?.firstName, user?.lastName);
      });
    } else if (event is td.UpdateOption) {
      if (event.name == "my_id") {
        final val = event.value.toJson();
        int id = int.parse(val['value']);
        final user = await _chatService?.getUser(id);

        setState(() {
          _userData = User(user?.id, user?.firstName, user?.lastName);
        });
      }
    }

    print('event: ${event.toJson()}');

    setState(() {
      _lastEvent = event;
    });
    if (event is td.UpdateAuthorizationState) {
      await _onAuthorizationState(event.authorizationState);
    }
  }

  Future<void> _onAuthorizationState(
    td.AuthorizationState authorizationState,
  ) async {
    setState(() {
      _authorizationState = authorizationState;
    });
    if (authorizationState is td.AuthorizationStateWaitTdlibParameters) {
      await _client?.send(
        td.SetTdlibParameters(
          systemVersion: '',
          useTestDc: false,
          useSecretChats: false,
          useMessageDatabase: true,
          useFileDatabase: true,
          useChatInfoDatabase: true,
          ignoreFileNames: true,
          enableStorageOptimizer: true,
          filesDirectory: await _getFilesDirectory(),
          databaseDirectory: await _getDatabaseDirectory(),
          systemLanguageCode: 'en',
          deviceModel: 'unknown',
          applicationVersion: '1.0.0',
          apiId: 25016349,
          apiHash: '204b31a82be0f184092705e8254a87ba',
          databaseEncryptionKey: '',
        ),
      );
    }
  }

  void _initialize() {
    if (_client != null) {
      return;
    }

    final Client newClient = Client.create();
    _client = newClient;
    _chatService = ChatService(newClient);
    _eventsSubscription?.cancel();
    _eventsSubscription = newClient.updates.listen(_onNewEvent);
    newClient.initialize();
  }

  void _destroy() {
    _client?.destroy();
    _eventsSubscription?.cancel();
    _client = null;
    _chatService = null;

    setState(() {
      _connectionState = null;
      _lastEvent = null;
      _authorizationState = null;
    });
  }

  Future<String> _getFilesDirectory() async {
    if (kIsWeb) {
      return 'files';
    }
    final Directory applicationSupportDirectory =
        await getApplicationSupportDirectory();

    return '${applicationSupportDirectory.path}/files';
  }

  Future<String> _getDatabaseDirectory() async {
    if (kIsWeb) {
      return 'database';
    }
    final Directory applicationSupportDirectory =
        await getApplicationSupportDirectory();

    return '${applicationSupportDirectory.path}/database';
  }
}
