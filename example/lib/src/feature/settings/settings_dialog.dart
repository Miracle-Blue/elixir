import 'package:elixir/elixir.dart';
import 'package:flutter/material.dart';

import 'settings_scope.dart';

/// {@template settings_dialog}
/// SettingsDialog widget.
/// {@endtemplate}
class SettingsDialog extends StatefulWidget {
  /// {@macro settings_dialog}
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

/// State for widget SettingsDialog.
abstract class SettingsDialogState extends State<SettingsDialog> {
  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /* #endregion */
}

class _SettingsDialogState extends SettingsDialogState {
  @override
  Widget build(BuildContext context) => Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: Colors.grey.withValues(alpha: 0.2), width: 1.5),
    ),
    constraints: const BoxConstraints(maxWidth: 600, minWidth: 300),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Settings', style: Theme.of(context).textTheme.titleLarge),
          Text('App Navigator: ${context.elixir.state.length}'),
          Text('Settings Navigator: ${SettingsScope.navigatorOf(context).value.length}'),
          TextButton(onPressed: () => context.elixir.pop(), child: const Text('Close')),
        ],
      ),
    ),
  );
}
