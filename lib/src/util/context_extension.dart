import 'dart:collection';

import 'package:flutter/material.dart';

import '../navigator/elixir_page.dart';
import '../navigator/navigator.dart';

extension ElixirContextExtension on BuildContext {
  ElixirState get elixir => Elixir.of(this);
}

extension ElixirControllerExtension on ValueNotifier<ElixirNavigationState> {
  void change(ElixirNavigationState Function(ElixirNavigationState pages) fn) {
    final prev = value.toList();
    var next = fn(prev);
    if (next.isEmpty) return;

    var isNotHaveSamePage = true;
    for (var i = 0; i < value.length; i++) {
      if (next.where((e) => e == value[i]).length > 1) {
        isNotHaveSamePage = false;
        break;
      }
    }
    assert(isNotHaveSamePage, 'Didn\'t pass the same page');
    if (next.isEmpty || isNotHaveSamePage) return;

    value = UnmodifiableListView<ElixirPage>(next);
  }
}
