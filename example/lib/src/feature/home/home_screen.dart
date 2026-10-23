import 'dart:developer';

import 'package:elixir/elixir.dart';
import 'package:flutter/material.dart';

import '../../common/routes/routes.dart';
import '../../common/widget/app.dart';

ElixirObserver? elixirStateObserver;

/// {@template home_screen}
/// HomeScreen widget.
/// {@endtemplate}
class HomeScreen extends StatefulWidget {
  /// {@macro home_screen}
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void updateUI(ElixirState elixir, ElixirNavigationState previous, ElixirNavigationState next) {
    setState(() {});
    log('\n =========== Global Listener ================================ ');
    log(elixir.name?.alias ?? '');
    log(next.join());
    log(' ================================================ \n');
  }

  @override
  void initState() {
    super.initState();
    elixirStateObserver = context.elixir.observer;
    elixirStateObserver?.addListener(updateUI);
  }

  @override
  void dispose() {
    elixirStateObserver?.removeListener(updateUI);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Home'),
      actions: [
        IconButton(
          icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode),
          onPressed: () => App.toggleThemeOf(context),
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed:
              () => App.navigatorOf(context)?.change((state) => [...state, SettingsScopePage(data: 'Data from home')]),
        ),
      ],
    ),
    body: const SafeArea(child: Center(child: Text('Home'))),
  );
}
