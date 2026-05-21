/// Error types used across the application.
///
/// [Failure] is a sealed class hierarchy representing business-logic
/// errors that are returned from repositories and services.
sealed class Failure {
  final String message;
  final String? details;

  const Failure(this.message, {this.details});

  @override
  String toString() => '$runtimeType: $message${details != null ? ' ($details)' : ''}';
}

/// A failure originating from the database layer.
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.details});
}

/// A failure caused by invalid user input or business rule violations.
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure(super.message, {super.details, this.fieldErrors});
}

/// A failure during data synchronization.
class SyncFailure extends Failure {
  const SyncFailure(super.message, {super.details});
}

/// A failure when a requested entity was not found.
class NotFoundFailure extends Failure {
  final String entityType;
  final String entityId;

  const NotFoundFailure({
    required this.entityType,
    required this.entityId,
  }) : super('$entityType with ID $entityId not found');
}

/// A failure caused by insufficient balance for a transaction.
class InsufficientBalanceFailure extends Failure {
  final int currentBalance;
  final int requiredAmount;

  const InsufficientBalanceFailure({
    required this.currentBalance,
    required this.requiredAmount,
  }) : super('Insufficient balance');
}
