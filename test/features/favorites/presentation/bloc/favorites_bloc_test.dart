// Path: test/features/favorites/presentation/bloc/favorites_bloc_test.dart
import "package:bloc_test/bloc_test.dart";
import "package:dartz/dartz.dart";
import "package:flutter_test/flutter_test.dart";
import "package:infinite_image_gallery_pixabay/core/constants/app_strings.dart";
import "package:infinite_image_gallery_pixabay/core/error/failures.dart";
import "package:infinite_image_gallery_pixabay/features/favorites/domain/repositories/favorites_repository.dart";
import "package:infinite_image_gallery_pixabay/features/favorites/presentation/bloc/favorites_bloc.dart";
import "package:infinite_image_gallery_pixabay/features/favorites/presentation/bloc/favorites_event.dart";
import "package:infinite_image_gallery_pixabay/features/favorites/presentation/bloc/favorites_state.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/data/models/photo_model.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/entities/photo.dart";
import "package:mocktail/mocktail.dart";

import "../../../gallery/gallery_fixtures.dart";
import "../../../gallery/test_doubles.dart";

void main() {
  late MockFavoritesRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(
      PhotoModel.fromJson(sampleHitJson()).toEntity(),
    );
  });

  setUp(() {
    mockRepository = MockFavoritesRepository();
  });

  FavoritesBloc buildBloc() => FavoritesBloc(repository: mockRepository);

  Photo samplePhoto({int id = 1}) =>
      PhotoModel.fromJson(sampleHitJson(id: id)).toEntity();

  group("FavoritesStarted", () {
    blocTest<FavoritesBloc, FavoritesState>(
      "loads persisted favorites",
      build: () {
        when(() => mockRepository.getFavorites()).thenAnswer(
          (_) async => Right<Failure, List<Photo>>(
            <Photo>[samplePhoto(id: 1)],
          ),
        );
        return buildBloc();
      },
      act: (FavoritesBloc bloc) => bloc.add(const FavoritesStarted()),
      expect: () => <FavoritesState>[
        const FavoritesState(status: FavoritesStatus.loading),
        FavoritesState(
          status: FavoritesStatus.loaded,
          photos: <Photo>[samplePhoto(id: 1)],
        ),
      ],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      "surfaces load failure",
      build: () {
        when(() => mockRepository.getFavorites()).thenAnswer(
          (_) async => const Left<Failure, List<Photo>>(
            CacheFailure("disk gone"),
          ),
        );
        return buildBloc();
      },
      act: (FavoritesBloc bloc) => bloc.add(const FavoritesStarted()),
      expect: () => const <FavoritesState>[
        FavoritesState(status: FavoritesStatus.loading),
        FavoritesState(
          status: FavoritesStatus.failure,
          message: "disk gone",
        ),
      ],
    );
  });

  group("FavoriteToggled", () {
    blocTest<FavoritesBloc, FavoritesState>(
      "announces additions",
      build: () {
        when(() => mockRepository.toggleFavorite(any())).thenAnswer(
          (_) async => Right<Failure, ToggleResult>((
            photos: <Photo>[samplePhoto(id: 1)],
            isFavorite: true,
          )),
        );
        return buildBloc();
      },
      act: (FavoritesBloc bloc) =>
          bloc.add(FavoriteToggled(samplePhoto(id: 1))),
      expect: () => <FavoritesState>[
        FavoritesState(
          status: FavoritesStatus.loaded,
          photos: <Photo>[samplePhoto(id: 1)],
          message: S.favoriteAdded,
        ),
      ],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      "announces removals",
      build: () {
        when(() => mockRepository.toggleFavorite(any())).thenAnswer(
          (_) async => const Right<Failure, ToggleResult>((
            photos: <Photo>[],
            isFavorite: false,
          )),
        );
        return buildBloc();
      },
      act: (FavoritesBloc bloc) =>
          bloc.add(FavoriteToggled(samplePhoto(id: 1))),
      expect: () => const <FavoritesState>[
        FavoritesState(
          status: FavoritesStatus.loaded,
          photos: <Photo>[],
          message: S.favoriteRemoved,
        ),
      ],
    );
  });

  group("FavoritesCleared + consume", () {
    blocTest<FavoritesBloc, FavoritesState>(
      "clears then consumes the message",
      build: () {
        when(() => mockRepository.clearFavorites()).thenAnswer(
          (_) async => const Right<Failure, List<Photo>>(<Photo>[]),
        );
        return buildBloc();
      },
      act: (FavoritesBloc bloc) {
        bloc
          ..add(const FavoritesCleared())
          ..add(const FavoritesMessageConsumed());
      },
      expect: () => const <FavoritesState>[
        FavoritesState(
          status: FavoritesStatus.loaded,
          photos: <Photo>[],
          message: S.favoritesCleared,
        ),
        FavoritesState(
          status: FavoritesStatus.loaded,
          photos: <Photo>[],
          message: "",
        ),
      ],
    );
  });
}
