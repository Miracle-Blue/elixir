import 'dart:async';

import 'package:example/src/common/widget/app.dart';
import 'package:flutter/material.dart';

void main() => runZonedGuarded<void>(
  () => runApp(const App()),
  (error, stackTrace) => print('Top level exception: $error'), // ignore: avoid_print
);
