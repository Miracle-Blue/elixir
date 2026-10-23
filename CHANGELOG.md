## 0.3.0

- **Breaking:** `ElixirStateObserver` replaced by `ElixirObserver`. `context.elixir.observer` now returns one observer created by the root Elixir and shared with every nested Elixir; listeners are `(elixir, previous, next)` callbacks instead of `VoidCallback`
- **Breaking:** Removed navigation history (`history`, `setHistory`, `ElixirHistoryEntry`, `maxHistoryLength`)
- Added `ElixirListener` typedef and `listeners` parameter on `Elixir`, called for that Elixir and every Elixir nested inside it
- Added optional `name` (`ElixirAlias?`) parameter on `Elixir` and `ElixirState.name` to tell Elixirs apart, e.g. in listeners
- System back button now goes to the innermost active nested Elixir first; a nested Elixir with a single page, or whose `onBackButtonPressed` returns `handled: false`, passes it to its parent
- Nested Elixirs under a covered route or in a hidden `IndexedStack` tab are skipped when handling the back button
- Added widget tests for nested back button handling and observers

## 0.2.0

- **Breaking:** `ElixirPage` now requires an `alias` field of type `ElixirAlias`; `name` is derived from `alias.alias`
- **Breaking:** Minimum SDK constraint raised to `^3.9.1`
- Added `ElixirAlias` interface for enum-based route identification
- Added `popUntil(ElixirAlias)` method to `ElixirState` and `ElixirControllerExtension`
- Added `ElixirControllerExtension` on `ValueNotifier<ElixirNavigationState>` with `change()` and `popUntil()` for programmatic navigation outside the widget tree
- Added `revalidate` parameter on `Elixir` widget to re-run guards when a `Listenable` fires
- Added `onBackButtonPressed` callback for custom system back button handling
- Added `ElixirStateObserver` with timestamped navigation history (up to 10,000 entries)
- Added `CupertinoBackGestureDetector` and `CupertinoBackGestureController` for iOS-style swipe-back gestures
- Added static access helpers: `Elixir.of`, `Elixir.maybeOf`, `Elixir.stateOf`, `Elixir.navigatorOf`
- Improved `ElixirPage` key generation using name and arguments hash
- Improved equality and hashCode implementations in `ElixirPage`
- Updated `flutter_lints` to `^6.0.0`
- Added `public_member_api_docs` lint rule and enhanced documentation across all public APIs

## 0.0.2

- Added Elixir controller extension

## 0.0.1

- Initial configuration
