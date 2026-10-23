import 'package:elixir/elixir.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

enum _Alias implements ElixirAlias {
  a,
  b,
  c,
  d,
  e,
  scope;

  @override
  String get alias => name;
}

final class _Page extends ElixirPage {
  const _Page(this.alias, [Widget child = const SizedBox()]) : super(name: '', child: child, arguments: null);

  @override
  final ElixirAlias alias;

  @override
  Set<String> get tags => const {};
}

({ElixirNavigationState state, bool handled}) _removeLast(ElixirNavigationState state) =>
    (handled: true, state: state..removeLast());

List<ElixirAlias> _aliases(ValueNotifier<ElixirNavigationState> n) => n.value.map((p) => p.alias).toList();

/// Records `<first page of the reporting Elixir>:<new top page>` per change.
ElixirListener _record(List<String> into) =>
    (elixir, previous, next) => into.add('${elixir.state.first.alias.alias}:${next.last.alias.alias}');

/// Pumps an outer Elixir whose `scope` page hosts an inner Elixir.
Future<(ValueNotifier<ElixirNavigationState>, ValueNotifier<ElixirNavigationState>)> _pumpNested(
  WidgetTester tester, {
  required List<_Alias> outerTail,
  List<ElixirListener> outerListeners = const [],
  List<ElixirListener> innerListeners = const [],
}) async {
  final inner = ValueNotifier<ElixirNavigationState>([const _Page(_Alias.b), const _Page(_Alias.c)]);
  final outer = ValueNotifier<ElixirNavigationState>([
    const _Page(_Alias.a),
    _Page(
      _Alias.scope,
      Elixir.controlled(controller: inner, listeners: innerListeners, onBackButtonPressed: _removeLast),
    ),
    for (final alias in outerTail) _Page(alias),
  ]);
  addTearDown(inner.dispose);
  addTearDown(outer.dispose);
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, _) =>
          Elixir.controlled(controller: outer, listeners: outerListeners, onBackButtonPressed: _removeLast),
    ),
  );
  await tester.pumpAndSettle();
  return (outer, inner);
}

Future<void> _back(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('back press goes to the inner Elixir first, then the outer one', (tester) async {
    final (outer, inner) = await _pumpNested(tester, outerTail: const []);

    await _back(tester);
    expect(_aliases(inner), [_Alias.b]);
    expect(_aliases(outer), [_Alias.a, _Alias.scope]);

    // Inner has a single page, so the outer Elixir handles it.
    await _back(tester);
    expect(_aliases(outer), [_Alias.a]);
  });

  testWidgets('inner Elixir under a covered route is skipped', (tester) async {
    final (outer, inner) = await _pumpNested(tester, outerTail: const [_Alias.d]);

    await _back(tester);
    expect(_aliases(outer), [_Alias.a, _Alias.scope]);
    expect(_aliases(inner), [_Alias.b, _Alias.c]);
  });

  testWidgets('listeners see their Elixir and nested ones only', (tester) async {
    final global = <String>[];
    final scoped = <String>[];
    final (outer, inner) = await _pumpNested(
      tester,
      outerTail: const [],
      outerListeners: [_record(global)],
      innerListeners: [_record(scoped)],
    );

    inner.change((s) => [...s, const _Page(_Alias.d)]);
    await tester.pumpAndSettle();
    expect(global, ['b:d']);
    expect(scoped, ['b:d']);

    outer.change((s) => [...s, const _Page(_Alias.e)]);
    await tester.pumpAndSettle();
    expect(global, ['b:d', 'a:e']);
    expect(scoped, ['b:d']);
  });

  testWidgets('nested Elixirs share the root observer', (tester) async {
    final (outer, inner) = await _pumpNested(tester, outerTail: const []);
    final elixirs = tester.stateList<ElixirState>(find.byType(Elixir));
    final observer = elixirs.first.observer;
    expect(elixirs.last.observer, same(observer));

    final changes = <String>[];
    observer.addListener(_record(changes));
    inner.change((s) => [...s, const _Page(_Alias.d)]);
    await tester.pumpAndSettle();
    outer.change((s) => [...s, const _Page(_Alias.e)]);
    await tester.pumpAndSettle();
    expect(changes, ['b:d', 'a:e']);
  });
}
