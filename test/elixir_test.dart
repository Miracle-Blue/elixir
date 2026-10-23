import 'package:elixir/elixir.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

enum _Alias implements ElixirAlias {
  a,
  b,
  c,
  d,
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

/// Pumps an outer Elixir whose `scope` page hosts an inner Elixir.
Future<(ValueNotifier<ElixirNavigationState>, ValueNotifier<ElixirNavigationState>)> _pumpNested(
  WidgetTester tester, {
  required List<_Alias> outerTail,
}) async {
  final inner = ValueNotifier<ElixirNavigationState>([const _Page(_Alias.b), const _Page(_Alias.c)]);
  final outer = ValueNotifier<ElixirNavigationState>([
    const _Page(_Alias.a),
    _Page(_Alias.scope, Elixir.controlled(controller: inner, onBackButtonPressed: _removeLast)),
    for (final alias in outerTail) _Page(alias),
  ]);
  addTearDown(inner.dispose);
  addTearDown(outer.dispose);
  await tester.pumpWidget(
    MaterialApp(builder: (context, _) => Elixir.controlled(controller: outer, onBackButtonPressed: _removeLast)),
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
}
