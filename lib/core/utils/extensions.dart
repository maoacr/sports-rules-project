import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// String extensions.
extension StringExtensions on String {
  /// Returns the string truncated to [maxLength] with '...' appended.
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  /// Capitalizes the first letter of the string.
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Returns true if the string is a valid email address.
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  /// Converts the string to a URL-safe slug.
  String toSlug() {
    return toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').trim();
  }
}

/// DateTime extensions.
extension DateTimeExtensions on DateTime {
  /// Formats the date as a readable string (e.g., "Jun 15, 2026").
  String toFormattedDate() {
    return DateFormat.yMMMd().format(this);
  }

  /// Formats the date as a relative time string (e.g., "2 days ago").
  String toRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  /// Returns true if the date is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}

/// BuildContext extensions.
extension ContextExtensions on BuildContext {
  /// Returns the screen width.
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Returns the screen height.
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Returns the screen padding.
  EdgeInsets get screenPadding => MediaQuery.of(this).padding;

  /// Returns the text theme.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Returns the color scheme.
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Shows a snackbar with the given [message].
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Nullable String extensions.
extension NullableStringExtensions on String? {
  /// Returns true if the string is null or empty.
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Returns true if the string is not null and not empty.
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;
}

/// List extensions.
extension ListExtensions<T> on List<T> {
  /// Returns the element at [index] or null if out of bounds.
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
}
