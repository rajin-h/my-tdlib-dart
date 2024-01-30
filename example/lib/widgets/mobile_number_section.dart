import 'package:flutter/material.dart';
import 'package:tdlib/td_api.dart' hide Text;
import 'package:tdlib/td_client.dart';
import 'package:tdlib/td_api.dart' as td;

class MobileNumberSection extends StatefulWidget {
  const MobileNumberSection({
    required this.client,
    required this.authorizationState,
  });

  final Client? client;
  final AuthorizationState? authorizationState;

  @override
  State<MobileNumberSection> createState() => _MobileNumberSectionState();
}

class _MobileNumberSectionState extends State<MobileNumberSection> {
  TextEditingController _mobileNumberTextController = TextEditingController();

  @override
  void dispose() {
    _mobileNumberTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _mobileNumberTextController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Mobile Number',
          ),
        ),
        const SizedBox(height: 15),
        ElevatedButton(
          onPressed: () async {
            if (widget.authorizationState
                is td.AuthorizationStateWaitPhoneNumber) {
              await widget.client?.send(
                td.SetAuthenticationPhoneNumber(
                  phoneNumber: _mobileNumberTextController.text.trim(),
                ),
              );
            }
          },
          child: const Text('Get Code'),
        ),
      ],
    );
  }
}
