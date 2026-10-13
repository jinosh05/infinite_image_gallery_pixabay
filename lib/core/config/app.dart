// Path: core/config/app.dart
import "package:flutter/material.dart";
import "package:infinite_image_gallery_pixabay/core/config/app_dimensions.dart";
import "package:infinite_image_gallery_pixabay/core/config/app_typography.dart";
import "package:infinite_image_gallery_pixabay/core/config/space.dart";
import "package:infinite_image_gallery_pixabay/core/config/ui.dart";

/// [App] is the main configuration class for the application.
///
/// Migrated: jigsaw ad-logic removed (not needed for the gallery).
/// Single responsibility — responsive + typography bootstrap only.
/// Call once from the root widget's first build (or a splash initializer).
class App {
  App._();

  /// Returns whether the current text direction is Left-to-Right.
  static bool? isLtr;

  /// Initializes responsive metrics, spacing and typography.
  /// Must run after [MediaQuery] is available (i.e. inside a widget build).
  static void init(BuildContext context) {
    UI.init(context);
    AppDimensions.init();
    Space.init();
    AppText.init();
    isLtr = Directionality.of(context) == TextDirection.ltr;
  }
}
