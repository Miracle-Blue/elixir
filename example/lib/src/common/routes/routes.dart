import 'package:elixir/elixir.dart';
import 'package:example/src/feature/home/home_screen.dart';
import 'package:example/src/feature/settings/settings_screen.dart';
import 'package:flutter/material.dart';

import 'custom_route_transitions.dart';

/// Type definition for the page.
@immutable
sealed class AppPage extends ElixirPage {
  const AppPage({required super.name, required super.child, super.arguments, super.key});

  @override
  int get hashCode => key.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AppPage && key == other.key;
}

final class HomePage extends AppPage {
  const HomePage() : super(child: const HomeScreen(), name: 'home_page');

  @override
  Route<void> createRoute(BuildContext context) => CustomMaterialRoute(page: this);

  @override
  Set<String> get tags => {'home'};
}

final class SettingsPage extends AppPage {
  SettingsPage({required final String data}) : super(child: SettingsScreen(data: data), name: 'settings_page');

  @override
  Route<void> createRoute(BuildContext context) => CustomMaterialRoute(page: this);

  @override
  Set<String> get tags => {'settings'};
}
