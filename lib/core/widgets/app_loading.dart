// Path: core/widgets/app_loading.dart
import "package:flutter/material.dart";
import "package:infinite_image_gallery_pixabay/core/constants/app_colors.dart";
import "package:shimmer/shimmer.dart";

/// Shimmer grid placeholder for first-load (uses `shimmer` package).
/// Pagination footers use a plain loader — this is only for full-screen load.
class AppLoadingGrid extends StatelessWidget {
  const AppLoadingGrid({super.key, this.itemCount = 12, this.crossAxisCount = 2});

  final int itemCount;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: itemCount,
      itemBuilder: (_, _) => Shimmer.fromColors(
        baseColor: AppColors.greyMuted,
        highlightColor: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.greyMuted,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
