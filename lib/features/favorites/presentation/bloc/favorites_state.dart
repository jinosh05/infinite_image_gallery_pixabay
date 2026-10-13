// Path: features/favorites/presentation/bloc/favorites_state.dart
import "package:equatable/equatable.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/entities/photo.dart";

enum FavoritesStatus { initial, loading, loaded, failure }

/// Global favorites state. [ids] derives from [photos] (single source of
/// truth — never stored twice). [message] is a one-shot UI announcement
/// consumed by [FavoritesMessenger].
class FavoritesState extends Equatable {
  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.photos = const <Photo>[],
    this.message = "",
  });

  final FavoritesStatus status;
  final List<Photo> photos;
  final String message;

  Set<int> get ids => <int>{for (final Photo p in photos) p.id};

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<Photo>? photos,
    String? message,
  }) =>
      FavoritesState(
        status: status ?? this.status,
        photos: photos ?? this.photos,
        message: message ?? this.message,
      );

  @override
  List<Object?> get props => <Object?>[status, photos, message];
}
