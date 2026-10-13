// Path: features/detail/presentation/pages/detail_page.dart
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:infinite_image_gallery_pixabay/core/constants/app_strings.dart";
import "package:infinite_image_gallery_pixabay/core/utils/format_utils.dart";
import "package:infinite_image_gallery_pixabay/core/utils/tools.dart";
import "package:infinite_image_gallery_pixabay/core/widgets/appimage.dart";
import "package:infinite_image_gallery_pixabay/features/detail/presentation/cubit/download_cubit.dart";
import "package:infinite_image_gallery_pixabay/features/detail/presentation/cubit/download_state.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/entities/photo.dart";
import "package:infinite_image_gallery_pixabay/injection_container.dart";
import "package:url_launcher/url_launcher.dart";

/// Image detail: Hero image (pinch-zoom) + description block + actions.
///
/// Receives the [Photo] entity — no refetch. Favorite stays a seam
/// ([onFavoriteToggle]/[isFavorite]) until Phase 4 wires `FavoritesBloc`,
/// mirroring [PhotoTile].
class DetailPage extends StatelessWidget {
  const DetailPage({
    required this.photo,
    super.key,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  final Photo photo;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DownloadCubit>(
      create: (_) => sl<DownloadCubit>(),
      child: _DetailView(
        photo: photo,
        isFavorite: isFavorite,
        onFavoriteToggle: onFavoriteToggle,
      ),
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView({
    required this.photo,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  final Photo photo;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  String get _heroTag => "photo-${photo.id}";

  Future<void> _onShare(BuildContext context) async {
    try {
      final String caption = photo.tagList.isEmpty
          ? "Photo by ${photo.user} via ${S.appName}"
          : "${photo.tagList.take(5).join(', ')} — by ${photo.user}";
      await Tools.shareImageUrl(photo.detailImageUrl, caption: caption);
    } catch (_) {
      if (context.mounted) Tools.showError(context, S.errorGeneric);
    }
  }

  Future<void> _onOpenPixabay(BuildContext context) async {
    try {
      final Uri uri = Uri.parse(photo.pageURL);
      final bool opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!opened && context.mounted) {
        Tools.showError(context, S.errorGeneric);
      }
    } catch (_) {
      if (context.mounted) Tools.showError(context, S.errorGeneric);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(S.detailTitle),
        actions: <Widget>[
          IconButton(
            tooltip: S.share,
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _onShare(context),
          ),
          if (onFavoriteToggle != null)
            IconButton(
              tooltip: isFavorite
                  ? "Remove from favorites"
                  : "Add to favorites",
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
              ),
              onPressed: onFavoriteToggle,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              color: Colors.black,
              child: Hero(
                tag: _heroTag,
                child: InteractiveViewer(
                  child: AppImage(
                    imageUrl: photo.detailImageUrl,
                    fit: BoxFit.contain,
                    height: MediaQuery.sizeOf(context).height * 0.45,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Description block (assignment requirement): tags +
                  // attribution + stats + resolution + source link.
                  if (photo.tagList.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        for (final String tag in photo.tagList)
                          Chip(label: Text(tag)),
                      ],
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      const Icon(Icons.person_outline, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        "${S.byAuthor} ${photo.user.isEmpty ? "unknown" : photo.user}",
                        style: text.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      _Stat(
                        icon: Icons.visibility_outlined,
                        value: compactCount(photo.views),
                        label: S.views,
                      ),
                      const SizedBox(width: 20),
                      _Stat(
                        icon: Icons.favorite_border,
                        value: compactCount(photo.likes),
                        label: S.likes,
                      ),
                      const SizedBox(width: 20),
                      _Stat(
                        icon: Icons.download_outlined,
                        value: compactCount(photo.downloads),
                        label: S.downloads,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "${photo.imageWidth} × ${photo.imageHeight}",
                    style: text.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed:
                        photo.pageURL.isEmpty ? null : () => _onOpenPixabay(context),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text("View on Pixabay"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: BlocConsumer<DownloadCubit, DownloadState>(
            listener: (BuildContext context, DownloadState state) {
              if (state.status == DownloadStatus.success) {
                Tools.showSuccess(context, S.downloadSuccess);
              } else if (state.status == DownloadStatus.failure) {
                Tools.showError(context, state.errorMessage);
              }
            },
            builder: (BuildContext context, DownloadState state) {
              if (state.status == DownloadStatus.inProgress) {
                final int pct = (state.progress * 100).round();
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    LinearProgressIndicator(value: state.progress),
                    const SizedBox(height: 8),
                    Text("${S.downloading} $pct%"),
                  ],
                );
              }
              return FilledButton.icon(
                onPressed: () =>
                    context.read<DownloadCubit>().download(photo),
                icon: const Icon(Icons.download_outlined),
                label: const Text(S.download),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        Text(value, style: text.bodyMedium),
        const SizedBox(width: 4),
        Text(label, style: text.bodySmall),
      ],
    );
  }
}
