// Path: features/favorites/presentation/bloc/favorites_bloc.dart
import "package:flutter_bloc/flutter_bloc.dart";
import "package:infinite_image_gallery_pixabay/core/constants/app_strings.dart";
import "package:infinite_image_gallery_pixabay/features/favorites/domain/repositories/favorites_repository.dart";
import "package:infinite_image_gallery_pixabay/features/favorites/presentation/bloc/favorites_event.dart";
import "package:infinite_image_gallery_pixabay/features/favorites/presentation/bloc/favorites_state.dart";

/// App-wide favorites (provided above `MaterialApp`, so gallery, detail and
/// favorites screens share one instance). Persistence lives in the
/// repository — this Bloc only orchestrates + announces.
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc({required this.repository})
      : super(const FavoritesState()) {
    on<FavoritesStarted>(_onStarted);
    on<FavoriteToggled>(_onToggled);
    on<FavoritesCleared>(_onCleared);
    on<FavoritesMessageConsumed>(
      (event, emit) => emit(state.copyWith(message: "")),
    );
  }

  final FavoritesRepository repository;

  Future<void> _onStarted(
    FavoritesStarted event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(state.copyWith(status: FavoritesStatus.loading));
    final result = await repository.getFavorites();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: FavoritesStatus.failure,
          message: failure.message,
        ),
      ),
      (photos) => emit(
        state.copyWith(status: FavoritesStatus.loaded, photos: photos),
      ),
    );
  }

  Future<void> _onToggled(
    FavoriteToggled event,
    Emitter<FavoritesState> emit,
  ) async {
    final result = await repository.toggleFavorite(event.photo);
    result.fold(
      (failure) => emit(state.copyWith(message: failure.message)),
      (toggle) => emit(
        state.copyWith(
          status: FavoritesStatus.loaded,
          photos: toggle.photos,
          message: toggle.isFavorite ? S.favoriteAdded : S.favoriteRemoved,
        ),
      ),
    );
  }

  Future<void> _onCleared(
    FavoritesCleared event,
    Emitter<FavoritesState> emit,
  ) async {
    final result = await repository.clearFavorites();
    result.fold(
      (failure) => emit(state.copyWith(message: failure.message)),
      (photos) => emit(
        state.copyWith(
          status: FavoritesStatus.loaded,
          photos: photos,
          message: S.favoritesCleared,
        ),
      ),
    );
  }
}
