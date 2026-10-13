// Path: features/gallery/presentation/pages/gallery_page.dart
import "package:custom_masonry_grid/custom_masonry_grid.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:infinite_image_gallery_pixabay/core/constants/app_strings.dart";
import "package:infinite_image_gallery_pixabay/core/routes/app_routes.dart";
import "package:infinite_image_gallery_pixabay/core/widgets/app_empty_view.dart";
import "package:infinite_image_gallery_pixabay/core/widgets/app_error_view.dart";
import "package:infinite_image_gallery_pixabay/core/widgets/app_loading.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/entities/photo.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/presentation/bloc/gallery_bloc.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/presentation/bloc/gallery_event.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/presentation/bloc/gallery_state.dart";
import "package:infinite_image_gallery_pixabay/features/detail/presentation/pages/detail_page.dart";
import "package:infinite_image_gallery_pixabay/features/favorites/presentation/bloc/favorites_bloc.dart";
import "package:infinite_image_gallery_pixabay/features/favorites/presentation/bloc/favorites_event.dart";
import "package:infinite_image_gallery_pixabay/features/favorites/presentation/pages/favorites_page.dart";
import "package:infinite_image_gallery_pixabay/features/favorites/presentation/widgets/favorites_listener.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/presentation/gallery_columns.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/presentation/widgets/category_filter_row.dart";import "package:infinite_image_gallery_pixabay/features/gallery/presentation/widgets/gallery_search_field.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/presentation/widgets/photo_tile.dart";
import "package:infinite_image_gallery_pixabay/features/theme/presentation/widgets/theme_toggle_button.dart";
import "package:infinite_scroll_pagination/infinite_scroll_pagination.dart";

/// Error carrier from the Bloc bridge into the paging controller.
/// Must extend [Exception]: v5 rethrows non-Exceptions (controller line ~102).
class PageFetchError implements Exception {
  const PageFetchError(this.message);
  final String message;
}

