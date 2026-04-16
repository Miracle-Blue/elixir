/// Library for the Elixir navigation package.
/// ```dart
/// import 'package:elixir/elixir.dart';
/// ```
/// // Use the extension methods
/// context.elixir;
/// context.elixir.controller.change((state) => [...state, page]);
/// context.elixir.controller.popUntil('settings');
/// ```
library;

export 'src/cupertino_back/cupertino_back_gesture.dart';
export 'src/navigator/elixir_page.dart';
export 'src/navigator/navigator.dart';
export 'src/navigator/observer.dart';
export 'src/util/context_extension.dart';
