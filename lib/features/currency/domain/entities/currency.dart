import 'package:flutter/foundation.dart';

/// Currency entity representing a currency in the domain layer.
///
/// This is a pure domain object with no dependencies on external
/// frameworks or data sources.
@immutable
class Currency {
  /// Creates a new [Currency] instance.
  const Currency({
    required this.code,
    required this.name,
    this.flagUrl,
  });

  /// The currency code (e.g., 'USD', 'EUR').
  final String code;

  /// The full name of the currency (e.g., 'United States Dollar').
  final String name;

  /// The URL of the country flag image.
  final String? flagUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Currency &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          name == other.name &&
          flagUrl == other.flagUrl;

  @override
  int get hashCode => code.hashCode ^ name.hashCode ^ flagUrl.hashCode;

  @override
  String toString() => 'Currency(code: $code, name: $name, flagUrl: $flagUrl)';
}
