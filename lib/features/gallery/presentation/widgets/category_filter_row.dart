// Path: features/gallery/presentation/widgets/category_filter_row.dart
import "package:flutter/material.dart";
import "package:infinite_image_gallery_pixabay/core/constants/api_constants.dart";

/// Horizontal category chips (Pixabay categories, bonus feature).
/// Pure: renders [selected], reports taps — filtering lives in the Bloc.
class CategoryFilterRow extends StatelessWidget {
  const CategoryFilterRow({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  static String labelOf(String category) =>
      category == "all" ? "All" : category[0].toUpperCase() + category.substring(1);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: ApiConstants.categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final String category = ApiConstants.categories[index];
          return ChoiceChip(
            label: Text(labelOf(category)),
            selected: category == selected,
            onSelected: (_) => onSelected(category),
          );
        },
      ),
    );
  }
}
