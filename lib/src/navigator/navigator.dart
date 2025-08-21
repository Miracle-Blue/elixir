import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../elixir.dart';

/// Type definition for the navigation state.
typedef ElixirNavigationState = List<ElixirPage>;

/// Type definition for the guard.
typedef ElixirGuard = List<ElixirNavigationState Function(BuildContext context, ElixirNavigationState state)>;

/// {@template navigator}
/// AppNavigator widget.
/// {@endtemplate}
class Elixir extends StatefulWidget {
  /// {@macro navigator}
  Elixir({
    required this.pages,
    this.guards = const [],
    this.observers = const [],
    this.transitionDelegate = const DefaultTransitionDelegate<Object?>(),
    this.revalidate,
    this.onBackButtonPressed,
    super.key,
  }) : assert(pages.isNotEmpty, 'pages cannot be empty'),
       controller = null;

  /// {@macro navigator}
  Elixir.controlled({
    required ValueNotifier<ElixirNavigationState> this.controller,
    this.guards = const [],
    this.observers = const [],
    this.transitionDelegate = const DefaultTransitionDelegate<Object?>(),
    this.revalidate,
    this.onBackButtonPressed,
    super.key,
  }) : assert(controller.value.isNotEmpty, 'controller cannot be empty'),
       pages = controller.value;

  /// The [AppNavigatorState] from the closest instance of this class
  /// that encloses the given context, if any.
  static ElixirState? maybeOf(BuildContext context, {bool listen = false}) =>
      _InheritedElixir.maybeOf(context, listen: listen)?.state;

  /// The state from the closest instance of this class
  /// that encloses the given context.
  /// e.g. `ElixirState.of(context)`
  static ElixirState of(BuildContext context, {bool listen = false}) =>
      _InheritedElixir.of(context, listen: listen).state;

  /// The navigation state from the closest instance of this class
  /// that encloses the given context, if any.
  static ElixirNavigationState? stateOf(BuildContext context, {bool listen = false}) =>
      maybeOf(context, listen: listen)?.state;

  /// The navigator from the closest instance of this class
  /// that encloses the given context, if any.
  static NavigatorState? navigatorOf(BuildContext context, {bool listen = false}) =>
      maybeOf(context, listen: listen)?.navigator;

  /// Initial pages to display.
  final ElixirNavigationState pages;

  /// The controller to use for the navigator.
  final ValueNotifier<ElixirNavigationState>? controller;

  /// Guards to apply to the pages.
  final ElixirGuard guards;

  /// Observers to attach to the navigator.
  final List<NavigatorObserver> observers;

  /// The transition delegate to use for the navigator.
  final TransitionDelegate<Object?> transitionDelegate;

  /// Revalidate the pages.
  final Listenable? revalidate;

  /// The callback function that will be called when the back button is pressed.
  ///
  /// It must return a boolean with true if this navigator will handle the request;
  /// otherwise, return a boolean with false.
  ///
  /// Also you can mutate the [AppNavigationState] to change the navigation stack.
  final ({ElixirNavigationState state, bool handled}) Function(ElixirNavigationState state)? onBackButtonPressed;

  @override
  State<Elixir> createState() => ElixirState();
}

/// State for widget AppNavigator.
class ElixirState extends State<Elixir> with WidgetsBindingObserver {
  /// The current [Navigator] state (null if not yet built).
  NavigatorState? get navigator => _observer.navigator;
  final NavigatorObserver _observer = NavigatorObserver();

  /// The current pages list.
  ElixirNavigationState get state => _state;

