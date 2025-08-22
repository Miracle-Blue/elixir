import 'package:flutter/material.dart';

import 'routes.dart';

/// {@template custom_material_route}
/// CustomMaterialRoute widget.
/// {@endtemplate}
class CustomMaterialRoute extends PageRoute<void> {
  /// {@macro custom_material_route}
  CustomMaterialRoute({required AppPage page}) : super(settings: page);

  /// {@macro custom_material_route}
  AppPage get page => settings as AppPage;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) =>
      page.child;

  @override
  bool get maintainState => true;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => const ZoomPageTransitionsBuilder().buildTransitions(this, context, animation, secondaryAnimation, child);
}
