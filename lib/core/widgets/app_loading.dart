// Path: core/widgets/app_loading.dart
import "package:flutter/material.dart";
import "package:infinite_image_gallery_pixabay/core/constants/app_colors.dart";
import "package:shimmer/shimmer.dart";

/// Shimmer grid placeholder for first-load (uses `shimmer` package).
///
/// Plain flex boxes — deliberately NOT a [GridView]: v5 slots first-page
/// indicators into `SliverFillRemaining`, which cannot measure any viewport
/// (lazy children defeat intrinsics). [Expanded] cells fill the remaining
/// space exactly, so this also works as a full-body loader.
class AppLoadingGrid extends StatelessWidget {
  const AppLoadingGrid({super.key, this.itemCount = 12, this.crossAxisCount = 2});

  final int itemCount;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    final int cols = crossAxisCount < 1 ? 2 : crossAxisCount;
    int rows = (itemCount / cols).ceil();
    if (rows < 1) rows = 1;
    if (rows > 4) rows = 4;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: <Widget>[
          for (int r = 0; r < rows; r++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: r == rows - 1 ? 0 : 10),
                child: Row(
                  children: <Widget>[
                    for (int c = 0; c < cols; c++)
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: c == cols - 1 ? 0 : 10,
                          ),
                          child: Shimmer.fromColors(
                            baseColor: AppColors.greyMuted,
                            highlightColor: Colors.white,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.greyMuted,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
