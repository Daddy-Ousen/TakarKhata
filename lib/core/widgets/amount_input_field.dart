import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/color_schemes.dart';
import '../theme/text_styles.dart';

/// A specialized [TextFormField] for monetary input in the KhataBook app.
///
/// Features:
/// - Accepts only digits and a single decimal point
/// - Auto-formats with commas as the user types (Indian/international)
/// - Displays a configurable currency symbol as a prefix
/// - Validates against a configurable maximum amount
/// - Communicates values in **cents** (integer) to match the app's
///   convention of storing all monetary values as `int`
///
/// ## Usage
/// ```dart
/// AmountInputField(
///   initialCents: 150000, // ৳1,500.00
///   onChanged: (cents) => setState(() => _amount = cents),
///   currencySymbol: '৳',
/// )
/// ```
class AmountInputField extends StatefulWidget {
  /// Creates an [AmountInputField].
  const AmountInputField({
    this.initialCents,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.currencySymbol = '৳',
    this.maxCents = 99999999999, // 999,999,999.99
    this.label,
    this.hint = '0.00',
    this.enabled = true,
    this.autofocus = false,
    super.key,
  });

  /// Initial value in cents. `150000` → displays as `1,500.00`.
  final int? initialCents;

  /// Called on every valid change with the current value in cents.
  final ValueChanged<int>? onChanged;

  /// Called when the form is saved with the current value in cents.
  final ValueChanged<int?>? onSaved;

  /// Optional extra validator. Return a non-null string on error.
  final String? Function(int? cents)? validator;

  /// Currency symbol shown as a prefix. Defaults to `'৳'` (Taka).
  final String currencySymbol;

  /// Maximum allowed value in cents.
  final int maxCents;

  /// Optional label text displayed above the field.
  final String? label;

  /// Hint text displayed when the field is empty.
  final String hint;

  /// Whether the field accepts input.
  final bool enabled;

  /// Whether to auto-focus when the widget is first inserted.
  final bool autofocus;

  @override
  State<AmountInputField> createState() => _AmountInputFieldState();
}

class _AmountInputFieldState extends State<AmountInputField> {
  late final TextEditingController _controller;
  int _currentCents = 0;

  @override
  void initState() {
    super.initState();
    _currentCents = widget.initialCents ?? 0;
    _controller = TextEditingController(
      text: _currentCents > 0 ? _centsToDisplay(_currentCents) : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Formatting helpers
  // ---------------------------------------------------------------------------

  /// Converts a cents integer to a formatted display string.
  ///
  /// Example: `150025` → `'1,500.25'`
  String _centsToDisplay(int cents) {
    final whole = cents ~/ 100;
    final fraction = cents % 100;
    final wholeFormatted = _addCommas(whole.toString());
    return '$wholeFormatted.${fraction.toString().padLeft(2, '0')}';
  }

  /// Adds comma thousand-separators to a numeric string.
  String _addCommas(String digits) {
    if (digits.length <= 3) return digits;

    final buffer = StringBuffer();
    var count = 0;
    for (var i = digits.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(digits[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join();
  }

  /// Parses a display string back to cents.
  ///
  /// Returns `0` for empty / invalid input.
  int _displayToCents(String text) {
    final cleaned = text.replaceAll(',', '');
    if (cleaned.isEmpty) return 0;

    final parts = cleaned.split('.');
    final wholePart = int.tryParse(parts[0]) ?? 0;

    int fractionPart = 0;
    if (parts.length > 1) {
      // Pad or truncate to exactly 2 decimal places.
      final frac = parts[1].padRight(2, '0').substring(0, math.min(parts[1].length, 2));
      fractionPart = int.tryParse(frac.padRight(2, '0')) ?? 0;
    }

    return (wholePart * 100) + fractionPart;
  }

  /// Strips formatting, re-formats, and repositions the cursor.
  void _onTextChanged(String value) {
    // Strip all commas for processing.
    final raw = value.replaceAll(',', '');

    // Allow empty field.
    if (raw.isEmpty) {
      _currentCents = 0;
      widget.onChanged?.call(0);
      return;
    }

    // If the user is typing a decimal point, don't reformat yet.
    if (raw.endsWith('.')) {
      _currentCents = _displayToCents(raw);
      widget.onChanged?.call(_currentCents);
      return;
    }

    // If there's a fractional part being typed (e.g., "12.3"), only
    // reformat the whole part to preserve cursor intent.
    final parts = raw.split('.');
    final wholeFormatted = _addCommas(parts[0]);

    String formatted;
    if (parts.length > 1) {
      // Limit to 2 decimal digits.
      final frac = parts[1].substring(0, math.min(parts[1].length, 2));
      formatted = '$wholeFormatted.$frac';
    } else {
      formatted = wholeFormatted;
    }

    // Only update the controller if the text actually changed to avoid
    // infinite loops.
    if (formatted != value) {
      final cursorOffset = formatted.length;
      _controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: cursorOffset),
      );
    }

    _currentCents = _displayToCents(formatted);
    widget.onChanged?.call(_currentCents);
  }

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  String? _validate(String? value) {
    final cents = _displayToCents(value ?? '');

    if (cents <= 0) {
      return 'Please enter a valid amount';
    }

    if (cents > widget.maxCents) {
      final maxDisplay = _centsToDisplay(widget.maxCents);
      return 'Amount cannot exceed ${widget.currencySymbol}$maxDisplay';
    }

    return widget.validator?.call(cents);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.start,
      style: AppTextStyles.transactionAmount,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
        _SingleDecimalPointFormatter(),
      ],
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Text(
            widget.currencySymbol,
            style: AppTextStyles.currencySymbol.copyWith(
              color: AppColors.income,
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 0,
          minHeight: 0,
        ),
      ),
      onChanged: _onTextChanged,
      validator: _validate,
      onSaved: (_) => widget.onSaved?.call(_currentCents),
    );
  }
}

/// Input formatter that ensures at most one decimal point exists in the text
/// and limits decimal digits to 2.
class _SingleDecimalPointFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Allow empty.
    if (text.isEmpty) return newValue;

    // Count decimal points.
    final dotCount = '.'.allMatches(text).length;
    if (dotCount > 1) return oldValue;

    // Limit to 2 decimal digits.
    if (dotCount == 1) {
      final parts = text.split('.');
      if (parts.length == 2 && parts[1].length > 2) {
        return oldValue;
      }
    }

    return newValue;
  }
}
