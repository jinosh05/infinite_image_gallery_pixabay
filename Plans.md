# Plans.md — Infinite Image Gallery (Pixabay) | Clean Architecture + flutter_bloc

> Status: **Phase 0 (foundation) DONE** — `lib/core` migrated, `pubspec.yaml` + `.env.example` created.
> Next: implement Phases 1–9 in order. Each phase ends with a verify gate — do not skip it.

---

## 0. Context & decisions (read once)

### 0.1 Assignment recap
Production-style Flutter gallery on a public image API (**Pixabay recommended**):
Gallery Home (responsive grid) · infinite scroll/pagination · loading states · error handling ·
detail screen **with description** · download · favorites + favorites screen · image performance.
Tech: maintainable architecture, separation of concerns, SOLID.
Bonus: search, pull-to-refresh, category filters, masonry, Hero, themes, share, download progress, unit + widget tests.

### 0.2 API choice: Pixabay (recommended option)
- Docs: `https://pixabay.com/api/docs/`. Free Basic plan is enough.
- Endpoint: `GET https://pixabay.com/api/?key={KEY}&q={query}&image_type=photo&page={n}&per_page={k}&category={c}&safesearch=true&order=popular`
- Response: `{ total, totalHits, hits: [{ id, pageURL, type, tags, previewURL, previewWidth/Height, webformatURL, webformatWidth/Height, largeImageURL, imageWidth/Height, views, downloads, likes, user, userImageURL }] }`
- Grid thumbnail → `webformatURL`; detail/download/share → `largeImageURL` (fallback `webformatURL`).
- Pagination: `page` (1-based) + `per_page` (default 20, max 200). Stop when `hits.isEmpty` OR `loaded >= totalHits`. Pixabay caps deep paging — treat empty page as end-of-list regardless of `totalHits`.
- Key passed as **query param `key`** (not a header).

### 0.3 Package → requirement map (all from `packages and widgets.md`)
| Package / widget | Used for | Notes |
|---|---|---|
| `flutter_bloc` + `equatable` | All state management (gallery, detail, favorites, theme, download) | No Riverpod/GetX mixed in |
| `dio` (`core/network/dio_client.dart`) | Single shared HTTP client | Interceptors + timeouts here; features only call `dio.get` |
| `flutter_dotenv` | `.env` → `PIXABAY_API_KEY` via `core/config/env_config.dart` | `.env` is gitignored; user creates it (see §2) |
| `flutter_secure_storage` | Optional API-key mirror | Stored once at startup; remote source still reads `.env` first |
| `shared_preferences` | Favorites persistence (JSON list of photo objects) | Survives restart; holds full object so favorites work offline |
| `cached_network_image` (+ `AppImage`) | Grid + detail images, memory/disk cache | `memCacheWidth` set from layout width; shimmer placeholder |
| `infinite_scroll_pagination` (`PagingController`) | Infinite scroll engine | Page-keyed; `appendPage` / `appendLastPage`; first-page shimmer, footer loader |
| `custom_masonry_grid` | Masonry layout option (bonus) | Toggle Grid ↔ Masonry in AppBar; keep scroll position per mode |
| `RefreshIndicator` (Flutter) | Pull-to-refresh (bonus) | Calls `pagingController.refresh()` |
| `Hero` (Flutter) | Grid → detail transition (bonus) | Tag: `photo-{id}`; both sides same tag |
| `shimmer` | First-load skeleton (`AppLoadingGrid`) | Pagination footer uses plain spinner, not shimmer |
| `google_fonts` (via `FontUtils`/`AppText`) | Typography | `getSafeGoogleFont` fallback so offline still renders |
| `image_gallery_saver_plus` | Save to gallery | Bytes fetched with Dio `ResponseType.bytes` → `saveImage` |
| `permission_handler` (+ `device_info_plus`, via `PermissionHelper`) | Save permission matrix | Android ≤12 `storage`; 13+ `photos`; iOS `photosAddOnly` → `photos` |
| `share_plus` (via `Tools.shareImageUrl`) | Share image URL/caption | File-share after download is detail-feature code, not core |
| `path_provider` | Temp file for `saveFile`/share flows | |
| `dartz` | `Either<Failure, T>` in repositories/use cases | Failures in `core/error/failures.dart` |
| `get_it` (`lib/injection_container.dart`) | Service locator / composition root | `initDependencies()` in `main()`; Blocs resolve use cases via `sl<T>()` |
| `mocktail` + `bloc_test` (dev) | Unit + bloc + widget tests | |

