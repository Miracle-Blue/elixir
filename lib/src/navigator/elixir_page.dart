import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
abstract class ElixirPage extends Page<void> {
  const ElixirPage({
    required String super.name,
    required this.child,
    required Map<String, Object?>? super.arguments,
    super.key,
  });

  final Widget child;

  abstract final Set<String> tags;

  @override
  String get name => super.name ?? 'Unknown';

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
  int get hashCode => key.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ElixirPage && key == other.key;
}
