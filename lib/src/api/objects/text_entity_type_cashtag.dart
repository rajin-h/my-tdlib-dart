import '../tdapi.dart';

/// A cashtag text, beginning with "$" and consisting of capital English
/// letters (e.g., "$USD")
class TextEntityTypeCashtag extends TextEntityType {
  const TextEntityTypeCashtag();

  static const String CONSTRUCTOR = 'textEntityTypeCashtag';

  static TextEntityTypeCashtag? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }

    return const TextEntityTypeCashtag();
  }

  @override
  String getConstructor() => CONSTRUCTOR;
  @override
  Map<String, dynamic> toJson() => {'@type': CONSTRUCTOR};
}