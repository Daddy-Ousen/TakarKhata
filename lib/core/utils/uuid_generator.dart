import 'package:uuid/uuid.dart';

/// Centralized UUID generation for the application.
///
/// All entity identifiers use UUID v4 (random) to ensure uniqueness
/// across devices for offline-first synchronization.
class UuidGenerator {
  static const Uuid _uuid = Uuid();

  UuidGenerator._();

  /// Generate a new UUID v4 string.
  static String generate() => _uuid.v4();

  /// Validate whether a string is a valid UUID.
  static bool isValid(String value) {
    return Uuid.isValidUUID(fromString: value);
  }
}
