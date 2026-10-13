// Path: features/gallery/presentation/bloc/gallery_bloc.dart
import "package:flutter_bloc/flutter_bloc.dart";
import "package:infinite_image_gallery_pixabay/core/config/env_config.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/entities/photo.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/repositories/gallery_repository.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/use_cases/get_photos.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/presentation/bloc/gallery_event.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/presentation/bloc/gallery_state.dart";

/// Owns gallery filter state + all fetching via [GetPhotos].
///
/// Paging mechanics (page keys, dedup, loading flags) stay in
/// `PagingController`; this Bloc answers "what to fetch" (query/category)
/// and "what came back" (items/total/error tagged by page key).
class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  // An initializing formal would privatize the `getPhotos` named argument
  // for external call sites (injection_container, tests).
  GalleryBloc({required GetPhotos getPhotos, int? perPage})
      // ignore: prefer_initializing_formals
      : _getPhotos = getPhotos,
        _perPage = perPage ?? EnvConfig.defaultPerPage,
        super(const GalleryState()) {
    on<GalleryPageRequested>(_onPageRequested);
    on<GalleryQueryChanged>(_onQueryChanged);
    on<GalleryCategoryChanged>(_onCategoryChanged);
  }

  final GetPhotos _getPhotos;
  final int _perPage;

  Future<void> _onPageRequested(
    GalleryPageRequested event,
    Emitter<GalleryState> emit,
  ) async {
    emit(
      state.copyWith(
        status: GalleryStatus.loading,
        resolvedPageKey: () => null,
        errorMessage: "",
      ),
    );
    final result = await _getPhotos(
      GalleryParams(
        query: state.query,
        category: state.category,
        page: event.pageKey,
        perPage: _perPage,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: GalleryStatus.failure,
          resolvedPageKey: () => event.pageKey,
          errorMessage: failure.message,
        ),
      ),
      (page) => emit(
        state.copyWith(
          status: GalleryStatus.success,
          pageItems: page.photos,
          resolvedPageKey: () => event.pageKey,
          totalHits: page.totalHits,
        ),
      ),
    );
  }

  void _onQueryChanged(
    GalleryQueryChanged event,
    Emitter<GalleryState> emit,
  ) {
    final String query = event.query.trim();
    if (query == state.query) return;
    emit(
      state.copyWith(
        query: query,
        status: GalleryStatus.initial,
        pageItems: const <Photo>[],
        resolvedPageKey: () => null,
        totalHits: 0,
        errorMessage: "",
      ),
    );
  }

  void _onCategoryChanged(
    GalleryCategoryChanged event,
    Emitter<GalleryState> emit,
  ) {
    if (event.category == state.category) return;
    emit(
      state.copyWith(
        category: event.category,
        status: GalleryStatus.initial,
        pageItems: const <Photo>[],
        resolvedPageKey: () => null,
        totalHits: 0,
        errorMessage: "",
      ),
    );
  }
}
