// Path: core/config/ui.dart
import "dart:math";

import "package:flutter/widgets.dart";

/// [UI] provides screen-related measurements and device checks.
class UI {
  UI._();
  static MediaQueryData? _mediaQueryData;

  /// Screen width.
  static double? width;

  /// Screen height.
  static double? height;

  /// Horizontal percentage unit (1% of width).
  static double? horizontal;

  /// Vertical percentage unit (1% of height).
  static double? vertical;

  /// Padding before keyboard is raised.
  static EdgeInsets? padding;

  /// View insets (e.g., keyboard height).
  static EdgeInsets? vi;
  static double? _safeAreaHorizontal;
  static double? _safeAreaVertical;

  /// Width excluding safe area padding.
  static double? safeWidth;

  /// Height excluding safe area padding.
  static double? safeHeight;

  /// Diagonal screen size.
  static double? diagonal;

  /// Extra extra small screen check.
  static bool? xxs;

  /// Extra small screen check.
  static bool? xs;

  /// Small screen check.
  static bool? sm;

  /// Medium screen check.
  static bool? md;

  /// Extra medium screen check.
  static bool? xmd;

  /// Large screen check.
  static bool? lg;

  /// Extra large screen check.
  static bool? xl;

  /// Extra extra large screen check.
  static bool? xlg;

  /// Extra extra extra large screen check (reserved).
  static bool? xxlg;

  /// Whether the screen is in portrait mode.
  static bool isPortrait = false;

  /// Physical screen size.
  static Size? physicalSize;

  /// Initializes the UI measurements.
  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    initChecks(_mediaQueryData!);

    padding = _mediaQueryData!.padding;
    vi = _mediaQueryData!.viewInsets;
    width = _mediaQueryData!.size.width;
    height = _mediaQueryData!.size.height;
    horizontal = width! / 100;
    vertical = height! / 100;

    _safeAreaHorizontal =
        _mediaQueryData!.padding.left + _mediaQueryData!.padding.right;
    _safeAreaVertical =
        _mediaQueryData!.padding.top + _mediaQueryData!.padding.bottom;
    safeWidth = width! - _safeAreaHorizontal!;
    safeHeight = height! - _safeAreaVertical!;

    ///
    isPortrait = (width ?? 0) < 600;
    physicalSize = View.of(context).physicalSize;
  }

  /// Initializes screen size checks.
  static void initChecks(MediaQueryData query) {
    final Size size = query.size;
    diagonal = sqrt((size.width * size.width) + (size.height * size.height));
    xxs = size.width > 300;
    xs = size.width > 360;
    sm = size.width > 480;
    md = size.width > 600;
    xmd = size.width > 720;
    lg = size.width > 980;
    xl = size.width > 1160;
    xlg = size.width > 1400;
    xxlg = size.width > 1700;
  }

  /// Returns the current [MediaQueryData].
  static MediaQueryData mediaQuery() => _mediaQueryData!;

  /// Returns the current screen [Size].
  static Size getSize() => _mediaQueryData!.size;
}
