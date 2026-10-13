// Path: features/gallery/presentation/gallery_columns.dart
/// Responsive column count shared by gallery + favorites grids (pure,
/// unit-testable). Keeps both screens on identical breakpoints (DRY).
int galleryCrossAxisCount(double width) {
  if (width < 360) return 2;
  if (width < 720) return 3;
  return 4;
}
