// Path: core/config/app_typography.dart
import "package:flutter/material.dart";
import "package:infinite_image_gallery_pixabay/core/config/app_dimensions.dart";
import "package:infinite_image_gallery_pixabay/core/constants/app_colors.dart";
import "package:infinite_image_gallery_pixabay/core/utils/font_utils.dart";

/// [AppText] provides predefined text styles for the application.
class AppText {
  AppText._();

  // Headings
  /// Heading 1 style.
  static TextStyle? h1;

  /// Heading 1 bold style.
  static TextStyle? h1b;

  /// Heading 2 style.
  static TextStyle? h2;

  /// Heading 2 bold style.
  static TextStyle? h2b;

  /// Heading 3 style.
  static TextStyle? h3;

  /// Heading 3 bold style.
  static TextStyle? h3b;

  /// Heading 4 style.
  static TextStyle? h4;

  /// Heading 4 bold style.
  static TextStyle? h4b;

  // Body
  /// Body text 1 style.
  static TextStyle? b1;

  /// Body text 1 bold style.
  static TextStyle? b1b;

  /// Body text 2 style.
  static TextStyle? b2;

  /// Body text 2 bold style.
  static TextStyle? b2b;

  /// Body text 3 style.
  static TextStyle? b3;

  /// Body text 3 bold style.
  static TextStyle? b3b;

  // Label
  /// Label text 1 style.
  static TextStyle? l1;

  /// Label text 1 bold style.
  static TextStyle? l1b;

  /// Label text 2 style.
  static TextStyle? l2;

  /// Label text 2 bold style.
  static TextStyle? l2b;

  /// Initializes the typography configuration.
  static void init() {
    const FontWeight b = FontWeight.bold;

    final TextStyle baseStyle = FontUtils.getSafeGoogleFont("Inter");

    h1 = baseStyle.copyWith(fontSize: AppDimensions.font(22));
    h1b = h1!.copyWith(fontWeight: b);

    h2 = baseStyle.copyWith(fontSize: AppDimensions.font(18));
    h2b = h2!.copyWith(fontWeight: b);

    h3 = baseStyle.copyWith(fontSize: AppDimensions.font(15));
    h3b = h3!.copyWith(fontWeight: b);

    h4 = baseStyle.copyWith(fontSize: AppDimensions.font(12));
    h4b = h4!.copyWith(fontWeight: b);

    b1 = baseStyle.copyWith(fontSize: AppDimensions.font(10));
    b1b = b1!.copyWith(fontWeight: b);

    b2 = baseStyle.copyWith(fontSize: AppDimensions.font(8));
    b2b = b2!.copyWith(fontWeight: b);

    b3 = baseStyle.copyWith(fontSize: AppDimensions.font(7));
    b3b = b3!.copyWith(fontWeight: b);

    l1 = baseStyle.copyWith(fontSize: AppDimensions.font(6));
    l1b = l1!.copyWith(fontWeight: b);

    l2 = baseStyle.copyWith(fontSize: AppDimensions.font(4));
    l2b = l2!.copyWith(fontWeight: b);
  }
}

/// [SuperTextStyles] provides helper methods for modifying [TextStyle].
extension SuperTextStyles on TextStyle {
  /// Sets the font family.
  TextStyle ff(String fontFamily) =>
      FontUtils.getSafeGoogleFont(fontFamily, textStyle: this);

  /// Sets the color.
  TextStyle cl(Color color) => copyWith(color: color);

  /// Sets the font style to italic.
  TextStyle ita() => copyWith(fontStyle: FontStyle.italic);

  /// Sets the font size.
  TextStyle s([double? size]) => copyWith(fontSize: size ?? fontSize);

  /// Multiplies the current font size by [multiplier].
  TextStyle tsc([double multiplier = 1.0]) =>
      copyWith(fontSize: fontSize! * multiplier);

  /// Sets the font weight based on an index (3-9).
  TextStyle w(int i) {
    FontWeight w = FontWeight.w400;

    if (i == 3) {
      w = FontWeight.w300;
    }
    if (i == 4) {
      w = FontWeight.w400;
    }
    if (i == 5) {
      w = FontWeight.w500;
    }
    if (i == 6) {
      w = FontWeight.w600;
    }
    if (i == 7) {
      w = FontWeight.w700;
    }
    if (i == 8) {
      w = FontWeight.w800;
    }
    if (i == 9) {
      w = FontWeight.w900;
    }
    return copyWith(fontWeight: w);
  }
}

/// [CustomTextStyles] provides application-specific [TextStyle] modifiers.
extension CustomTextStyles on TextStyle {
  /// Sets the color to the primary application color.
  TextStyle priClr() => copyWith(color: AppColors.forestGreen);

  /// Sets the color to the secondary application color (dark blue).
  TextStyle secClr() => copyWith(color: AppColors.gold);

  TextStyle montserrat() => copyWith(fontFamily: "Montserrat");
}
