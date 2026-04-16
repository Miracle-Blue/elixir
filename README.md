# Elixir

A declarative navigation package for Flutter built on top of Navigator 2.0. Elixir provides a clean, type-safe approach to managing navigation state as an immutable list of pages.

## Features

- ✅ Declarative navigation with immutable page stack
- ✅ Type-safe page definitions with `ElixirAlias` enum routing
- ✅ Navigation guards for access control and state validation
- ✅ Navigation history tracking with timestamped entries
- ✅ Custom per-page route transitions
- ✅ iOS-style swipe-back gesture support (`CupertinoBackGestureDetector`)
- ✅ Programmatic navigation via `ValueNotifier` controller
- ✅ Reactive revalidation through `Listenable`
- ✅ Built-in context extensions for ergonomic access

## Getting Started

Add Elixir to your `pubspec.yaml`:

```yaml
dependencies:
  elixir:
    git:
      url: https://github.com/Miracle-Blue/elixir.git
```

Then run:

```bash
flutter pub get
```

## Usage

### 1. Define Route Aliases

Create a route enum implementing `ElixirAlias`:

```dart
enum Routes implements ElixirAlias, Comparable<Routes> {
  home('home'),
  settings('settings');

  const Routes(this.value);

  final String value;

  @override
  String get alias => value;

  @override
  int compareTo(Routes other) => index.compareTo(other.index);

  @override
  String toString() => value;
}
```

### 2. Define Pages

Create a sealed page hierarchy extending `ElixirPage`. Each page must provide `tags` and `alias`:

```dart
@immutable
sealed class AppPage extends ElixirPage {
  const AppPage({required super.name, required super.child, super.arguments, super.key});

  @override
  String toString() => '/$name${arguments.isEmpty ? '' : '~$arguments'}';
}

final class HomePage extends AppPage {
  const HomePage() : super(child: const HomeScreen(), name: 'home');

  @override
  Set<String> get tags => {'home'};

  @override
  Routes get alias => Routes.home;
}

final class SettingsPage extends AppPage {
  SettingsPage({required String data})
      : super(child: SettingsScreen(data: data), name: 'settings');

  @override
  Set<String> get tags => {'settings'};

  @override
  Routes get alias => Routes.settings;
}
```

### 3. Set Up the Navigator

Use `Elixir.controlled` with a `ValueNotifier` to manage the page stack:

```dart
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final ValueNotifier<ElixirNavigationState> _controller;

  @override
  void initState() {
    super.initState();
    _controller = ValueNotifier([const HomePage()]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        builder: (context, _) => Elixir.controlled(
          controller: _controller,
          guards: [
            (context, state) => state.length > 1 ? state : [const HomePage()],
            (context, state) => state.toSet().toList(),
          ],
        ),
      );
}
```

Alternatively, use the uncontrolled constructor for simpler setups:

```dart
Elixir(
  pages: [const HomePage()],
  guards: [...],
)
```

### 4. Navigate

Access navigation from any descendant widget via `context.elixir`:

```dart
// Push a page
context.elixir.push(SettingsPage(data: 'Hello'));

// Pop the top page
context.elixir.pop();

// Pop until a specific alias
context.elixir.popUntil(Routes.home);

// Arbitrary stack manipulation
context.elixir.change(
  (state) => state.where((e) => e.alias != Routes.settings).toList(),
);

// Reset to initial pages
context.elixir.reset();
```

For programmatic navigation outside the widget tree (e.g. from a controller), use the `ValueNotifier` extension:

```dart
controller.change((state) => [...state, SettingsPage(data: 'data')]);
controller.popUntil(Routes.home);
```

## Core API

### ElixirPage

Abstract base class for pages. Extends Flutter's `Page<void>`.

| Member          | Type                   | Description                                                      |
| --------------- | ---------------------- | ---------------------------------------------------------------- |
| `child`         | `Widget`               | The widget rendered by this page                                 |
| `name`          | `String`               | Derived from `alias.alias`                                       |
| `tags`          | `Set<String>`          | Set of tags for page identification and filtering                |
| `alias`         | `ElixirAlias`          | Unique route alias (typically an enum value)                     |
| `arguments`     | `Map<String, Object?>` | Optional arguments passed to the page                            |
| `key`           | `LocalKey`             | Auto-generated from name and arguments hash                      |
| `createRoute()` | `Route<void>`          | Defaults to `MaterialPageRoute`; override for custom transitions |

### ElixirAlias

An interface that route enums implement. Requires a single `String get alias` getter.

### ElixirNavigationState

Type alias for `List<ElixirPage>` — the immutable page stack.

### ElixirState

The state object exposed via `context.elixir` or `Elixir.of(context)`:

