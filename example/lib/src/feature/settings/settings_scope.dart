import 'dart:developer';

import 'package:elixir/elixir.dart';
import 'package:flutter/widgets.dart';

import '../../common/routes/routes.dart';

/// {@template settings_scope}
/// SettingsScope widget.
/// {@endtemplate}
class SettingsScope extends StatefulWidget {
  /// {@macro settings_scope}
  const SettingsScope({required this.data, super.key});

  final String data;

  /// The state from the closest instance of this class
  /// that encloses the given context, if any.
  /// For example: `SettingsScope.maybeOf(context)`.
  static SettingsScopeState? maybeOf(BuildContext context, {bool listen = true}) =>
      (listen
              ? context.dependOnInheritedWidgetOfExactType<_InheritedSettingsScope>()
              : context.getInheritedWidgetOfExactType<_InheritedSettingsScope>())
          ?.state;

  static Never _notFoundInheritedWidgetOfExactType() =>
      throw ArgumentError(
        'Out of scope, not found inherited widget '
            'a _InheritedSettingsScope of the exact type',
        'out_of_scope',
      );

  /// The state from the closest instance of this class
  /// that encloses the given context.
  /// For example: `SettingsScope.of(context)`.
  static SettingsScopeState of(BuildContext context, {bool listen = true}) =>
      maybeOf(context, listen: listen) ?? _notFoundInheritedWidgetOfExactType();

  static ValueNotifier<ElixirNavigationState> navigatorOf(BuildContext context, {bool listen = true}) =>
      of(context, listen: listen)._settingsNavigator;

  @override
  State<SettingsScope> createState() => _SettingsScopeState();
}

/// State for widget SettingsScope.
abstract class SettingsScopeState extends State<SettingsScope> {
  late ValueNotifier<ElixirNavigationState> _settingsNavigator;

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    // Initial state initialization
    _settingsNavigator = ValueNotifier([SettingsPage(data: widget.data)]);
  }

  @override
  void dispose() {
    _settingsNavigator.dispose();
    super.dispose();
  }

  /* #endregion */
}

class _SettingsScopeState extends SettingsScopeState {
  @override
  Widget build(BuildContext context) => _InheritedSettingsScope(
    state: this,
    child: Elixir.controlled(
      name: AppRoutes.settings,
      controller: _settingsNavigator,
      listeners: [
        (ElixirState elixir, ElixirNavigationState previous, ElixirNavigationState next) {
          setState(() {});
          log('\n ========= ${AppRoutes.settings.alias} ============================= ');
          log(elixir.name?.alias ?? '');
          log(next.join());
          log(' ================================================ \n');
        },
      ],
      onBackButtonPressed: (state) {
        log('onBackButtonPressed (settings scope): $state');
        return (handled: true, state: (state..removeLast()).toList());
      },
    ),
  );
}

/// Inherited widget for quick access in the element tree.
class _InheritedSettingsScope extends InheritedWidget {
  const _InheritedSettingsScope({required this.state, required super.child});

  final _SettingsScopeState state;

  @override
  bool updateShouldNotify(covariant _InheritedSettingsScope oldWidget) => false;
}
