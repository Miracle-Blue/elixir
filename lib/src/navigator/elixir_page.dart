import 'package:flutter/foundation.dart' show shortHash;
import 'package:flutter/material.dart';

/// {@template elixir_page}
/// Elixir page.
/// {@endtemplate}
@immutable
abstract base class ElixirPage extends Page<void> {
  /// {@macro elixir_page}
  const ElixirPage({
    required super.name,
    required this.child,
    required Map<String, Object?>? super.arguments,
    super.key,
  });

  /// The child widget.
  final Widget child;

  /// Tags of the page.
  abstract final Set<String> tags;

  /// Alias of the page.
  abstract final ElixirAlias alias;

  @override
  Route<void> createRoute(BuildContext context) => MaterialPageRoute(builder: (context) => child, settings: this);

  @override
  String get name => alias.alias;

  @override
  LocalKey get key => switch ((super.key, super.arguments)) {
    (LocalKey key, _) => key,
    (_, Map<String, Object?> arguments) => ValueKey('$name#${shortHash(arguments)}'),
    _ => ValueKey<String>(name),
  };

  @override
  Map<String, Object?> get arguments => switch (super.arguments) {
    Map<String, Object?> args when args.isNotEmpty => args,
    _ => const <String, Object?>{},
  };

  @override
  int get hashCode => Object.hashAll([key, name]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ElixirPage && key == other.key && name == other.name;
}

/// Elixir alias.
///
/// ```dart
/// enum Routes implements ElixirAlias, Comparable< Routes > {
///   home('home'),
///   settings('settings');
///
///   /// {@macro routes}
///   const Routes(this.value);
///
///   /// Value of the enum
///   final String value;
///
///   @override
///   String get alias => value;
///
///   @override
///   int compareTo(Routes other) => index.compareTo(other.index);
///
///   @override
///   String toString() => value;
/// }
/// ```
/// Alias must be unique and immutable.
abstract interface class ElixirAlias {
  /// Alias of the page.
  String get alias;
}
