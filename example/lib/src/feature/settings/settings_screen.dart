import 'package:elixir/elixir.dart';
import 'package:flutter/material.dart';

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
        onPressed: () => context.elixir.change((state) => state.where((e) => !e.tags.contains('settings')).toList()),
      ),
      title: const Text('Settings'),
    ),
    body: SafeArea(child: Center(child: Text('data: $data'))),
  );
}
