import 'dart:developer';

import 'package:elixir/elixir.dart';
import 'package:flutter/material.dart';

import '../../common/routes/routes.dart';

ElixirStateObserver? elixirStateObserver;

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
  void updateUI() {
    setState(() {});
    log(elixirStateObserver?.value.join() ?? '');
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
          icon: const Icon(Icons.settings),
          onPressed: () => context.elixir.push(SettingsPage(data: 'Data from home')),
        ),
      ],
    ),
    body: const SafeArea(child: Center(child: Text('Home'))),
  );
}