| Method                  | Description                                             |
| ----------------------- | ------------------------------------------------------- |
| `push(ElixirPage)`      | Append a page to the stack                              |
| `pop()`                 | Remove the top page                                     |
| `popUntil(ElixirAlias)` | Pop pages until the page with the given alias is on top |
| `change(fn)`            | Apply an arbitrary transformation to the page stack     |
| `reset(ElixirPage)`     | Reset to the initial pages                              |
| `revalidate()`          | Re-run all guards against the current stack             |
| `state`                 | Current `ElixirNavigationState`                         |
| `observer`              | `ElixirStateObserver` for tracking history              |
| `navigator`             | Underlying `NavigatorState`                             |

### Static Access

```dart
Elixir.of(context)        // ElixirState (throws if not found)
Elixir.maybeOf(context)   // ElixirState? (returns null if not found)
Elixir.stateOf(context)   // ElixirNavigationState?
Elixir.navigatorOf(context) // NavigatorState?
```

### Elixir Widget Parameters

| Parameter             | Type                                    | Description                                                            |
| --------------------- | --------------------------------------- | ---------------------------------------------------------------------- |
| `pages`               | `ElixirNavigationState`                 | Initial page stack                                                     |
| `controller`          | `ValueNotifier<ElixirNavigationState>?` | External controller (`.controlled` constructor)                        |
| `guards`              | `ElixirGuard`                           | List of guard functions applied on every state change                  |
| `observers`           | `List<NavigatorObserver>`               | Flutter navigator observers                                            |
| `transitionDelegate`  | `TransitionDelegate`                    | Controls transition behavior (defaults to `DefaultTransitionDelegate`) |
| `revalidate`          | `Listenable?`                           | When notified, re-runs guards against current state                    |
| `onBackButtonPressed` | `Function?`                             | Custom system back button handler; returns `({state, handled})`        |

## Guards

Guards are functions that intercept and transform every navigation state change. They run sequentially — each guard receives the output of the previous one.

```dart
guards: [
  // Ensure at least one page
  (context, state) => state.length > 1 ? state : [const HomePage()],

  // Deduplicate pages
  (context, state) => state.toSet().toList(),

  // Auth guard
  (context, state) {
    if (!isAuthenticated && state.any((p) => p.tags.contains('protected')))
      return [const LoginPage()];
    return state;
  },
],
```

If guards produce an empty list or a list equal to the current state, the navigation change is rejected.

## Navigation History

Track navigation changes via the observer:

```dart
final observer = context.elixir.observer;

// Listen for state changes
observer.addListener(() {
  final currentState = observer.value;
});

// Access timestamped history (up to 10,000 entries)
final history = observer.history; // List<ElixirHistoryEntry>
for (final entry in history) {
  print('${entry.timestamp}: ${entry.state}');
}
```

## Custom Transitions

Override `createRoute()` on a page to provide a custom route:

```dart
final class SettingsPage extends AppPage {
  SettingsPage({required String data})
      : super(child: SettingsScreen(data: data), name: 'settings');

  @override
  Route<void> createRoute(BuildContext context) => CustomMaterialRoute(page: this);

  @override
  Set<String> get tags => {'settings'};

  @override
  Routes get alias => Routes.settings;
}
```

### iOS Swipe-Back Gesture

Elixir ships `CupertinoBackGestureDetector` and `CupertinoBackGestureController` for adding iOS-style edge-swipe navigation to custom routes:

```dart
class CustomMaterialRoute extends PageRoute<void> {
  CustomMaterialRoute({required AppPage page}) : super(settings: page);

  AppPage get page => settings as AppPage;

  @override
  bool get popGestureEnabled => true;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => const ZoomPageTransitionsBuilder().buildTransitions(
    this, context, animation, secondaryAnimation,
    CupertinoBackGestureDetector<void>(
      enabledCallback: () => popGestureEnabled,
      onStartPopGesture: () => CupertinoBackGestureController<void>(
        navigator: navigator!,
        getIsActive: () => isActive,
        getIsCurrent: () => isCurrent,
        controller: controller!,
      ),
      child: child,
    ),
  );

  @override
  bool get maintainState => true;
  @override
  Color? get barrierColor => null;
  @override
  String? get barrierLabel => null;
  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);
  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) => page.child;
}
```

## Back Button Handling

Customize system back button behavior with `onBackButtonPressed`:

```dart
Elixir.controlled(
  controller: _controller,
  onBackButtonPressed: (state) => (
    handled: true,
    state: (state..removeLast()).toList(),
  ),
)
```

Return `handled: true` to consume the event, or `handled: false` to let the system handle it.

## Example

See the [example](example/) directory for a complete working application.

## License

This package is licensed under the terms specified in the LICENSE file.

## Author

Created and maintained by [Miracle-Blue](https://github.com/Miracle-Blue).
