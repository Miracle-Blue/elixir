import 'package:example/src/feature/home/home_screen.dart';
import 'package:example/src/feature/settings/settings_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Type definition for the page.
@immutable
sealed class AppPage extends MaterialPage<void> {
  const AppPage({
    required String super.name,
    required super.child,
    required Map<String, Object?>? super.arguments,
    super.key,
  });

  @override
  String get name => super.name ?? 'Unknown';

  abstract final Set<String> tags;

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
  bool operator ==(Object other) => identical(this, other) || other is AppPage && key == other.key;
}

final class HomePage extends AppPage {
  const HomePage({super.arguments}) : super(child: const HomeScreen(), name: 'home_page');

  @override
  Set<String> get tags => {'home'};
}

final class SettingsPage extends AppPage {
  SettingsPage({required final String data, super.arguments})
    : super(child: SettingsScreen(data: data), name: 'settings_page');

  @override
  Set<String> get tags => {'settings'};
}
