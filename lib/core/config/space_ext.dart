// Path: core/config/space_ext.dart
import "package:flutter/material.dart";
import "package:infinite_image_gallery_pixabay/core/config/app_dimensions.dart";
import "package:infinite_image_gallery_pixabay/core/config/ui.dart";

/// [SuperEdgeInsets] provides helper methods for modifying [EdgeInsets].
extension SuperEdgeInsets on EdgeInsets {
  /// Adds safe area padding to both top and bottom.
  EdgeInsets sv() =>
      copyWith(top: top + UI.padding!.top, bottom: bottom + UI.padding!.bottom);

  /// Adds safe area padding to the top.
  EdgeInsets st() => copyWith(top: top + UI.padding!.top);

  /// Adds safe area padding to the bottom.
  EdgeInsets sb() => copyWith(bottom: bottom + UI.padding!.bottom);

  /// Sets the bottom padding with a multiplier.
  EdgeInsets b(double no) => copyWith(bottom: AppDimensions.space(no));

  /// Sets the top padding with a multiplier.
  EdgeInsets t(double no) => copyWith(top: AppDimensions.space(no));

  /// Sets the left padding with a multiplier.
  EdgeInsets l(double no) => copyWith(left: AppDimensions.space(no));

  /// Sets the right padding with a multiplier.
  EdgeInsets r(double no) => copyWith(right: AppDimensions.space(no));

  /// Sets the bottom padding without multiplier.
  EdgeInsets bm(double no) => copyWith(bottom: no);

  /// Sets the top padding without multiplier.
  EdgeInsets tm(double no) => copyWith(top: no);

  /// Sets the left padding without multiplier.
  EdgeInsets lm(double no) => copyWith(left: no);

  /// Sets the right padding without multiplier.
  EdgeInsets rm(double no) => copyWith(right: no);
}
