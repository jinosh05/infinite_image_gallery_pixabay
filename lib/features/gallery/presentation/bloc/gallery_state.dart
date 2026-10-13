// Path: features/gallery/presentation/bloc/gallery_state.dart
import "package:equatable/equatable.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/entities/photo.dart";

enum GalleryStatus { initial, loading, success, failure }

/// Single source of truth for gallery fetching.
///
/// [resolvedPageKey] tags the page the current [status]/[pageItems] belong
/// to (null while loading) — the page's `fetchPage` bridge awaits the state
/// matching its key, so concurrent/retried fetches never cross-talk.
class GalleryState extends Equatable {
  const GalleryState({
    this.query = "",
    this.category = "all",
    this.status = GalleryStatus.initial,
    this.pageItems = const <Photo>[],
    this.resolvedPageKey,
    this.totalHits = 0,
    this.errorMessage = "",
  });

  final String query;
  final String category;
  final GalleryStatus status;
  final List<Photo> pageItems;
  final int? resolvedPageKey;
  final int totalHits;
  final String errorMessage;

  GalleryState copyWith({
    String? query,
    String? category,
    GalleryStatus? status,
    List<Photo>? pageItems,
    int? Function()? resolvedPageKey,
    int? totalHits,
    String? errorMessage,
  }) =>
      GalleryState(
        query: query ?? this.query,
        category: category ?? this.category,
        status: status ?? this.status,
        pageItems: pageItems ?? this.pageItems,
        resolvedPageKey:
            resolvedPageKey != null ? resolvedPageKey() : this.resolvedPageKey,
        totalHits: totalHits ?? this.totalHits,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => <Object?>[
        query,
        category,
        status,
        pageItems,
        resolvedPageKey,
        totalHits,
        errorMessage,
      ];
}
