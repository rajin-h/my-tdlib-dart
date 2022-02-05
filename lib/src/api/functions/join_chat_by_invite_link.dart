import '../tdapi.dart';

/// Uses an invite link to add the current user to the chat if possible
/// Returns [Chat]
class JoinChatByInviteLink extends TdFunction {
  JoinChatByInviteLink({required this.inviteLink});

  /// [inviteLink] Invite link to use
  final String inviteLink;

  static const String CONSTRUCTOR = 'joinChatByInviteLink';

  @override
  String getConstructor() => CONSTRUCTOR;
  @override
  Map<String, dynamic> toJson() =>
      {'invite_link': this.inviteLink, '@type': CONSTRUCTOR};
}