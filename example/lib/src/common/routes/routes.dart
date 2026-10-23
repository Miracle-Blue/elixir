import 'package:elixir/elixir.dart';
import 'package:flutter/material.dart';

import '../../feature/home/home_screen.dart';
import '../../feature/settings/settings_dialog.dart';
import '../../feature/settings/settings_scope.dart';
import '../../feature/settings/settings_screen.dart';
import 'custom_route_transitions.dart';

enum AppRoutes implements ElixirAlias, Comparable<AppRoutes> {
  // this is the root not uses for routing
  app('app'),
  // these are the pages in the root
  home('home'),
  settings('settings_scope');

  const AppRoutes(this.value);

  final String value;

  @override
  String get alias => value;

  @override
  int compareTo(AppRoutes other) => index.compareTo(other.index);

  @override
  String toString() => value;
}

/// Type definition for the page.
@immutable
sealed class AppPage extends ElixirPage {
  const AppPage({required super.name, required super.child, super.arguments, super.key});

  @override
  Route<void> createRoute(BuildContext context) => MaterialPageRoute(builder: (context) => child, settings: this);

  @override
  int get hashCode => key.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AppPage && key == other.key;

  @override
  String toString() => '/$name${arguments.isEmpty ? '' : '~$arguments'}';
}

final class HomePage extends AppPage {
  const HomePage() : super(child: const HomeScreen(), name: 'home');

  @override
  Set<String> get tags => {'home'};

  @override
  ElixirAlias get alias => AppRoutes.home;
}

final class SettingsScopePage extends AppPage {
  SettingsScopePage({required final String data}) : super(child: SettingsScope(data: data), name: 'settings_scope');

  // @override
  // Route<void> createRoute(BuildContext context) => CustomMaterialRoute(page: this);

  @override
  Set<String> get tags => {'settings_scope'};

  @override
  ElixirAlias get alias => AppRoutes.settings;
}

/// *** ========================= Settings Scope =========================

/// {@template routes}
/// Routes enumeration
/// {@endtemplate}
enum Settings implements ElixirAlias, Comparable<Settings> {
  settings('settings'),
  settingsDialog('settings_dialog');

  const Settings(this.value);

  /// Value of the enum
  final String value;

  @override
  String get alias => value;

  @override
  int compareTo(Settings other) => index.compareTo(other.index);

  @override
  String toString() => value;
}

final class SettingsPage extends AppPage {
  SettingsPage({required final String data}) : super(child: SettingsScreen(data: data), name: 'settings');

  @override
  Route<void> createRoute(BuildContext context) => CustomMaterialRoute(page: this);

  @override
  Set<String> get tags => {'settings'};

  @override
  ElixirAlias get alias => Settings.settings;
}

final class SettingsDialogPage extends AppPage {
  const SettingsDialogPage() : super(child: const SettingsDialog(), name: 'settings_dialog');

  @override
  Route<void> createRoute(BuildContext context) =>
      DialogRoute(context: context, settings: this, builder: (context) => child);

  @override
  Set<String> get tags => {'settings_dialog'};

  @override
  ElixirAlias get alias => Settings.settingsDialog;
}
