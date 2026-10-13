// Path: features/favorites/presentation/widgets/favorites_listener.dart
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:infinite_image_gallery_pixabay/core/utils/tools.dart";
import "package:infinite_image_gallery_pixabay/features/favorites/presentation/bloc/favorites_bloc.dart";
import "package:infinite_image_gallery_pixabay/features/favorites/presentation/bloc/favorites_event.dart";
import "package:infinite_image_gallery_pixabay/features/favorites/presentation/bloc/favorites_state.dart";

/// Shows [FavoritesState.message] once as a snackbar, then consumes it.
/// Wrap any screen that triggers favorite changes (gallery, detail,
/// favorites) — one place for the feedback, no per-screen listeners (DRY).
class FavoritesMessenger extends StatelessWidget {
  const FavoritesMessenger({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<FavoritesBloc, FavoritesState>(
      listenWhen: (FavoritesState prev, FavoritesState curr) =>
          curr.message.isNotEmpty && curr.message != prev.message,
      listener: (BuildContext context, FavoritesState state) {
        Tools.showSuccess(context, state.message);
        context.read<FavoritesBloc>().add(const FavoritesMessageConsumed());
      },
      child: child,
    );
  }
}
