import 'package:elixir/elixir.dart';
import 'package:flutter/material.dart';

import '../../common/routes/routes.dart';
import '../../common/widget/app.dart';

/// {@template settings_screen}
/// SettingsScreen widget.
/// {@endtemplate}
class SettingsScreen extends StatelessWidget {
  /// {@macro settings_screen}
  const SettingsScreen({required this.data, super.key});

  final String data;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.cyan,
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed:
            () => App.controllerOf(context)?.change((state) => state.where((e) => e.alias != Routes.settings).toList()),
      ),
      title: const Text('Settings'),
    ),
    body: SafeArea(child: Center(child: Text('data: $data'))),
  );
}