### 0.4 Architecture — Clean + BLoC, SOLID enforced
```
lib/
  main.dart                 → dotenv.load, DI init, App bootstrap
  app.dart                  → MaterialApp + App.init + MultiBlocProvider + routes
  injection_container.dart  → manual DI (get_it optional; default: plain factories)
  core/                     → ✅ MIGRATED (see §1)
  features/
    gallery/  { data/{datasources,models,repositories}, domain/{entities,repositories,use_cases}, presentation/{bloc,pages,widgets} }
    detail/   { ... }   // detail bloc OR reuse gallery entity + small DownloadCubit
    favorites/{ ... }   // favorites bloc + local data source
    search/   (fold into gallery bloc — NOT a separate feature)
    theme/    (ThemeCubit in core or features/theme — 1 small cubit)
```
- **Layers:** presentation (Bloc/Widgets) → domain (Entities + UseCases + Repository contracts) → data (Models + DataSources + Repository impls). Dependencies point inward only.
- **SOLID mapping:** S — one class one job (`DioClient` builds HTTP only; `PermissionHelper` permissions only; `Tools` feedback only); O — new filters/sorts extend, never edit paging core; L — `Failure` subtypes substitutable in `showFailure`; I — small contracts (`GalleryRepository`, `FavoritesRepository`, `DownloadService`); D — blocs depend on use-case/repository abstractions, constructed in `injection_container.dart`.
- **State:** one Bloc/Cubit per screen concern: `GalleryBloc` (paging+search+filter state; drives `PagingController`), `FavoritesBloc` (global, provided at app root so grid hearts + favorites screen stay in sync), `DownloadCubit` (progress 0→1, success/fail), `ThemeCubit` (light/dark/system + persistence).

---

## 1. Core reuse — what was migrated (DONE, verify in §3)

| File | Kept | Changed | Removed |
|---|---|---|---|
| `config/ui.dart`, `app_dimensions.dart`, `space.dart`, `space_ext.dart` | ✅ all logic | import `jigsaw` → `infinite_image_gallery_pixabay` | — |
| `config/app_typography.dart`, `apptheme.dart` | ✅ styles/theme | colors import → new `core/constants/app_colors.dart` | — |
| `config/app.dart` | ✅ `UI/AppDimensions/Space/AppText/isLtr` init | same | ❌ ad logic (`showAds`, `SharedPreferences` restore) — not needed |
| `app_lifecycle.dart` | ✅ observer bridging to `ValueNotifier` | ❌ Riverpod provider → constructor-injected `notifier` (Bloc-compatible) | `flutter_riverpod`, `logging`-only kept |
| `utils/tools.dart` | ✅ snackbar family + share | share slimmed to URL/caption text | ❌ game code (`shareLevel`, `LevelInfo`, analytics, version check, image_picker, vibration) |
| `widgets/appimage.dart` | ✅ cached image + shimmer + asset fallback | simplified props, `fadeIn/Out`, `memCacheWidth` | ❌ Lottie/SVG branches, `NeverRefreshCacheManager`, hard `Assets.logo` dep |
| `routes/app_routes.dart`, `utils/{network_check,font_utils,regex_pattern}.dart` | ✅ as-is | — | — |
| **NEW** `constants/{app_colors,app_strings,api_constants,app_assets}.dart` | — | missing jigsaw constants recreated locally | — |
| **NEW** `error/{failures,exceptions}.dart` | — | `Failure` hierarchy + data exceptions | — |
| **NEW** `network/dio_client.dart` | — | singleton Dio (timeouts + log interceptor) | — |
| **NEW** `config/env_config.dart` | — | typed `.env` reader (`hasApiKey` gate) | — |
| **NEW** `utils/permission_helper.dart` | — | Android SDK + iOS save-permission matrix | — |
| **NEW** `widgets/{app_error_view,app_loading,app_empty_view}.dart` | — | shared loading/error/empty (DRY) | — |
| **NEW** `.env.example`, `pubspec.yaml` (all requested packages) | — | — | — |

> If `flutter analyze` flags anything in `core/`, fix it before starting Phase 1 — features build on these files.

---

## 2. User action required (you, not the agent)

1. Create `.env` next to `.env.example` (never commit it):
   ```
   PIXABAY_API_KEY=PASTE_YOUR_KEY_HERE
   ```
