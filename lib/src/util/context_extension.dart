import 'package:flutter/material.dart';

import '../navigator/navigator.dart';

extension ElixirContextExtension on BuildContext {
  ElixirState get elixir => Elixir.of(this);
}
