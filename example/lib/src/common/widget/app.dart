import 'package:elixir/elixir.dart';
import 'package:flutter/material.dart';

import '../routes/route_state_mixin.dart';

/// {@template app}
/// App widget.
/// {@endtemplate}
class App extends StatefulWidget {
  /// {@macro app}
  const App({super.key});

  static ValueNotifier<ElixirNavigationState>? controllerOf(BuildContext context) =>
      context.findAncestorStateOfType<_AppState>()?._controller;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with RouteStateMixin {
  final GlobalKey<State<StatefulWidget>> _preserveKey = GlobalKey<State<StatefulWidget>>();

  late ValueNotifier<ElixirNavigationState> _controller;

  @override
  void initState() {
    super.initState();
    _controller = ValueNotifier(initialPages);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    key: _preserveKey,
    title: 'Declarative Navigation',
    debugShowCheckedModeBanner: false,
    builder:
        (context, _) => Elixir.controlled(
          controller: _controller,
          guards: guards,
          onBackButtonPressed: (state) => (handled: true, state: (state..removeLast()).toList()),
        ),
  );
}
