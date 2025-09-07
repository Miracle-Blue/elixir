import 'package:elixir/elixir.dart';
import 'package:flutter/material.dart';

import '../routes/route_state_mixin.dart';

/// {@template app}
/// App widget.
/// {@endtemplate}
class App extends StatefulWidget {
  /// {@macro app}
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with RouteStateMixin {
  final GlobalKey<State<StatefulWidget>> _preserveKey = GlobalKey<State<StatefulWidget>>();

  @override
  Widget build(BuildContext context) => MaterialApp(
    key: _preserveKey,
    title: 'Declarative Navigation',
    debugShowCheckedModeBanner: false,
    builder: (context, _) => Elixir.controlled(controller: ValueNotifier(initialPages), guards: guards),
  );
}
