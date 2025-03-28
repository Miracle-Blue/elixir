import 'package:example/src/feature/home/home_screen.dart';
import 'package:example/src/feature/settings/settings_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Just for example, as one of possible ways to
/// represent the pages/routes in the app.
enum Routes {
  home,
  settings;

  const Routes();

  /// Converts the route to a [MaterialPage].
  Page<Object?> page({Map<String, Object?>? arguments, LocalKey? key}) => MaterialPage<void>(
    name: name,
    arguments: arguments,
    key: switch ((key, arguments)) {
      (LocalKey key, _) => key,
      (_, Map<String, Object?> arguments) => ValueKey('$name#${shortHash(arguments)}'),
      _ => ValueKey<String>(name),
    },
    child: switch (this) {
      Routes.home => const HomeScreen(),
      Routes.settings => const SettingsScreen(),
    },
  );
}