2. Key source: `https://pixabay.com/api/docs/` → sign up → copy key → ~30 chars.
3. Android save-permission manifest (`android/app/src/main/AndroidManifest.xml`):
   - Add `READ_MEDIA_IMAGES` (SDK 33+) + legacy `READ/WRITE_EXTERNAL_STORAGE` (maxSdk 32) + `android:requestLegacyExternalStorage="true"` on the `<application>` tag for SDK 29 compat (per `image_gallery_saver_plus` README).
4. iOS (`ios/Runner/Info.plist`): add `NSPhotoLibraryAddUsageDescription` (+ `NSPhotoLibraryUsageDescription` if reading library).
5. Confirm to the agent when `.env` exists — Phase 1 gates on `EnvConfig.hasApiKey`.

---

## 3. Phase 0 — verify foundation (agent, ~15 min) ✅ DONE, still verify

- [x] `pubspec.yaml` has all §0.3 packages; `flutter` assets include `.env`
- [x] `.env.example` created
- [x] `lib/core` migrated per §1 table
- [ ] Run: `flutter pub get` → `flutter analyze` → **0 errors** (warnings in `core/` must be fixed now)
- [ ] Run: `flutter test` (passes trivially — no tests yet)
- Gate: `analyze` clean before Phase 1.

---

## 4. Phase 1 — Gallery DATA + DOMAIN layers (~2–3 h)

1. `features/gallery/data/models/photo_model.dart` — `fromJson` for all §0.2 hit fields; `toJson` (needed for favorites persistence); `toEntity()`. Null-safe: `largeImageURL` may be missing → fallback chain `largeImageURL → webformatURL → previewURL`.
2. `features/gallery/data/datasources/gallery_remote_data_source.dart` (+ impl) — `fetchPhotos({query, category, page, perPage, order})` via `DioClient.instance.get("", queryParameters: {key, q, image_type, page, per_page, category?, safesearch, order})`. Map: 401/403 → `UnauthorizedException`; `DioException.connectionError/timeout` → `NetworkException`; other non-200 → `ServerException`.
3. `features/gallery/domain/entities/photo.dart` (Equatable, all display fields) + `domain/repositories/gallery_repository.dart` contract: `Future<Either<Failure, PhotoPage>> getPhotos(GalleryParams)` where `PhotoPage { photos, totalHits, page, perPage }`.
4. `features/gallery/data/repositories/gallery_repository_impl.dart` — try remote; catch exceptions → `Left(Failure)` mapping (`UnauthorizedException→UnauthorizedFailure`, `Network→NetworkFailure`, else `ServerFailure`). Pre-check `NetworkCheck().check()` → early `Left(NetworkFailure)` (offline-first UX).
5. `domain/use_cases/get_photos.dart` — thin `call(GalleryParams)` passthrough (keeps Bloc → abstraction, DIP).
6. `lib/injection_container.dart` (get_it) — `sl` registers `Dio`, `NetworkCheck`, `SharedPreferences` (async singleton), `GalleryRemoteDataSource`, `GalleryRepository`, `GetPhotos` as lazy singletons. Called once in `main()` (wired in Phase 5); verified by `test/injection_container_test.dart`.
7. Unit tests: model JSON (full + missing-field), page-model parsing, `PhotoPage.isLastPage/nextPageKey`, data-source param building + exception mapping (mocked Dio), repository exception→failure mapping (mocked data source), use-case passthrough, DI graph resolution. Gate: `flutter test` green (32 tests). ✅ DONE

---

## 5. Phase 2 — Gallery PRESENTATION: grid + infinite scroll ✅ DONE

> v5 API note: `infinite_scroll_pagination@5` is controller-driven
> (`PagingController(getNextPageKey:, fetchPage:)` + `PagingListener` +
> `PagedGridView`), not the v4 `appendPage` style. Empty page ⇒
> `lastPageIsEmpty` ⇒ key `null` ⇒ stop — exactly the Pixabay contract.

1. `GalleryBloc` (+ event/state) — owns filters + fetching via `GetPhotos`;
   paging mechanics stay in the controller. States tag results with
   `resolvedPageKey` so the `fetchPage` bridge (subscribe-first, then
   dispatch `GalleryPageRequested`) never cross-talks retries/pages.