/// Gallery home: search + category filter + infinite grid/masonry.
///
/// Paging mechanics live in `PagingController` (v5); [GalleryBloc] owns
/// filters + fetching. The `fetchPage` bridge dispatches
/// [GalleryPageRequested] and completes from the Bloc state tagged with the
/// same page key — retries and sequential pages never cross-talk.
class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late final GalleryBloc _bloc;
  late final PagingController<int, Photo> _controller;
  bool _ready = false;
  bool _masonry = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    _ready = true;
    _bloc = context.read<GalleryBloc>();
    _controller = PagingController<int, Photo>(
      getNextPageKey: (PagingState<int, Photo> state) {
        final int loaded = state.items?.length ?? 0;
        final int total = _bloc.state.totalHits;
        // Exact stop once the server-reported total is reached…
        if (loaded > 0 && total > 0 && loaded >= total) return null;
        // …empty-page safety net for Pixabay's deep-paging cap.
        if (state.lastPageIsEmpty) return null;
        return state.nextIntPageKey;
      },
      fetchPage: _fetchPage,
    );
  }

  Future<List<Photo>> _fetchPage(int pageKey) {
    // Subscribe first, dispatch second: Bloc handles events asynchronously,
    // so the result emission can never precede this subscription.
    final Future<GalleryState> result = _bloc.stream.firstWhere(
      (GalleryState s) => s.resolvedPageKey == pageKey,
    );
    _bloc.add(GalleryPageRequested(pageKey));
    return result.then((GalleryState s) {
      if (s.status == GalleryStatus.failure) {
        throw PageFetchError(
          s.errorMessage.isEmpty ? S.errorGeneric : s.errorMessage,
        );
      }
      return s.pageItems;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(S.galleryTitle),
        actions: <Widget>[
          IconButton(
            tooltip: _masonry ? "Grid view" : "Masonry view",
            icon: Icon(_masonry ? Icons.grid_view : Icons.dashboard_outlined),
            onPressed: () => setState(() => _masonry = !_masonry),
          ),
          IconButton(
            tooltip: S.favoritesTitle,
            icon: const Icon(Icons.favorite_border),
            onPressed: () =>
                AppRoutes.push(context, const FavoritesPage()),
          ),
          const ThemeToggleButton(),
        ],
      ),
      body: FavoritesMessenger(
        child: BlocListener<GalleryBloc, GalleryState>(
          // Filter resets are the only `initial` emissions after mount;
          // result emissions are success/failure and must not refresh.
        listenWhen: (GalleryState prev, GalleryState curr) =>
            curr.status == GalleryStatus.initial &&
            (curr.query != prev.query || curr.category != prev.category),
        listener: (_, _) => _controller.refresh(),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: GallerySearchField(
                initialQuery: _bloc.state.query,
                onQueryChanged: (String value) {
                  if (value != _bloc.state.query) {
                    _bloc.add(GalleryQueryChanged(value));
                  }
                },
              ),
            ),
            CategoryFilterRow(
              selected: context.select<GalleryBloc, String>(
                (GalleryBloc b) => b.state.category,
              ),
              onSelected: (String category) {
                if (category != _bloc.state.category) {
                  _bloc.add(GalleryCategoryChanged(category));
                }
              },
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () {
                  // Guard: refreshing mid-fetch can append stale items
                  // (v5 fetch is non-atomic) — wait for idle instead.
                  if (_controller.isLoading) return Future<void>.value();
                  return Future.sync(_controller.refresh);
                },
                child: PagingListener<int, Photo>(
                  controller: _controller,
                  builder: (
                    BuildContext context,
                    PagingState<int, Photo> state,
                    NextPageCallback fetchNextPage,
                  ) =>
                      _masonry
                          ? _buildMasonry(state, fetchNextPage)
                          : _buildGrid(state, fetchNextPage),
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, Photo item) {
    AppRoutes.push(context, DetailPage(photo: item));
  }

  Widget _buildGrid(
    PagingState<int, Photo> state,
    NextPageCallback fetchNextPage,
  ) =>
      PagedGridView<int, Photo>(
        state: state,
        fetchNextPage: fetchNextPage,
        padding: const EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:
              galleryCrossAxisCount(MediaQuery.sizeOf(context).width),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        builderDelegate: PagedChildBuilderDelegate<Photo>(
          itemBuilder: (BuildContext context, Photo item, int index) =>
              _GalleryTile(
            photo: item,
            onTap: () => _openDetail(context, item),
          ),
          firstPageProgressIndicatorBuilder: (_) => const AppLoadingGrid(),
          firstPageErrorIndicatorBuilder: (_) => AppErrorView(
            message: _errorMessage(state),
            onRetry: fetchNextPage,
          ),
          newPageProgressIndicatorBuilder: (_) => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
          newPageErrorIndicatorBuilder: (_) => Center(
            child: TextButton.icon(
              onPressed: fetchNextPage,
              icon: const Icon(Icons.refresh),
              label: Text(
                _errorMessage(state),
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          noItemsFoundIndicatorBuilder: (_) => const AppEmptyView(
            message: S.emptyGallery,
            hint: S.emptyGalleryHint,
          ),
          noMoreItemsIndicatorBuilder: (_) => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text("You've reached the end")),
          ),
        ),
      );

  Widget _buildMasonry(
    PagingState<int, Photo> state,
    NextPageCallback fetchNextPage,
  ) {
    final PagingStatus status = state.status;
    if (status == PagingStatus.loadingFirstPage) {
      return const AppLoadingGrid();
    }
    final List<Photo> items = state.items ?? <Photo>[];
    if (status == PagingStatus.firstPageError) {
      return AppErrorView(
        message: _errorMessage(state),
        onRetry: fetchNextPage,
      );
    }
    if (status == PagingStatus.noItemsFound) {
      return const AppEmptyView(
        message: S.emptyGallery,
        hint: S.emptyGalleryHint,
      );
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification n) {
        if (n.depth == 0) {
          final ScrollMetrics m = n.metrics;
          if (m.pixels >= m.maxScrollExtent - 600 &&
              state.hasNextPage &&
              !state.isLoading) {
            fetchNextPage();
          }
        }
        return false;
      },
      child: CustomMasonryGrid(
        padding: const EdgeInsets.all(12),
        crossAxisCount:
            galleryCrossAxisCount(MediaQuery.sizeOf(context).width),
        items: <Widget>[
          for (final Photo item in items)
            _GalleryTile(
              photo: item,
              aspectRatio: _masonryAspect(item),
              onTap: () => _openDetail(context, item),
            ),
        ],
        footer: _masonryFooter(state, fetchNextPage),
      ),
    );
  }

  Widget _masonryFooter(
    PagingState<int, Photo> state,
    NextPageCallback fetchNextPage,
  ) {
    if (state.status == PagingStatus.subsequentPageError) {
      return Center(
        child: TextButton.icon(
          onPressed: fetchNextPage,
          icon: const Icon(Icons.refresh),
          label: Text(_errorMessage(state)),
        ),
      );
    }
    if (state.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (state.status == PagingStatus.completed) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text("You've reached the end")),
      );
    }
    return const SizedBox.shrink();
  }

  static double _masonryAspect(Photo photo) {
    final double a = photo.aspectRatio;
    if (a <= 0) return 1;
    return a.clamp(0.5, 2.0);
  }

  static String _errorMessage(PagingState<int, Photo> state) {
    final Object? error = state.error;
    if (error is PageFetchError && error.message.isNotEmpty) {
      return error.message;
    }
    return S.errorGeneric;
  }
}

/// Favorite-aware tile: subscribes to ONE photo's favorite flag, so toggles
/// rebuild only this tile — never the grid (context.select is illegal
/// directly inside sliver item builders).
class _GalleryTile extends StatelessWidget {
  const _GalleryTile({
    required this.photo,
    required this.onTap,
    this.aspectRatio,
  });

  final Photo photo;
  final VoidCallback onTap;
  final double? aspectRatio;

  @override
  Widget build(BuildContext context) {
    final bool isFavorite = context.select<FavoritesBloc, bool>(
      (FavoritesBloc b) => b.state.ids.contains(photo.id),
    );
    return PhotoTile(
      photo: photo,
      aspectRatio: aspectRatio,
      isFavorite: isFavorite,
      onFavoriteToggle: () =>
          context.read<FavoritesBloc>().add(FavoriteToggled(photo)),
      onTap: onTap,
    );
  }
}
