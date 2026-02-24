import 'package:flutter/foundation.dart' show shortHash;
import 'package:flutter/material.dart';

@immutable
abstract base class ElixirPage extends Page<void> {
  const ElixirPage({
    required super.name,
    required this.child,
    required Map<String, Object?>? super.arguments,
    super.key,
  });

  final Widget child;

  abstract final Set<String> tags;

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

abstract interface class ElixirAlias {
  String get alias;
}
