import '../tdapi.dart';

/// A file generated by the application
class InputFileGenerated extends InputFile {
  InputFileGenerated(
      {required this.originalPath,
      required this.conversion,
      required this.expectedSize});

  /// [originalPath] Local path to a file from which the file is generated; may
  /// be empty if there is no such file
  final String originalPath;

  /// [conversion] String specifying the conversion applied to the original
  /// file; must be persistent across application restarts. Conversions
  /// beginning with '#' are reserved for internal TDLib usage
  final String conversion;

  /// [expectedSize] Expected size of the generated file, in bytes; 0 if unknown
  final int expectedSize;

  static const String CONSTRUCTOR = 'inputFileGenerated';

  static InputFileGenerated? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }

    return InputFileGenerated(
        originalPath: json['original_path'],
        conversion: json['conversion'],
        expectedSize: json['expected_size']);
  }

  @override
  String getConstructor() => CONSTRUCTOR;
  @override
  Map<String, dynamic> toJson() => {
        'original_path': this.originalPath,
        'conversion': this.conversion,
        'expected_size': this.expectedSize,
        '@type': CONSTRUCTOR
      };
}