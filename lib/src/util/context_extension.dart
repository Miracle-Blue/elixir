import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../navigator/elixir_page.dart';
import '../navigator/navigator.dart';

/// Extension for the [BuildContext] to get the [ElixirState].
extension ElixirContextExtension on BuildContext {
  /// The [ElixirState] from the closest instance of this class
  /// that encloses the given context.
  /// ```dart
  /// context.elixir;
  /// ```
  ElixirState get elixir => Elixir.of(this);
}

/// Extension for the [ValueNotifier<ElixirNavigationState>] to change the navigation state.
extension ElixirControllerExtension on ValueNotifier<ElixirNavigationState> {
  /// Change the navigation state.
  /// To push a new page, you can use the [push] method.
  /// ```dart
  /// context.elixir.change((state) => [...state, page]);
  /// ```
  ///
  /// You can also push multiple pages at once by using the [change] method.
  /// ```dart
  /// context.elixir.change((state) => [...state, page1, page2]);
  /// ```
  ///
  /// You can also filter the pages by using the [change] method.
  /// ```dart
  /// context.elixir.change((state) => state.where((page) => page.alias == Alias.home).toList());
  /// ```
  /// 
  /// ... and more.
  void change(ElixirNavigationState Function(ElixirNavigationState pages) fn) {
    final prev = value.toList();
    var next = fn(prev);
    if (next.isEmpty || listEquals(next, value)) return;
    value = UnmodifiableListView<ElixirPage>(next);
  }

  /// Pop until the last page with the given tag.
  /// ```dart
  /// context.elixir.popUntil(Alias.settings);
  /// ```
  void popUntil(ElixirAlias tag) => change(
    (state) => [
      ...state.takeWhile((page) => page.alias != tag),
      ?state.skipWhile((page) => page.alias != tag).firstOrNull,
    ],
  );
}
