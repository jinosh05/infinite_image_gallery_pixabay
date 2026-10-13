// Path: lib/app.dart
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:infinite_image_gallery_pixabay/core/config/app.dart";
import "package:infinite_image_gallery_pixabay/core/config/apptheme.dart";
import "package:infinite_image_gallery_pixabay/core/constants/app_strings.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/presentation/bloc/gallery_bloc.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/presentation/pages/gallery_page.dart";
import "package:infinite_image_gallery_pixabay/injection_container.dart";

/// Root widget. Owns [MaterialApp] + responsive bootstrap ([App.init]).
/// Feature Blocs are provided here (DIP: pages read them via context).
/// Phase 2: [GalleryBloc]. Favorites/Theme/Download providers land in
/// Phases 3–5 alongside their features.
class GalleryApp extends StatefulWidget {
  const GalleryApp({super.key});

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  /// Rebuilt once [_Bootstrap] finishes [App.init] so the theme picks up
  /// the initialized [AppText] styles instead of fallback defaults.
  void _onCoreReady() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: S.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: _Bootstrap(onReady: _onCoreReady),
    );
  }
}

/// Runs [App.init] on first frame (needs [MediaQuery], so it must sit
/// *below* [MaterialApp]), then swaps the splash for the real home.
class _Bootstrap extends StatefulWidget {
  const _Bootstrap({required this.onReady});

  final VoidCallback onReady;

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  bool _ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_ready) {
      App.init(context);
      _ready = true;
      // onReady rebuilds GalleryApp (theme refresh) — must run outside the
      // build phase that didChangeDependencies belongs to.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onReady();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return BlocProvider<GalleryBloc>(
      create: (_) => sl<GalleryBloc>(),
      child: const GalleryPage(),
    );
  }
}
