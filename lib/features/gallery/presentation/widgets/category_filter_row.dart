// Path: features/gallery/presentation/widgets/category_filter_row.dart
import "package:flutter/material.dart";
import "package:infinite_image_gallery_pixabay/core/constants/api_constants.dart";

/// Horizontal category chips (Pixabay categories, bonus feature).
/// Pure: renders [selected], reports taps — filtering lives in the Bloc.
///
/// Colors are explicit per state (never theme-inherited): the inherited
/// M3 label style rendered near-invisible text on light fills in light
/// theme, so selected/unselected contrast is pinned to scheme tokens here.
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
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: ApiConstants.categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final String category = ApiConstants.categories[index];
          final bool isSelected = category == selected;
          return ChoiceChip(
            label: Text(
              labelOf(category),
              style: TextStyle(
                color: isSelected ? scheme.onPrimary : scheme.onSurface,
              ),
            ),
            selected: isSelected,
            selectedColor: scheme.primary,
            backgroundColor: scheme.surfaceContainerHighest,
            checkmarkColor:
                isSelected ? scheme.onPrimary : scheme.onSurface,
            side: BorderSide(
              color: isSelected ? scheme.primary : scheme.outlineVariant,
            ),
            onSelected: (_) => onSelected(category),
          );
        },
      ),
    );
  }
}
