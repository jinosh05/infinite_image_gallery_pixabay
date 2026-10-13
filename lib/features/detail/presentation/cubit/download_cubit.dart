// Path: features/detail/presentation/cubit/download_cubit.dart
import "package:flutter_bloc/flutter_bloc.dart";
import "package:infinite_image_gallery_pixabay/core/constants/app_strings.dart";
import "package:infinite_image_gallery_pixabay/core/error/exceptions.dart";
import "package:infinite_image_gallery_pixabay/features/detail/data/services/image_download_service.dart";
import "package:infinite_image_gallery_pixabay/features/detail/presentation/cubit/download_state.dart";
import "package:infinite_image_gallery_pixabay/features/gallery/domain/entities/photo.dart";

/// Drives one gallery-save from [DetailPage].
/// Guards re-entry while a download is running; maps service exceptions to
/// user-facing messages (the page shows them via snackbar).
class DownloadCubit extends Cubit<DownloadState> {
  DownloadCubit({required this.service}) : super(const DownloadState());

  final ImageDownloadService service;

  Future<void> download(Photo photo) async {
    if (state.status == DownloadStatus.inProgress) return;
    emit(
      const DownloadState(status: DownloadStatus.inProgress, progress: 0),
    );
    try {
      final String savedAs = await service.downloadToGallery(
        photo.detailImageUrl,
        fileName: "pixabay_${photo.id}",
        onProgress: (double p) => emit(
          DownloadState(status: DownloadStatus.inProgress, progress: p),
        ),
      );
      emit(DownloadState(status: DownloadStatus.success, savedAs: savedAs));
    } on PermissionException catch (e) {
      emit(
        DownloadState(
          status: DownloadStatus.failure,
          errorMessage: e.message,
        ),
      );
    } on DownloadException catch (e) {
      emit(
        DownloadState(
          status: DownloadStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        const DownloadState(
          status: DownloadStatus.failure,
          errorMessage: S.downloadFailed,
        ),
      );
    }
  }
}