2. `getNextPageKey`: exact stop at `loaded >= totalHits`, empty-page safety
   net for the deep-paging cap. Failures cross the bridge as
   `PageFetchError` (v5 rethrows non-Exceptions).
3. `GalleryPage`: `PagingListener` → `PagedGridView` (responsive columns via
   pure `galleryCrossAxisCount`) OR `CustomMasonryGrid` (manual proximity
   fetch + footer) behind the AppBar toggle; `RefreshIndicator`
   (skipped while loading — v5 fetch is non-atomic); `firstPage → AppLoadingGrid`
   (flex boxes, NOT a GridView — v5 slots indicators into SliverFillRemaining);
   error → `AppErrorView` + retry; empty → `AppEmptyView`.
4. `PhotoTile` (Hero `photo-{id}`, stats overlay, favorite button only when
   Phase 4 passes a handler), `GallerySearchField` (400 ms debounce),
   `CategoryFilterRow`, interim `PhotoPreviewDialog` (Phase 3 replaces the
   call site with DetailPage; `onTap` seam unchanged).
5. Tests: `bloc_test` (paging/filter/reset/dedupe) + 10 widget tests
   (render, scroll-pagination, error+retry, empty, search, category,
   masonry, preview, favorite seam) + app composition test. Widget tests use
   fixed pumps (sandbox blackholes image HTTP ⇒ shimmer never settles) and
   call `App.init` (mirrors the bootstrap contract).
   Gate: `flutter test` green (51 tests), `flutter analyze` clean. ✅ DONE

---

## 6. Phase 3 — Detail screen: description + actions ✅ DONE

1. `DetailPage(photo)` (entity passed, no refetch): black Hero viewer
   (`largeImageURL` → fallback chain, `InteractiveViewer` pinch-zoom),
   scrollable meta sheet — **description block**: tag chips + `user`
   attribution + views/likes/downloads stats + resolution + "View on
   Pixabay" (`pageURL` via `url_launcher`, try/catch → snackbar).
2. Action bar: favorite toggle seam (Phase 4 wires `FavoritesBloc`),
   Download → `DownloadCubit` (linear progress 0→1 in the bottom bar,
   success/fail snackbars), Share (`Tools.shareImageUrl` + caption,
   try/catch → snackbar). Gallery tile tap now pushes `DetailPage`
   (interim preview dialog deleted).
3. `ImageDownloadService` (data) + `DownloadCubit`: permission pre-flight
   (`PermissionHelper` → `PermissionException`), `Dio.download` with
   `onReceiveProgress` to tmp (`path_provider`) → `saveFile`
   (accepts map/`true`/path results); concurrent taps ignored.
   Platform entries added: Android `READ_MEDIA_IMAGES` + legacy storage
   (maxSdk 32) + `requestLegacyExternalStorage`; iOS photo-library keys.
   Gate: real-device save + moving progress bar; denied permission shows
   `S.errorPermission`. (Device verification pending — unit/widget green.)
4. Tests: cubit (progress/success/permission/download/generic/concurrency)
   + 7 detail widget tests + retargeted gallery tap test + DI graph test.
   Gate: `flutter test` green (64 tests), `flutter analyze` clean. ✅ DONE
   Test-forced fixes: `AppImage.memCacheWidth` guards non-finite widths;
   `Tools.showSnackBar` no longer assumes bootstrap ran (fallback metrics);
   plugin calls (share/url) are presence/crash-freedom-tested only —
   untestable without platform plugins.

---

## 7. Phase 4 — Favorites + persistence ✅ DONE

1. `FavoritesRepository` contract + impl over `SharedPreferences`
   (`favorite_photos_v1` JSON list): `getFavorites`, `toggleFavorite`
   (record `ToggleResult = ({photos, isFavorite})`), `clearFavorites`;
   corrupt entries skipped, models detach via `toEntity`/`fromEntity`.
2. `FavoritesBloc` (global singleton ABOVE `MaterialApp`, `Started` at
   launch): `Toggled`/`Cleared` announce via one-shot `message`
   (`favoriteAdded/Removed/Cleared`), consumed by `FavoritesMessenger`
   (single snackbar site, no per-screen listeners).
3. `FavoritesPage`: saved grid (shared `galleryCrossAxisCount` + `PhotoTile`),
   `AppEmptyView` when empty, inline unfavorite, tap → `DetailPage`,
   clear-all with confirm dialog; failure → `AppErrorView` + retry.
