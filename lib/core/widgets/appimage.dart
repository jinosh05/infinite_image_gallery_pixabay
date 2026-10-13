// Path: core/widgets/appimage.dart
import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:infinite_image_gallery_pixabay/core/constants/app_colors.dart";
import "package:shimmer/shimmer.dart";

/// Gallery image widget: network-first with shimmer placeholder.
///
/// Migrated from the jigsaw version — Lottie/SVG/package branches and the
/// custom [NeverRefreshCacheManager] removed (SRP: gallery only needs
/// cached network images + asset fallback). `cached_network_image` already
/// handles memory + disk caching for image performance.
class AppImage extends StatelessWidget {
  const AppImage({
    required this.imageUrl,
    super.key,
    this.width,
    this.size,
    this.height,
    this.fit,
    this.color,
    this.errorImg,
    this.borderRadius,
  });

  /// Network URL or local asset path (non-http → [Image.asset]).
  final String imageUrl;

  /// Optional asset shown while loading AND on error (default: grey box).
  final String? errorImg;

  final double? width;

  /// Uniform size — takes precedence over [width]/[height].
  final double? size;

  final double? height;
  final BoxFit? fit;
  final Color? color;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) return const SizedBox.shrink();

    final double? w = size ?? width;
    final double? h = size ?? height;
    final BoxFit effectiveFit = fit ?? BoxFit.cover;

    Widget placeholder() {
      if (errorImg != null) {
        return Image.asset(
          errorImg!,
          width: w,
          height: h,
          fit: effectiveFit,
          color: color,
        );
      }
      return Container(width: w, height: h, color: AppColors.greyMuted);
    }

    Widget resolved;
    if (!imageUrl.contains("http")) {
      resolved = Image.asset(
        imageUrl,
        width: w,
        height: h,
        fit: effectiveFit,
        color: color,
        errorBuilder: (_, _, _) => placeholder(),
      );
    } else {
      resolved = CachedNetworkImage(
        imageUrl: imageUrl,
        width: w,
        height: h,
        fit: effectiveFit,
        color: color,
        fadeInDuration: const Duration(milliseconds: 250),
        fadeOutDuration: const Duration(milliseconds: 150),
        memCacheWidth: w == null ? null : (w * 2).round(),
        placeholder: (_, _) => Shimmer.fromColors(
          baseColor: AppColors.greyMuted,
          highlightColor: Colors.white,
          child: placeholder(),
        ),
        errorWidget: (_, _, _) => placeholder(),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: resolved);
    }
    return resolved;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty("imageUrl", imageUrl))
      ..add(StringProperty("errorImg", errorImg))
      ..add(DoubleProperty("width", width))
      ..add(DoubleProperty("size", size))
      ..add(DoubleProperty("height", height))
      ..add(EnumProperty<BoxFit?>("fit", fit))
      ..add(ColorProperty("color", color));
  }
}
