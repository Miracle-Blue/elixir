import 'navigator.dart';

/// Called after [elixir]'s pages changed from [previous] to [next].
typedef ElixirListener =
    void Function(ElixirState elixir, ElixirNavigationState previous, ElixirNavigationState next);

/// Navigation observer shared by the root Elixir and every Elixir nested inside it.
/// For example: `context.elixir.observer.addListener((elixir, previous, next) {})`.
abstract interface class ElixirObserver {
  /// Calls [listener] after any Elixir in the tree changes its pages.
  void addListener(ElixirListener listener);

  /// Stops calling [listener].
  void removeListener(ElixirListener listener);
}

/// [ElixirObserver] owned by the root Elixir.
final class ElixirObserver$NavigatorImpl implements ElixirObserver {
  final List<ElixirListener> _listeners = [];

  @override
  void addListener(ElixirListener listener) => _listeners.add(listener);

  @override
  void removeListener(ElixirListener listener) => _listeners.remove(listener);

  /// Calls every listener. The copy lets a listener remove itself while being called.
  void notify(ElixirState elixir, ElixirNavigationState previous, ElixirNavigationState next) {
    for (final listener in _listeners.toList()) {
      listener(elixir, previous, next);
    }
  }
}
