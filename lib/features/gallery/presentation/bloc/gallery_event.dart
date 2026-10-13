// Path: features/gallery/presentation/bloc/gallery_event.dart
import "package:equatable/equatable.dart";

/// Gallery UI intents. Paging itself is owned by `PagingController` (v5);
/// these events carry user/filter intent + page demand into the Bloc.
abstract class GalleryEvent extends Equatable {
  const GalleryEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// One page of items is needed (from the paging controller's `fetchPage`).
class GalleryPageRequested extends GalleryEvent {
  const GalleryPageRequested(this.pageKey);

  final int pageKey;

  @override
  List<Object?> get props => <Object?>[pageKey];
}

/// Search query changed (dispatched debounced from the search field).
class GalleryQueryChanged extends GalleryEvent {
  const GalleryQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => <Object?>[query];
}

/// Category filter changed (from the filter chips).
class GalleryCategoryChanged extends GalleryEvent {
  const GalleryCategoryChanged(this.category);

  final String category;

  @override
  List<Object?> get props => <Object?>[category];
}
