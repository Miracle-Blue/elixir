import 'package:elixir/elixir.dart';
import 'package:example/src/common/routes/routes.dart';
import 'package:flutter/material.dart';

/// {@template home_screen}
/// HomeScreen widget.
/// {@endtemplate}
class HomeScreen extends StatelessWidget {
  /// {@macro home_screen}
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Home'),
      actions: [
        IconButton(icon: const Icon(Icons.settings), onPressed: () => Elixir.push(context, Routes.settings.page())),
      ],
    ),
    body: const SafeArea(child: Center(child: Text('Home'))),
  );
}
