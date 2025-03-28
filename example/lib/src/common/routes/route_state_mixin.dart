import 'package:elixir/elixir.dart';
import 'package:example/src/feature/home/home_screen.dart';
import 'package:flutter/material.dart';

mixin RouteStateMixin<T extends StatefulWidget> on State<T> {
  late List<Page<void>> initialPages;

  late List<ElixirGuard> guards;

  @override
  void initState() {
    super.initState();
    initialPages = const [MaterialPage<void>(child: HomeScreen())];

    guards = [
      (pages) => pages.length > 1 ? pages : [const MaterialPage(child: HomeScreen())],
    ];
  }
}
