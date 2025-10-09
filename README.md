# Elixir

A declarative navigation package for Flutter that provides a clean, type-safe approach to managing navigation state using the Navigator 2.0 API.

## Overview

Elixir is a lightweight navigation library that simplifies Flutter's Navigator 2.0 implementation by providing:

- **Declarative Navigation**: Manage navigation state as a list of pages
- **Type-Safe Pages**: Define custom page types with compile-time safety
- **Navigation Guards**: Apply rules to control navigation flow
- **State Observation**: Track navigation history and state changes
- **Custom Transitions**: Define custom page transitions per route
- **Back Button Handling**: Custom back button behavior support

## Features

- ✅ Declarative navigation with immutable state
- ✅ Type-safe page definitions using sealed classes
- ✅ Navigation guards for access control and validation
- ✅ Navigation history tracking with observer pattern
- ✅ Custom page transitions support
- ✅ Deep linking support through Navigator 2.0
- ✅ Programmatic navigation with push/pop/change methods
- ✅ Built-in context extensions for easy access

## Getting started

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

### 1. Define Your Pages

Create custom page types by extending `ElixirPage`:

```dart
import 'package:elixir/elixir.dart';
import 'package:flutter/material.dart';

@immutable
sealed class AppPage extends ElixirPage {
  const AppPage({
    required super.name,
    required super.child,
    super.arguments,
    super.key,
  });

  @override
  String toString() => '/$name${arguments.isEmpty ? '' : '~$arguments'}';
}

final class HomePage extends AppPage {
  const HomePage() : super(child: const HomeScreen(), name: 'home');

  @override
  Set<String> get tags => {'home'};
}

final class SettingsPage extends AppPage {
  SettingsPage({required String data})
      : super(
          child: SettingsScreen(data: data),
          name: 'settings',
        );

  @override
  Set<String> get tags => {'settings'};
}
```

### 2. Set Up Navigation

Use the `Elixir` widget in your app:

```dart
import 'package:elixir/elixir.dart';
import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) => MaterialApp(
        title: 'Elixir Example',
        builder: (context, _) => Elixir.controlled(
          controller: _controller,
          guards: [
            // Ensure at least one page is always present
            (context, state) => state.length > 1 ? state : [const HomePage()],
          ],
        ),
      );
}
```

### 3. Navigate Between Pages

Use the context extension to navigate:

```dart
import 'package:elixir/elixir.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // Navigate to settings page
                context.elixir.push(SettingsPage(data: 'Hello from home'));
              },
            ),
          ],
        ),
        body: const Center(child: Text('Home Screen')),
      );
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.data, super.key});

  final String data;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Navigate back by removing pages with 'settings' tag
              context.elixir.change(
                (state) => state.where((e) => !e.tags.contains('settings')).toList(),
              );
            },
          ),
        ),
        body: Center(child: Text('Data: $data')),
      );
}
```

## Core Concepts

### ElixirPage

An abstract base class for defining navigation pages. Each page must implement:
- `child`: The widget to display
- `name`: A unique name for the page
- `tags`: A set of tags for page identification

### ElixirNavigationState

A type alias for `List<ElixirPage>` representing the current navigation stack.

### Navigation Methods

- `push(ElixirPage page)`: Add a page to the navigation stack
- `pop()`: Remove the last page from the stack
- `change(fn)`: Apply custom transformations to the navigation state
- `reset(ElixirPage page)`: Reset to initial pages

### Guards

Guards are functions that intercept and modify navigation state changes:

```dart
ElixirGuard guards = [
  // Example: Redirect to login if not authenticated
  (context, state) {
    final isAuthenticated = checkAuth();
    if (!isAuthenticated && state.any((page) => page.tags.contains('protected'))) {
      return [LoginPage()];
    }
    return state;
  },
];
```

### State Observation

Track navigation changes using the observer:

```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  @override
  void initState() {
    super.initState();
    final observer = context.elixir.observer;
    observer.addListener(() {
      print('Navigation changed: ${observer.value}');
    });
  }

  @override
  Widget build(BuildContext context) => Container();
}
```

### Custom Transitions

Define custom transitions per page:

```dart
final class SettingsPage extends AppPage {
  SettingsPage({required String data})
      : super(child: SettingsScreen(data: data), name: 'settings');

  @override
  Route<void> createRoute(BuildContext context) => 
      CustomMaterialRoute(page: this);

  @override
  Set<String> get tags => {'settings'};
}

class CustomMaterialRoute extends PageRoute<void> {
  CustomMaterialRoute({required AppPage page}) : super(settings: page);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => ZoomPageTransitionsBuilder().buildTransitions(
        this,
        context,
        animation,
        secondaryAnimation,
        child,
      );

  // ... other overrides
}
```

## Example

Check out the [example](example/) directory for a complete working application demonstrating all features.

## Additional Information

### Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Issues

File issues and feature requests at the [GitHub issue tracker](https://github.com/Miracle-Blue/elixir/issues).

### License

This package is licensed under the terms specified in the LICENSE file.

### Author

Created and maintained by [Miracle-Blue](https://github.com/Miracle-Blue).
