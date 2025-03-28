import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Type definition for the navigation state.
typedef NavigationState = List<Page<Object?>>;
typedef ElixirGuard = NavigationState Function(NavigationState pages);

/// {@template navigator}
/// Elixir widget.
/// {@endtemplate}
class Elixir extends StatefulWidget {
  /// {@macro navigator}
  Elixir({
    required this.pages,
    this.guards = const [],
    this.observers = const [],
    this.transitionDelegate = const DefaultTransitionDelegate<Object?>(),
    this.revalidate,
    super.key,
  }) : assert(pages.isNotEmpty, 'pages cannot be empty'),
       controller = null;

  /// {@macro navigator}
  Elixir.controlled({
    required ValueNotifier<NavigationState> this.controller,
    this.guards = const [],
    this.observers = const [],
    this.transitionDelegate = const DefaultTransitionDelegate<Object?>(),
    this.revalidate,
    super.key,
  }) : assert(controller.value.isNotEmpty, 'controller cannot be empty'),
       pages = controller.value;

  /// The [ElixirState] from the closest instance of this class
  /// that encloses the given context, if any.
  static ElixirState? maybeOf(BuildContext context) => context.findAncestorStateOfType<ElixirState>();

  /// The navigation state from the closest instance of this class
  /// that encloses the given context, if any.
  static NavigationState? stateOf(BuildContext context) => maybeOf(context)?.state;

  /// The navigator from the closest instance of this class
  /// that encloses the given context, if any.
  static NavigatorState? navigatorOf(BuildContext context) => maybeOf(context)?.navigator;

  /// Change the pages.
  static void change(BuildContext context, NavigationState Function(NavigationState pages) fn) =>
      maybeOf(context)?.change(fn);

  /// Add a page to the stack.
  static void push(BuildContext context, Page<Object?> page) => change(context, (state) => [...state, page]);

  /// Pop the last page from the stack.
  static void pop(BuildContext context) => change(context, (state) {
    if (state.isNotEmpty) state.removeLast();
    return state;
  });

  /// Clear the pages to the initial state.
  static void reset(BuildContext context, Page<Object?> page) {
    final navigator = maybeOf(context);
    if (navigator == null) return;
    navigator.change((_) => navigator.widget.pages);
  }

  /// Initial pages to display.
  final NavigationState pages;

  /// The controller to use for the navigator.
  final ValueNotifier<NavigationState>? controller;

  /// Guards to apply to the pages.
  final List<ElixirGuard> guards;

  /// Observers to attach to the navigator.
  final List<NavigatorObserver> observers;

  /// The transition delegate to use for the navigator.
  final TransitionDelegate<Object?> transitionDelegate;

  /// Revalidate the pages.
  final Listenable? revalidate;

  @override
  State<Elixir> createState() => ElixirState();
}

/// State for widget Elixir.
class ElixirState extends State<Elixir> {
  /// The current [Navigator] state (null if not yet built).
  NavigatorState? get navigator => _observer.navigator;

  /// The current pages list.
  NavigationState get state => _state;

  late NavigationState _state;
  final NavigatorObserver _observer = NavigatorObserver();
  List<NavigatorObserver> _observers = const [];

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    _state = widget.pages;
    widget.revalidate?.addListener(revalidate);
    _observers = <NavigatorObserver>[_observer, ...widget.observers];
    widget.controller?.addListener(_controllerListener);
    _controllerListener();
  }

  @override
  void didUpdateWidget(covariant Elixir oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.revalidate, oldWidget.revalidate)) {
      oldWidget.revalidate?.removeListener(revalidate);
      widget.revalidate?.addListener(revalidate);
    }
    if (!identical(widget.observers, oldWidget.observers)) {
      _observers = <NavigatorObserver>[_observer, ...widget.observers];
    }
    if (!identical(widget.controller, oldWidget.controller)) {
      oldWidget.controller?.removeListener(_controllerListener);
      widget.controller?.addListener(_controllerListener);
      _controllerListener();
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller?.removeListener(_controllerListener);
    widget.revalidate?.removeListener(revalidate);
  }
  /* #endregion */

  void _setStateToController() {
    if (widget.controller case ValueNotifier<NavigationState> controller) {
      controller
        ..removeListener(_controllerListener)
        ..value = _state
        ..addListener(_controllerListener);
    }
  }

  void _controllerListener() {
    final controller = widget.controller;
    if (controller == null) return;
    final newValue = controller.value;
    if (identical(newValue, _state)) return;
    final next = widget.guards.fold(newValue.toList(), (s, g) => g(s));
    if (next.isEmpty || listEquals(next, _state)) {
      _setStateToController(); // Revert the controller value.
    } else {
      _state = UnmodifiableListView<Page<Object?>>(next);
      _setStateToController();
      setState(() {});
    }
  }

  /// Revalidate the pages.
  void revalidate() {
    final next = widget.guards.fold(_state.toList(), (s, g) => g(s));
    if (next.isEmpty || listEquals(next, _state)) return;
    _state = UnmodifiableListView<Page<Object?>>(next);
    _setStateToController();
    setState(() {});
  }

  /// Change the pages.
  void change(NavigationState Function(NavigationState pages) fn) {
    final prev = _state.toList();
    var next = fn(prev);
    if (next.isEmpty) return;
    next = widget.guards.fold(next, (s, g) => g(s));
    if (next.isEmpty || listEquals(next, _state)) return;
    _state = UnmodifiableListView<Page<Object?>>(next);
    _setStateToController();
    setState(() {});
  }

  void _onDidRemovePage(Page<Object?> page) => change((pages) => pages..remove(page));

  @override
  Widget build(BuildContext context) => Navigator(
    pages: _state,
    reportsRouteUpdateToEngine: false,
    transitionDelegate: widget.transitionDelegate,
    onDidRemovePage: _onDidRemovePage,
    observers: _observers,
  );
}
