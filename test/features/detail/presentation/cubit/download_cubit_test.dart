// Path: test/features/detail/presentation/cubit/download_cubit_test.dart
import "package:bloc_test/bloc_test.dart";
import "package:flutter_test/flutter_test.dart";
import "package:infinite_image_gallery_pixabay/core/constants/app_strings.dart";
import "package:infinite_image_gallery_pixabay/core/error/exceptions.dart";
import "package:infinite_image_gallery_pixabay/features/detail/data/services/image_download_service.dart";
import "package:infinite_image_gallery_pixabay/features/detail/presentation/cubit/download_cubit.dart";
import "package:infinite_image_gallery_pixabay/features/detail/presentation/cubit/download_state.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/data/models/photo_model.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/entities/photo.dart";
import "package:mocktail/mocktail.dart";

import "../../../gallery/gallery_fixtures.dart";

class MockImageDownloadService extends Mock implements ImageDownloadService {}

void _noopProgress(double _) {}

Photo _samplePhoto() =>
    PhotoModel.fromJson(sampleHitJson()).toEntity();

void main() {
  late MockImageDownloadService mockService;

  setUpAll(() {
    registerFallbackValue("");
    registerFallbackValue(_noopProgress);
  });

  setUp(() {
    mockService = MockImageDownloadService();
  });

  DownloadCubit buildCubit() => DownloadCubit(service: mockService);

  group("DownloadCubit.download", () {
    blocTest<DownloadCubit, DownloadState>(
      "emits progress then success",
      build: () {
        when(
          () => mockService.downloadToGallery(
            any(),
            onProgress: any(named: "onProgress"),
            fileName: any(named: "fileName"),
          ),
        ).thenAnswer((Invocation inv) async {
          final void Function(double) onProgress =
              inv.namedArguments[#onProgress] as void Function(double);
          onProgress(0.5);
          return "saved.jpg";
        });
        return buildCubit();
      },
      act: (DownloadCubit cubit) => cubit.download(_samplePhoto()),
      expect: () => const <DownloadState>[
        DownloadState(status: DownloadStatus.inProgress, progress: 0),
        DownloadState(status: DownloadStatus.inProgress, progress: 0.5),
        DownloadState(status: DownloadStatus.success, savedAs: "saved.jpg"),
      ],
      verify: (_) {
        verify(
          () => mockService.downloadToGallery(
            "https://pixabay.com/get/large_1280.jpg",
            onProgress: any(named: "onProgress"),
            fileName: "pixabay_123456",
          ),
        ).called(1);
      },
    );

    blocTest<DownloadCubit, DownloadState>(
      "maps PermissionException to failure",
      build: () {
        when(
          () => mockService.downloadToGallery(
            any(),
            onProgress: any(named: "onProgress"),
            fileName: any(named: "fileName"),
          ),
        ).thenThrow(const PermissionException("no permission"));
        return buildCubit();
      },
      act: (DownloadCubit cubit) => cubit.download(_samplePhoto()),
      expect: () => const <DownloadState>[
        DownloadState(status: DownloadStatus.inProgress, progress: 0),
        DownloadState(
          status: DownloadStatus.failure,
          errorMessage: "no permission",
        ),
      ],
    );

    blocTest<DownloadCubit, DownloadState>(
      "maps DownloadException to failure",
      build: () {
        when(
          () => mockService.downloadToGallery(
            any(),
            onProgress: any(named: "onProgress"),
            fileName: any(named: "fileName"),
          ),
        ).thenThrow(const DownloadException("nope"));
        return buildCubit();
      },
      act: (DownloadCubit cubit) => cubit.download(_samplePhoto()),
      expect: () => const <DownloadState>[
        DownloadState(status: DownloadStatus.inProgress, progress: 0),
        DownloadState(
          status: DownloadStatus.failure,
          errorMessage: "nope",
        ),
      ],
    );

    blocTest<DownloadCubit, DownloadState>(
      "maps unexpected errors to the generic message",
      build: () {
        when(
          () => mockService.downloadToGallery(
            any(),
            onProgress: any(named: "onProgress"),
            fileName: any(named: "fileName"),
          ),
        ).thenThrow(StateError("?!"));
        return buildCubit();
      },
      act: (DownloadCubit cubit) => cubit.download(_samplePhoto()),
      expect: () => const <DownloadState>[
        DownloadState(status: DownloadStatus.inProgress, progress: 0),
        DownloadState(
          status: DownloadStatus.failure,
          errorMessage: S.downloadFailed,
        ),
      ],
    );

    blocTest<DownloadCubit, DownloadState>(
      "ignores a second download while one is running",
      build: () {
        when(
          () => mockService.downloadToGallery(
            any(),
            onProgress: any(named: "onProgress"),
            fileName: any(named: "fileName"),
          ),
        ).thenAnswer((_) async => "saved.jpg");
        return buildCubit();
      },
      act: (DownloadCubit cubit) {
        cubit.download(_samplePhoto());
        cubit.download(_samplePhoto());
      },
      expect: () => const <DownloadState>[
        DownloadState(status: DownloadStatus.inProgress, progress: 0),
        DownloadState(status: DownloadStatus.success, savedAs: "saved.jpg"),
      ],
      verify: (_) {
        verify(
          () => mockService.downloadToGallery(
            any(),
            onProgress: any(named: "onProgress"),
            fileName: any(named: "fileName"),
          ),
        ).called(1);
      },
    );
  });

  test("starts idle", () {
    expect(buildCubit().state, const DownloadState());
  });
}
