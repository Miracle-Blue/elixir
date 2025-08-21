import 'package:flutter/material.dart';

import '../navigator/navigator.dart';

extension ContextExtension on BuildContext {
  ElixirState get elixir => Elixir.of(this);
}
