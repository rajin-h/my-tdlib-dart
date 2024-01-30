import 'package:tdlib/td_api.dart' as td;
import 'package:flutter/material.dart';
import 'package:tdlib/td_api.dart' hide Text;
import 'package:tdlib/td_client.dart';

class CodeVerificationSection extends StatefulWidget {
  const CodeVerificationSection({
    required this.client,
    required this.authorizationState,
  });

  final Client? client;
  final AuthorizationState? authorizationState;

  @override
  State<CodeVerificationSection> createState() =>
      _CodeVerificationSectionState();
}

class _CodeVerificationSectionState extends State<CodeVerificationSection> {
  TextEditingController _codeTextController = TextEditingController();

  @override
  void dispose() {
    _codeTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _codeTextController,
          decoration: new InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Verification Code',
          ),
        ),
        const SizedBox(height: 15),
        ElevatedButton(
          onPressed: () async {
            if (widget.authorizationState is td.AuthorizationStateWaitCode) {
              await widget.client?.send(
                td.CheckAuthenticationCode(
                  code: _codeTextController.text.trim(),
                ),
              );
            }
          },
          child: const Text('Authenticate'),
        ),
      ],
    );
  }
}
