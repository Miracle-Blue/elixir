import 'package:elixir/elixir.dart';
import 'package:flutter/material.dart';

import '../../feature/home/home_screen.dart';
import '../../feature/settings/settings_screen.dart';
import 'custom_route_transitions.dart';

/// {@template routes}
/// Routes enumeration
/// {@endtemplate}
enum Routes implements ElixirAlias, Comparable<Routes> {
  home('home'),
  settings('settings');

  /// {@macro routes}
  const Routes(this.value);

  /// Value of the enum
  final String value;

  @override
  String get alias => value;

  @override
  int compareTo(Routes other) => index.compareTo(other.index);

  @override
  String toString() => value;
}

/// Type definition for the page.
@immutable
sealed class AppPage extends ElixirPage {
  const AppPage({required super.name, required super.child, super.arguments, super.key});

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
  ElixirAlias get alias => Routes.home;
}

final class SettingsPage extends AppPage {
  SettingsPage({required final String data}) : super(child: SettingsScreen(data: data), name: 'settings');

  @override
  Route<void> createRoute(BuildContext context) => CustomMaterialRoute(page: this);

  @override
  Set<String> get tags => {'settings'};

  @override
  ElixirAlias get alias => Routes.settings;
}
