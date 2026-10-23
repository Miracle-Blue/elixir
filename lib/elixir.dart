/// Declarative Navigator 2.0 navigation built on widgets only (no Material dependency).
/// ```dart
/// import 'package:elixir/elixir.dart';
///
/// context.elixir.push(page);
/// context.elixir.change((state) => [...state, page]);
/// context.elixir.popUntil(Routes.settings);
/// ```
library;

export 'src/cupertino_back/cupertino_back_gesture.dart';
export 'src/navigator/elixir_page.dart';
export 'src/navigator/navigator.dart';
export 'src/navigator/observer.dart';
export 'src/util/context_extension.dart';
