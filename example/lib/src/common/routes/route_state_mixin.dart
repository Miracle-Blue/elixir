import 'package:elixir/elixir.dart';
import 'package:flutter/material.dart';

import 'routes.dart';

mixin RouteStateMixin<T extends StatefulWidget> on State<T> {
  late ElixirNavigationState initialPages;

  late ElixirGuard guards;

  @override
  void initState() {
    super.initState();
    initialPages = [const HomePage()];

    guards = [
      (context, state) => state.length > 1 ? state : [const HomePage()],
    ];
  }
}
