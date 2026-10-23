import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'elixir_page.dart';
import 'observer.dart';

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
    this.name,
    this.guards = const [],
    this.observers = const [],
    this.listeners = const [],
    this.transitionDelegate = const DefaultTransitionDelegate<Object?>(),
    this.revalidate,
    this.onBackButtonPressed,
    super.key,
  }) : assert(pages.isNotEmpty, 'pages cannot be empty'),
       controller = null;

  /// {@macro navigator}
  Elixir.controlled({
    required ValueNotifier<ElixirNavigationState> this.controller,
    this.name,
    this.guards = const [],
    this.observers = const [],
    this.listeners = const [],
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

  /// Optional name to tell Elixirs apart, e.g. in listeners: `elixir.name == Scopes.settings`.
  final ElixirAlias? name;

  /// Guards to apply to the pages.
  final ElixirGuard guards;

  /// Observers to attach to the navigator.
  final List<NavigatorObserver> observers;

  /// Called after this Elixir or any Elixir nested inside it changes its pages.
  final List<ElixirListener> listeners;

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
  ///
  /// Nested Elixirs are asked first (innermost active one wins).
  /// A nested Elixir with a single page, or one returning `handled: false`,
  /// passes the back press to its parent Elixir.
  final ({ElixirNavigationState state, bool handled}) Function(ElixirNavigationState state)? onBackButtonPressed;

  @override
  State<Elixir> createState() => ElixirState();
}

/// State for widget AppNavigator.
class ElixirState extends State<Elixir> with WidgetsBindingObserver {
  /// The current [Navigator] state (null if not yet built).
  NavigatorState? get navigator => _navigatorObserver.navigator;
  final NavigatorObserver _navigatorObserver = NavigatorObserver();

  /// Created only by the root Elixir, see [_rootObserver].
  late final ElixirObserver$NavigatorImpl _observer = ElixirObserver$NavigatorImpl();

  /// The observer shared by the root Elixir and all nested Elixirs.
  /// For example: `context.elixir.observer`.
  ElixirObserver get observer => _rootObserver;
  ElixirObserver$NavigatorImpl get _rootObserver => _parent?._rootObserver ?? _observer;

  /// The current pages list.
  ElixirNavigationState get state => _state;

  /// The name given to this Elixir, if any.
  ElixirAlias? get name => widget.name;

  late ElixirNavigationState _state;
  List<NavigatorObserver> _observers = const [];

  /// The closest ancestor Elixir, null for the root one.
  ElixirState? _parent;

  /// Nested Elixirs registered under this one.
  final Set<ElixirState> _children = <ElixirState>{};

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    _state = widget.pages;
    widget.revalidate?.addListener(revalidate);

    _observers = <NavigatorObserver>[_navigatorObserver, ...widget.observers];
    widget.controller?.addListener(_controllerListener);
    _controllerListener();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Our own _InheritedElixir is below this context, so this finds the ancestor.
    final parent = Elixir.maybeOf(context, listen: true);
    if (!identical(parent, _parent)) {
      _parent?._children.remove(this);
      _parent = parent?.._children.add(this);
    }
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
      _observers = <NavigatorObserver>[_navigatorObserver, ...widget.observers];
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
    _parent?._children.remove(this);
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

  /// PopUntil the last page with the given tag.
  void popUntil(ElixirAlias tag) => change(
    (state) => [
      ...state.takeWhile((page) => page.alias != tag),
      ?state.skipWhile((page) => page.alias != tag).firstOrNull,
    ],
  );

  /// Clear the pages to the initial state.
  void reset(ElixirPage page) => change((_) => widget.pages);

  // Only the root Elixir answers the binding; it dispatches to nested ones.
  @override
  Future<bool> didPopRoute() => SynchronousFuture(_parent == null && _handleBackButton());

  /// Whether this Elixir is in the parent's top route and not a hidden tab.
  bool get _isActive => mounted && (ModalRoute.isCurrentOf(context) ?? true) && Visibility.of(context);

  /// Active nested Elixirs handle the back press first, then this one.
  bool _handleBackButton() {
    for (final child in _children) {
      if (child._isActive && child._handleBackButton()) return true;
    }

    // A nested Elixir with a single page defers to its parent.
    if (_parent != null && _state.length < 2) return false;

    // If the back button handler is defined, call it.
    final backButtonHandler = widget.onBackButtonPressed;
    if (backButtonHandler != null) {
      final result = backButtonHandler(_state.toList());
      change((pages) => result.state);
      return result.handled;
    }

    // Otherwise, handle the back button press with the default behavior.
    if (_state.length < 2) return false;
    _onDidRemovePage(_state.last);
    return true;
  }

  void _setStateToController() {
    if (widget.controller case ValueNotifier<ElixirNavigationState> controller) {
      controller
        ..removeListener(_controllerListener)
        ..value = _state
        ..addListener(_controllerListener);
    }
  }

  /// Applies [next] and notifies scoped listeners and the global observer.
  void _updateState(ElixirNavigationState next) {
    final previous = _state;
    _state = UnmodifiableListView<ElixirPage>(next);
    _setStateToController();
    setState(() {});
    // Scoped listeners of this Elixir and its ancestors; the Set calls a shared one once.
    final listeners = {for (ElixirState? e = this; e != null; e = e._parent) ...e.widget.listeners};
    for (final listener in listeners) {
      listener(this, previous, _state);
    }
    _rootObserver.notify(this, previous, _state);
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
      _updateState(next);
    }
  }

  /// Revalidate the pages.
  void revalidate() {
    if (!mounted) return;
    final ctx = context;
    final next = widget.guards.fold(_state.toList(), (s, g) => g(ctx, s));
    if (next.isEmpty || listEquals(next, _state)) return;
    _updateState(next);
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
    _updateState(next);
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
      restorationScopeId: 'elixir_navigator',
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
  static _InheritedElixir? maybeOf(BuildContext context, {bool listen = true}) => listen
      ? context.dependOnInheritedWidgetOfExactType<_InheritedElixir>()
      : context.getInheritedWidgetOfExactType<_InheritedElixir>();

  static Never _notFoundInheritedWidgetOfExactType() => throw ArgumentError(
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
