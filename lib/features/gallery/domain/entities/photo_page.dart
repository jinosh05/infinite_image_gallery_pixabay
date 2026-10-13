// Path: features/gallery/domain/entities/photo_page.dart
import "package:equatable/equatable.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/entities/photo.dart";

/// One fetched page plus the server-reported total.
/// The presentation layer accumulates pages; this object answers
/// "are we done?" without knowing about controllers (DIP).
class PhotoPage extends Equatable {
  const PhotoPage({
    required this.photos,
    required this.totalHits,
    required this.page,
    required this.perPage,
  });

  final List<Photo> photos;
  final int totalHits;
  final int page;
  final int perPage;

  /// True when the server has nothing more to give.
  /// [accumulatedCount] = total items loaded so far (all pages).
  /// An empty page always means "last" — Pixabay caps deep paging, so an
  /// empty `hits` wins over `totalHits` (see Plans.md §0.2).
  bool isLastPage(int accumulatedCount) =>
      photos.isEmpty || accumulatedCount >= totalHits;

  /// Next 1-based page key for `PagingController`, or null when finished.
  int? nextPageKey(int accumulatedCount) =>
      isLastPage(accumulatedCount) ? null : page + 1;

  @override
  List<Object?> get props => <Object?>[photos, totalHits, page, perPage];
}