4. Seams lit up: gallery hearts (`_GalleryTile` subscribes per-photo so only
   the tile rebuilds), detail star (self-wired), AppBar favorites icon.
   Gate: kill → relaunch → still favorited (SharedPreferences); grid heart
   and favorites screen share one bloc. ✅ DONE (device restart round-trip
   to verify on hardware)
5. Tests: data source (round-trip/corrupt/persist) + repository
   (add/remove/clear/failure) + bloc (load/toggle/clear/consume) + page
   (empty/grid/unfavorite/clear-confirm/failure/tap) + gallery heart +
   detail star + DI singletons. `flutter test` green (87), analyze clean.
   Test-forced fixes: `context.select` extracted out of sliver builders
   (`_GalleryTile`); providers moved above `MaterialApp` in tests too;
   `AppEmptyView`/`AppErrorView` bootstrap-null-safe.
- Post-Phase-2 fixes (user feedback on-device): masonry is now the DEFAULT
  view; category chips use explicit per-state scheme colors (inherited M3
  label style was near-invisible on light fills); masonry owns its scroll
  controller + auto-fetches short result sets (CustomMasonryGrid never
  self-fetches, which previously stranded non-overflowing lists).

---

## 8. Phase 5 — App shell, theme, error/loading polish ✅ DONE

1. `app.dart` + `main.dart`: `dotenv.load` → `initDependencies()` → `runApp`
   (done earlier); `App.init` on first frame. Providers: [FavoritesBloc] +
   [ThemeCubit] ABOVE `MaterialApp` (global singletons, all routes share),
   [GalleryBloc] per-page, [DownloadCubit] per-detail. `themeMode` rebuilds
   via `BlocBuilder<ThemeCubit, ThemeMode>`.
2. `ThemeCubit` (state IS the `ThemeMode`): system/light/dark persisted to
   `SharedPreferences` (`theme_mode_v1`, unknown → system); `cycleTheme`
   system → light → dark → system. One shared `ThemeToggleButton`
   (mode-reflecting icon) in all three AppBars.
3. Global rules hold: every async screen has loading (`AppLoadingGrid`) +
   error (`AppErrorView` + retry) + empty (`AppEmptyView`); failures surface
   via `Tools` snackbars; repositories map all exceptions (nothing raw
   reaches UI); missing key shows the unauthorized error view with retry.
   Gate: airplane-mode gallery shows `S.errorNoInternet`... — note: live
   `NetworkCheck` does DNS lookup, so the offline copy appears only with
   genuinely no route; the failure-mapping path is unit-covered. ✅ DONE
4. Tests: cubit (load/persist/cycle/dedupe/unknown) + toggle widget test +
   providers in all page pumps + DI singleton. `flutter test` green (95),
   analyze clean. Test-forced: `blocTest.build` must be sync (seeded cases
   use direct construction); pushed routes need providers above
   `MaterialApp` in tests too.

---

## 9. Phase 6 — Tests + docs + submission (~2 h)

1. Tests (assignment explicitly scores these): unit — photo model, repository mapping, `GalleryBloc` page-append/stop conditions (`bloc_test`), favorites round-trip; widget — gallery grid, error+retry, favorites empty; (optional) golden tile. Gate: `flutter test` all green + `flutter analyze` clean.
2. README: setup (`.env` key steps), architecture diagram + state-management paragraph, package table, assumptions/limitations (Pixabay rate limits, paging cap, Android 13+ permission note), screenshots section.
3. Submission: git repo link, APK (`flutter build apk --release`), 2–4 screenshots/screen recording, limitations list. `.env` stays uncommitted (`.gitignore` entry verified).

---

## 10. Build order & gates (checklist for the agent)

- [ ] Phase 0 verify: `pub get` + `analyze` clean (foundation already written)
- [x] Phase 1: data+domain + get_it DI + unit tests green (32 tests)
- [x] Phase 2: gallery paging/search/filter/masonry/hero + widget tests (51 tests)
- [x] Phase 3: detail + download progress + share (64 tests)
- [x] Phase 4: favorites persistence + sync (87 tests)
- [x] Phase 5: shell + theme + global error polish (95 tests)
- [ ] Phase 6: full tests + README + APK + screenshots

> Suggested commit per phase (`feat(gallery): …`, `feat(detail): …`, `feat(favorites): …`, `test: …`, `docs: …`).
