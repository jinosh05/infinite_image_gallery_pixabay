// Path: features/favorites/presentation/bloc/favorites_event.dart
import "package:equatable/equatable.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/entities/photo.dart";

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Load persisted favorites (dispatched once at app startup).
class FavoritesStarted extends FavoritesEvent {
  const FavoritesStarted();
}

/// Toggle one photo, then announce the outcome via [FavoritesState.message].
class FavoriteToggled extends FavoritesEvent {
  const FavoriteToggled(this.photo);

  final Photo photo;

  @override
  List<Object?> get props => <Object?>[photo];
}

/// Remove everything (after user confirmation in the UI).
class FavoritesCleared extends FavoritesEvent {
  const FavoritesCleared();
}

/// Reset [FavoritesState.message] after the messenger showed it.
class FavoritesMessageConsumed extends FavoritesEvent {
  const FavoritesMessageConsumed();
}
