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

## 5. Phase 2 — Gallery PRESENTATION: grid + infinite scroll (~3–4 h)

1. `GalleryBloc` (events: `Requested(pageKey)`, `QueryChanged(q)` debounced 400 ms, `CategoryChanged(c)`, `Refreshed`; state: `status {initial,loading,success,failure}`, `photos`, `totalHits`, `hasReachedMax`, `query`, `category`, `errorMessage`). Bloc fetches page, emits appended list; **paging math**: `isLastPage = hits.isEmpty || accumulated.length >= totalHits`.
2. Page wiring: `PagingController<int, Photo>` (firstPageKey = 1) in `GalleryPage` (`features/gallery/presentation/pages/gallery_page.dart`); bloc listener → `appendPage(nextKey, items)` / `appendLastPage(items)` / `error = msg`. `PagedChildBuilderDelegate` with `firstPageProgressIndicatorBuilder → AppLoadingGrid`, `newPageProgressIndicatorBuilder → footer spinner`, `firstPageErrorIndicatorBuilder → AppErrorView(retry: controller.refresh)`, `noItemsFoundIndicatorBuilder → AppEmptyView`, `noMoreItemsIndicatorBuilder → "You've reached the end"`.
3. Grid UI: `RefreshIndicator(onRefresh: () => Future.sync(controller.refresh))` → responsive `GridView` (crossAxisCount from `UI.width`: <360→2, <720→3, else 4) OR `CustomMasonryGrid` masonry toggle (bonus, keep both behind AppBar switch). Tile widget (`photo_tile.dart`): `AppImage(webformatURL)`, bottom gradient + likes/views chips, heart button (reads `FavoritesBloc`), `Hero(tag: "photo-{id}")` wrapping image.
4. AppBar: title + `SearchBar` (bonus search, debounced) + masonry toggle + theme toggle + favorites navigation icon.
5. Category filter row (bonus): horizontal `ChoiceChip`s from `ApiConstants.categories`; selecting resets paging (`controller.refresh()` with new category).
6. Detail navigation: `AppRoutes.push(context, DetailPage(photo))` — pass entity, no refetch ( heroes animate because tags match).
7. Widget test: grid renders tiles from stubbed bloc; error view retry calls refresh. Gate: scroll loads page 2+; empty query + search + category all page correctly; rotation/tablet columns adapt.

---

## 6. Phase 3 — Detail screen: description + actions (~2 h)

1. `DetailPage(photo)`: full `Hero` image (`largeImageURL`, `InteractiveViewer` pinch-zoom), scrollable meta sheet — **description block (assignment-required)**: `tags` as chips + `user` attribution + stats row (views/likes/downloads) + resolution (`imageWidth×imageHeight`) + "View on Pixabay" (`pageURL` via `url_launcher` — add dep only here if needed).
2. Action bar: Favorite toggle (dispatches `FavoritesBloc`), Download (→ `DownloadCubit`, shows linear progress 0→1 in button), Share (`Tools.shareImageUrl`), set-as/fallback if `largeImageURL` missing.
3. `DownloadCubit` + `DownloadService` (data): `Dio.download(url, tmpPath, onReceiveProgress)` → `ImageGallerySaverPlus.saveFile` (or `saveImage` bytes path); pre-flight `PermissionHelper.ensureSavePermission()` → `PermissionFailure` snackbar if denied; emit `DownloadProgress(p)` → `DownloadSuccess`/`DownloadFailure`. Gate: real-device save appears in gallery; progress bar moves; denied permission shows `S.errorPermission`.

---

## 7. Phase 4 — Favorites + persistence (~1–2 h)

1. `FavoritesRepository` contract + impl over `SharedPreferences` key `favorite_photos_v1`: `getFavorites()`, `toggle(photo)`, `isFavorite(id)`, `clear()` — store `List<String>` of `photoModel.toJson()`; decode defensively (skip corrupt entries).
2. `FavoritesBloc` (global, provided in `app.dart` above `MaterialApp`): loads on start; events `Toggled(photo)`, `Loaded`, `Cleared`; state `{ids:Set<int>, photos:List<Photo>}`; emits snackbar messages via listener (`favoriteAdded/Removed`).
3. `FavoritesPage`: grid of saved photos (reuse `PhotoTile`), `AppEmptyView` when empty, unfavorite inline, tap → detail. Gate: favorite → kill app → relaunch → still favorited; grid heart and favorites screen never disagree.

---

## 8. Phase 5 — App shell, theme, error/loading polish (~1 h)

1. `app.dart` + `main.dart`: `dotenv.load(fileName: ".env")` → `initDependencies()` → `runApp`; `App.init(context)` on first frame via `_Bootstrap`; `MultiBlocProvider(GalleryBloc, FavoritesBloc, ThemeCubit, DownloadCubit)` added in respective phases. ✅ Bootstrap (env+DI+shell+placeholder home) done early; Bloc providers pending Phases 2–5.
2. `ThemeCubit`: `ThemeMode.system/light/dark` + persist in `SharedPreferences`; AppBar toggle cycles.
3. Global rules: every async screen has loading (`AppLoadingGrid`/skeleton) + error (`AppErrorView` + retry) + empty (`AppEmptyView`); failures surface via `Tools.showFailure`; no raw exceptions reach UI. Gate: airplane-mode gallery shows `S.errorNoInternet` + retry works after reconnect.

---

## 9. Phase 6 — Tests + docs + submission (~2 h)

1. Tests (assignment explicitly scores these): unit — photo model, repository mapping, `GalleryBloc` page-append/stop conditions (`bloc_test`), favorites round-trip; widget — gallery grid, error+retry, favorites empty; (optional) golden tile. Gate: `flutter test` all green + `flutter analyze` clean.
2. README: setup (`.env` key steps), architecture diagram + state-management paragraph, package table, assumptions/limitations (Pixabay rate limits, paging cap, Android 13+ permission note), screenshots section.
3. Submission: git repo link, APK (`flutter build apk --release`), 2–4 screenshots/screen recording, limitations list. `.env` stays uncommitted (`.gitignore` entry verified).

---

## 10. Build order & gates (checklist for the agent)

- [ ] Phase 0 verify: `pub get` + `analyze` clean (foundation already written)
- [x] Phase 1: data+domain + get_it DI + unit tests green (32 tests)
- [ ] Phase 2: gallery paging/search/filter/masonry/hero + widget tests
- [ ] Phase 3: detail + download progress + share
- [ ] Phase 4: favorites persistence + sync
- [ ] Phase 5: shell + theme + global error polish
- [ ] Phase 6: full tests + README + APK + screenshots

> Suggested commit per phase (`feat(gallery): …`, `feat(detail): …`, `feat(favorites): …`, `test: …`, `docs: …`).
