import 'package:elixir/elixir.dart';
import 'package:flutter/material.dart';

import '../../common/routes/routes.dart';
import '../../common/widget/app.dart';
import 'settings_scope.dart';

/// {@template settings_screen}
/// SettingsScreen widget.
/// {@endtemplate}
class SettingsScreen extends StatefulWidget {
  /// {@macro settings_screen}
  const SettingsScreen({required this.data, super.key});

  final String data;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.cyan,
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed:
            () =>
                App.navigatorOf(context)?.change((state) => state.where((e) => e.alias != AppRoutes.settings).toList()),
      ),
      title: const Text('Settings'),
    ),
    body: SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('data: ${widget.data}'),
            TextButton(
              onPressed:
                  () => SettingsScope.navigatorOf(context).change((state) => [...state, const SettingsDialogPage()]),
              child: const Text('Open Settings Dialog'),
            ),
          ],
        ),
      ),
    ),
  );
}
