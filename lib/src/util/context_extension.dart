import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../navigator/elixir_page.dart';
import '../navigator/navigator.dart';

extension ElixirContextExtension on BuildContext {
  ElixirState get elixir => Elixir.of(this);
}

extension ElixirControllerExtension on ValueNotifier<ElixirNavigationState> {
  /// Change the navigation state.
  void change(ElixirNavigationState Function(ElixirNavigationState pages) fn) {
    final prev = value.toList();
    var next = fn(prev);
    if (next.isEmpty || listEquals(next, value)) return;
    value = UnmodifiableListView<ElixirPage>(next);
  }

  /// Pop until the last page with the given tag.
  void popUntil(ElixirAlias tag) => change(
    (state) => [...state.takeWhile((page) => page.alias != tag), state.firstWhere((page) => page.alias == tag)],
  );
}
