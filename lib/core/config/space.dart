// Path: core/config/space.dart
import "package:flutter/material.dart";
import "package:infinite_image_gallery_pixabay/core/config/app_dimensions.dart";
import "package:infinite_image_gallery_pixabay/core/config/ui.dart";

/// [Space] provides predefined spacing widgets and edge insets.
class Space {
  Space._();

  /// Horizontal space (0.5 units).
  static Widget? x;

  /// Vertical space (0.5 units).
  static Widget? y;

  /// Horizontal space (1 unit).
  static Widget? x1;

  /// Vertical space (1 unit).
  static Widget? y1;

  /// Horizontal space (2 units).
  static Widget? x2;

  /// Vertical space (2 units).
  static Widget? y2;

  /// Expanded horizontal space taking all available width.
  static Widget? xm;

  /// Expanded vertical space taking all available height.
  static Widget? ym;

  /// Zero edge insets.
  static EdgeInsets? z;

  /// Horizontal edge insets (0.5 units).
  static EdgeInsets? h;

  /// Vertical edge insets (0.5 units).
  static EdgeInsets? v;

  /// Horizontal edge insets (1 unit).
  static EdgeInsets? h1;

  /// Vertical edge insets (1 unit).
  static EdgeInsets? v1;

  /// Horizontal edge insets (2 units).
  static EdgeInsets? h2;

  /// Vertical edge insets (2 units).
  static EdgeInsets? v2;

  /// Spacing for the top safe area.
  static Widget? top;

  /// Spacing for the bottom safe area.
  static Widget? bottom;

  /// Initializes the spacing configuration.
  static void init() {
    x = SizedBox(width: AppDimensions.space(0.5));
    y = SizedBox(height: AppDimensions.space(0.5));

    x1 = SizedBox(width: AppDimensions.space());
    y1 = SizedBox(height: AppDimensions.space());

    x2 = SizedBox(width: AppDimensions.space(2));
    y2 = SizedBox(height: AppDimensions.space(2));

    xm = const Expanded(child: SizedBox(width: double.infinity));
    ym = const Expanded(child: SizedBox(height: double.infinity));

    z = EdgeInsets.zero;
    h = EdgeInsets.symmetric(horizontal: AppDimensions.space(0.5));
    v = EdgeInsets.symmetric(vertical: AppDimensions.space(0.5));

    h1 = EdgeInsets.symmetric(horizontal: AppDimensions.space());
    v1 = EdgeInsets.symmetric(vertical: AppDimensions.space());

    h2 = EdgeInsets.symmetric(horizontal: AppDimensions.space(2));
    v2 = EdgeInsets.symmetric(vertical: AppDimensions.space(2));

    top = SizedBox(height: UI.padding!.top);
    bottom = SizedBox(height: UI.padding!.bottom);
  }

  /// Creates a horizontal [SizedBox] with responsive width.
  static Widget xf([double no = 1]) => SizedBox(width: AppDimensions.space(no));

  /// Creates a vertical [SizedBox] with responsive height.
  static Widget yf([double no = 1]) =>
      SizedBox(height: AppDimensions.space(no));

  /// Creates horizontal [EdgeInsets] with responsive duration.
  static EdgeInsets hf([double no = 1]) =>
      EdgeInsets.symmetric(horizontal: AppDimensions.space(no));

  /// Creates vertical [EdgeInsets] with responsive duration.
  static EdgeInsets vf([double no = 1]) =>
      EdgeInsets.symmetric(vertical: AppDimensions.space(no));

  /// Creates symmetric [EdgeInsets] with responsive duration.
  static EdgeInsets all([double h = 0.5, double? v]) => EdgeInsets.symmetric(
    vertical: AppDimensions.space(v ?? h),
    horizontal: AppDimensions.space(h),
  );
}
