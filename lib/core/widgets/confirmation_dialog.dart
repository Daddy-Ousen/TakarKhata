import 'package:flutter/material.dart';

import '../theme/color_schemes.dart';
import '../theme/text_styles.dart';

/// A reusable Material 3 confirmation dialog for destructive or important
/// actions throughout the KhataBook application.
///
/// Displays a title, descriptive message, and two action buttons (cancel and
/// confirm). When [isDestructive] is `true`, the confirm button uses the
/// expense/error color to signal a dangerous action (e.g., delete, reset).
///
/// ## Usage
/// ```dart
/// final confirmed = await ConfirmationDialog.show(
///   context: context,
///   title: 'Delete Transaction',
///   message: 'This action cannot be undone. Are you sure?',
///   confirmText: 'Delete',
///   isDestructive: true,
/// );
/// if (confirmed) { /* proceed */ }
/// ```
class ConfirmationDialog extends StatelessWidget {
  /// Creates a [ConfirmationDialog].
  const ConfirmationDialog({
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.isDestructive = false,
    super.key,
  });

  /// The dialog headline.
  final String title;

  /// Descriptive body text explaining the action.
  final String message;

  /// Label for the confirm/action button.
  final String confirmText;

  /// Label for the cancel button.
  final String cancelText;

  /// When `true`, the confirm button is styled with [AppColors.expense]
  /// to indicate a destructive / irreversible action.
  final bool isDestructive;

  /// Convenience method to show the dialog and return the user's decision.
  ///
  /// Returns `true` if the user tapped the confirm button, `false` if
  /// they cancelled or dismissed the dialog.
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final confirmColor =
        isDestructive ? AppColors.expense : AppColors.income;

    return AlertDialog(
      title: Text(
        title,
        style: AppTextStyles.titleLarge,
      ),
      content: Text(
        message,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            cancelText,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: confirmColor,
            foregroundColor: isDestructive
                ? Colors.white
                : AppColors.backgroundDark,
          ),
          child: Text(confirmText),
        ),
      ],
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actionsAlignment: MainAxisAlignment.end,
    );
  }
}
