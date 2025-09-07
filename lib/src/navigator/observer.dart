import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'navigator.dart';

/// Elixir state observer
abstract interface class ElixirStateObserver implements ValueListenable<ElixirNavigationState> {
  /// Max history length.
  static const int maxHistoryLength = 10000;

  /// History.
  List<ElixirHistoryEntry> get history;

  /// Set history
  void setHistory(Iterable<ElixirHistoryEntry> history);
}

@immutable
final class ElixirHistoryEntry implements Comparable<ElixirHistoryEntry> {
  ElixirHistoryEntry({required this.state, DateTime? timestamp}) : timestamp = timestamp ?? DateTime.now();

  /// Navigation state
  final ElixirNavigationState state;

  /// Timestamp of the entry
  final DateTime timestamp;

  @override
  int compareTo(covariant ElixirHistoryEntry other) => timestamp.compareTo(other.timestamp);

  @override
  late final int hashCode = state.hashCode ^ timestamp.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ElixirHistoryEntry && state == other.state && timestamp == other.timestamp;
}

/// Elixir state observer implementation
final class ElixirObserver$NavigatorImpl with ChangeNotifier implements ElixirStateObserver {
  ElixirObserver$NavigatorImpl(ElixirNavigationState initialState, [List<ElixirHistoryEntry>? history])
    : _value = initialState,
      _history = history?.toSet().toList() ?? [] {
    // Add the initial state to the history.
    if (_history.isEmpty || _history.last.state != initialState) {
      _history.add(ElixirHistoryEntry(state: initialState, timestamp: DateTime.now()));
    }
    _history.sort();
  }

  ElixirNavigationState _value;

  final List<ElixirHistoryEntry> _history;

  @override
  List<ElixirHistoryEntry> get history => UnmodifiableListView<ElixirHistoryEntry>(_history);

  @override
  void setHistory(Iterable<ElixirHistoryEntry> history) {
    _history
      ..clear()
      ..addAll(history)
      ..sort();
  }

  @override
  ElixirNavigationState get value => _value;

  bool changeState(ElixirNavigationState Function(ElixirNavigationState state) fn) {
    final prev = _value;
    final next = fn(prev);
    if (identical(next, prev)) return false;
    _value = next;

    late final historyEntry = ElixirHistoryEntry(state: next, timestamp: DateTime.now());
    _history.add(historyEntry);
    if (_history.length > ElixirStateObserver.maxHistoryLength) _history.removeAt(0);

    notifyListeners();
    return true;
  }
}
