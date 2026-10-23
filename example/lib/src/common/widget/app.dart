import 'dart:developer';

import 'package:elixir/elixir.dart';
import 'package:flutter/material.dart';

import '../routes/route_state_mixin.dart';
import '../routes/routes.dart';

/// {@template app}
/// App widget.
/// {@endtemplate}
class App extends StatefulWidget {
  /// {@macro app}
  const App({super.key});

  static ValueNotifier<ElixirNavigationState>? navigatorOf(BuildContext context) =>
      context.findAncestorStateOfType<_AppState>()?._navigator;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with RouteStateMixin {
  final GlobalKey<State<StatefulWidget>> _preserveKey = GlobalKey<State<StatefulWidget>>();

  late ValueNotifier<ElixirNavigationState> _navigator;

  @override
  void initState() {
    super.initState();
    _navigator = ValueNotifier(initialPages);
  }

  @override
  void dispose() {
    _navigator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    key: _preserveKey,
    title: 'Declarative Navigation',
    debugShowCheckedModeBanner: false,
    builder:
        (context, _) => Elixir.controlled(
          listeners: [
            (ElixirState elixir, ElixirNavigationState previous, ElixirNavigationState next) {
              setState(() {});
              log('\n =========== ${AppRoutes.app.alias} ================================ ');
              log(elixir.name?.alias ?? '');
              log(next.join());
              log(' ================================================ \n');
            },
          ],
          name: AppRoutes.app,
          controller: _navigator,
          guards: guards,
          onBackButtonPressed: (state) {
            log('onBackButtonPressed: $state');
            return (handled: true, state: (state..removeLast()).toList());
          },
        ),
  );
}
