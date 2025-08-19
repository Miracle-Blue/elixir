import 'package:elixir/elixir.dart';
import 'package:example/src/common/routes/routes.dart';
import 'package:flutter/material.dart';

mixin RouteStateMixin<T extends StatefulWidget> on State<T> {
  late ElixirNavigationState initialPages;

  late ElixirGuard guards;

  @override
  void initState() {
    super.initState();
    initialPages = [HomePage()];

    guards = [
      (context, state) => state.length > 1 ? state : [HomePage()],
    ];
  }
}
