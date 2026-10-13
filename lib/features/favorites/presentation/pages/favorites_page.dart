// Path: features/favorites/presentation/pages/favorites_page.dart
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:infinite_image_gallery_pixabay/core/config/app_utils.dart";
import "package:infinite_image_gallery_pixabay/core/constants/app_strings.dart";
import "package:infinite_image_gallery_pixabay/core/routes/app_routes.dart";
import "package:infinite_image_gallery_pixabay/core/widgets/app_empty_view.dart";
import "package:infinite_image_gallery_pixabay/core/widgets/app_error_view.dart";
import "package:infinite_image_gallery_pixabay/core/widgets/app_loading.dart";
import "package:infinite_image_gallery_pixabay/features/detail/presentation/pages/detail_page.dart";
import "package:infinite_image_gallery_pixabay/features/favorites/presentation/bloc/favorites_bloc.dart";
import "package:infinite_image_gallery_pixabay/features/favorites/presentation/bloc/favorites_event.dart";
import "package:infinite_image_gallery_pixabay/features/favorites/presentation/bloc/favorites_state.dart";
import "package:infinite_image_gallery_pixabay/features/favorites/presentation/widgets/favorites_listener.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/entities/photo.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/presentation/gallery_columns.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/presentation/widgets/photo_tile.dart";

/// Saved-photos screen. Reads the global [FavoritesBloc] (provided above
/// `MaterialApp`) — no local state, no refetch. Tiles reuse [PhotoTile];
/// tap opens the same [DetailPage] as the gallery.
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  Future<void> _onClear(BuildContext context) async {
    final bool confirmed = await AppUtils.showConfirmDialog(
      context,
      title: "Clear favorites?",
      message: "Remove all saved photos? This cannot be undone.",
      confirmLabel: "Clear",
    );
    if (confirmed && context.mounted) {
      context.read<FavoritesBloc>().add(const FavoritesCleared());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasItems = context.select<FavoritesBloc, bool>(
      (FavoritesBloc b) => b.state.photos.isNotEmpty,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(S.favoritesTitle),
        actions: <Widget>[
          if (hasItems)
            IconButton(
              tooltip: "Clear all",
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () => _onClear(context),
            ),
        ],
      ),
      body: FavoritesMessenger(
        child: BlocBuilder<FavoritesBloc, FavoritesState>(
          builder: (BuildContext context, FavoritesState state) {
            switch (state.status) {
              case FavoritesStatus.loading:
              case FavoritesStatus.initial:
                return const AppLoadingGrid(itemCount: 6);
              case FavoritesStatus.failure:
                return AppErrorView(
                  message: state.message.isEmpty
                      ? S.errorGeneric
                      : state.message,
                  onRetry: () => context
                      .read<FavoritesBloc>()
                      .add(const FavoritesStarted()),
                );
              case FavoritesStatus.loaded:
                if (state.photos.isEmpty) {
                  return const AppEmptyView(
                    message: S.emptyFavorites,
                    hint: S.emptyFavoritesHint,
                    icon: Icons.favorite_border,
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: galleryCrossAxisCount(
                      MediaQuery.sizeOf(context).width,
                    ),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: state.photos.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Photo photo = state.photos[index];
                    return PhotoTile(
                      photo: photo,
                      isFavorite: true,
                      onFavoriteToggle: () => context
                          .read<FavoritesBloc>()
                          .add(FavoriteToggled(photo)),
                      onTap: () => AppRoutes.push(
                        context,
                        DetailPage(photo: photo),
                      ),
                    );
                  },
                );
            }
          },
        ),
      ),
    );
  }
}