  late ElixirNavigationState _state;
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
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    revalidate();
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
    WidgetsBinding.instance.removeObserver(this);
    widget.controller?.removeListener(_controllerListener);
    widget.revalidate?.removeListener(revalidate);
    super.dispose();
  }
  /* #endregion */

  /// Add a page to the stack.
  void push(ElixirPage page) => change((state) => [...state, page]);

  /// Pop the last page from the stack.
  void pop() => change((state) {
    if (state.isNotEmpty) state.removeLast();
    return state;
  });

  /// Clear the pages to the initial state.
  void reset(ElixirPage page) => change((_) => widget.pages);

  @override
  Future<bool> didPopRoute() {
    // If the back button handler is defined, call it.
    final backButtonHandler = widget.onBackButtonPressed;
    if (backButtonHandler != null) {
      final result = backButtonHandler(_state.toList());
      change((pages) => result.state);
      return SynchronousFuture(result.handled);
    }

    // Otherwise, handle the back button press with the default behavior.
    if (_state.length < 2) return SynchronousFuture(false);
    _onDidRemovePage(_state.last);
    return SynchronousFuture(true);
  }

  void _setStateToController() {
    if (widget.controller case ValueNotifier<ElixirNavigationState> controller) {
      controller
        ..removeListener(_controllerListener)
        ..value = _state
        ..addListener(_controllerListener);
    }
  }

  void _controllerListener() {
    final controller = widget.controller;
    if (controller == null || !mounted) return;
    final newValue = controller.value;
    if (identical(newValue, _state)) return;
    final ctx = context;
    final next = widget.guards.fold(newValue.toList(), (s, g) => g(ctx, s));
    if (next.isEmpty || listEquals(next, _state)) {
      _setStateToController(); // Revert the controller value.
    } else {
      _state = UnmodifiableListView<ElixirPage>(next);
      _setStateToController();
      setState(() {});
    }
  }

  /// Revalidate the pages.
  void revalidate() {
    if (!mounted) return;
    final ctx = context;
    final next = widget.guards.fold(_state.toList(), (s, g) => g(ctx, s));
    if (next.isEmpty || listEquals(next, _state)) return;
    _state = UnmodifiableListView<ElixirPage>(next);
    _setStateToController();
    setState(() {});
  }

  /// Change the pages.
  void change(ElixirNavigationState Function(ElixirNavigationState pages) fn) {
    final prev = _state.toList();
    var next = fn(prev);
    if (next.isEmpty) return;
    if (!mounted) return;
    final ctx = context;
    next = widget.guards.fold(next, (s, g) => g(ctx, s));
    if (next.isEmpty || listEquals(next, _state)) return;
    _state = UnmodifiableListView<ElixirPage>(next);
    _setStateToController();
    setState(() {});
  }

  /// Called when a page is removed from the stack.
  void _onDidRemovePage(ElixirPage page) {
    change((pages) => pages..removeWhere((p) => p.key == page.key));
  }

  @override
  Widget build(BuildContext context) => _InheritedElixir(
    state: this,
    child: Navigator(
      pages: _state,
      reportsRouteUpdateToEngine: false,
      transitionDelegate: widget.transitionDelegate,
      onDidRemovePage: (page) => _onDidRemovePage(page as ElixirPage),
      observers: _observers,
    ),
  );
}

/// Inherited widget for quick access in the element tree.
class _InheritedElixir extends InheritedWidget {
  const _InheritedElixir({required this.state, required super.child});

  final ElixirState state;

  /// The state from the closest instance of this class
  /// that encloses the given context, if any.
  /// For example: `Elixir.maybeOf(context)`.
  static _InheritedElixir? maybeOf(BuildContext context, {bool listen = true}) =>
      listen
          ? context.dependOnInheritedWidgetOfExactType<_InheritedElixir>()
          : context.getInheritedWidgetOfExactType<_InheritedElixir>();

  static Never _notFoundInheritedWidgetOfExactType() =>
      throw ArgumentError(
        'Out of scope, not found inherited widget '
            'a _InheritedElixir of the exact type',
        'out_of_scope',
      );

  /// The state from the closest instance of this class
  /// that encloses the given context.
  /// For example: `Elixir.of(context)`.
  static _InheritedElixir of(BuildContext context, {bool listen = true}) =>
      maybeOf(context, listen: listen) ?? _notFoundInheritedWidgetOfExactType();

  @override
  bool updateShouldNotify(covariant _InheritedElixir oldWidget) => false;
}
