import 'package:elixir/elixir.dart';
import 'package:example/src/common/routes/routes.dart';
import 'package:flutter/material.dart';

/// {@template settings_screen}
/// SettingsScreen widget.
/// {@endtemplate}
class SettingsScreen extends StatelessWidget {
  /// {@macro settings_screen}
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Elixir.change(context, (state) => state..removeWhere((p) => p.name == Routes.settings.name)),
      ),
      title: const Text('Settings'),
    ),
    body: const SafeArea(child: Center(child: Text('Settings'))),
  );
}
