// Path: lib/app.dart
import "package:flutter/material.dart";
import "package:infinite_image_gallery_pixabay/core/config/app.dart";
import "package:infinite_image_gallery_pixabay/core/config/apptheme.dart";
import "package:infinite_image_gallery_pixabay/core/config/env_config.dart";
import "package:infinite_image_gallery_pixabay/core/config/space.dart";
import "package:infinite_image_gallery_pixabay/core/constants/app_strings.dart";

/// Root widget. Owns [MaterialApp] + responsive bootstrap ([App.init]).
/// Feature Blocs (Gallery/Favorites/Theme/Download) are added to the
/// [MultiBlocProvider] here in their respective phases — Phase 2 replaces
/// [_PlaceholderHome] with the real gallery page.
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
    return const _PlaceholderHome();
  }
}

/// Temporary home until Phase 2 lands the gallery page.
/// Shows env/key status so setup problems are visible immediately.
class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final bool hasKey = EnvConfig.hasApiKey;

    return Scaffold(
      appBar: AppBar(title: const Text(S.appName)),
      body: Center(
        child: Padding(
          padding: Space.all(2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                hasKey ? Icons.photo_library_outlined : Icons.key_off_outlined,
                size: 56,
              ),
              Space.yf(1),
              Text(
                hasKey ? S.galleryTitle : "API key missing",
                style: text.headlineSmall,
                textAlign: TextAlign.center,
              ),
              Space.yf(0.5),
              Text(
                hasKey
                    ? "Gallery UI lands in Phase 2."
                    : "Add PIXABAY_API_KEY to your .env file, then restart. "
                        "Get a free key at pixabay.com/api/docs/",
                style: text.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
