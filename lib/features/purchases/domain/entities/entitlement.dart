import 'package:equatable/equatable.dart';

/// Entitlement entity representing a RevenueCat purchase entitlement.
class Entitlement extends Equatable {
  final String identifier;
  final bool isActive;
  final String? productId;

  /// ISO-8601 string for the entitlement expiration date, or null if
  /// non-expiring. The `purchases_flutter` 7.x SDK exposes this as
  /// `String?`; callers can parse it to `DateTime` if needed.
  final String? expiresDate;

  const Entitlement({
    required this.identifier,
    required this.isActive,
    this.productId,
    this.expiresDate,
  });

  @override
  List<Object?> get props => [identifier, isActive, productId, expiresDate];
}
