// Path: routes/app_routes.dart
// Ignore types for simplicity in routes
// ignore_for_file: always_specify_types

import "package:flutter/material.dart";

/// A utility class for routing and navigation.
class AppRoutes {
  AppRoutes._();

  /// Pushes a new [page] onto the routing stack.
  static Future<void> push(BuildContext context, Widget page) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (BuildContext context) => page));
  }

  /// Replaces the current page with [page] using a slide-up transition.
  static Future<void> replace(BuildContext context, Widget page) async {
    await Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1, 0); // Start from the right (1.0)
          const Offset end = Offset.zero; // End at the current position (0.0)
          const Cubic curve = Curves.ease;

          final Animatable<Offset> tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          final Animation<Offset> offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  /// Replaces the current page with [page] using a slide-left transition.
  static Future<void> replaceLeftSwipe(
    BuildContext context,
    Widget page,
  ) async {
    await Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(-1, 0); // Start from the left (-1.0)
          const Offset end = Offset.zero; // End at the current position (0.0)
          const Cubic curve = Curves.ease;

          final Animatable<Offset> tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          final Animation<Offset> offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  /// Clears navigation stack back to the first route and replaces with [page].
  static Future<void> makeFirst(BuildContext context, Widget page) async {
    Navigator.of(context).popUntil((Route predicate) => predicate.isFirst);
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (BuildContext context) => page),
    );
  }

  /// Pops the current route off the navigation stack.
  static void pop(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Dismisses the currently displayed alert dialog.
  static void dismissAlert(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Pushes [page] and removes all previous routes.
  static Future<void> pushAndRemove(BuildContext context, Widget page) async {
    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => page),
      (Route route) => false,
    );
  }
}
