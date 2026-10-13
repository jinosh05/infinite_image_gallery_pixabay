// Path: features/detail/presentation/cubit/download_state.dart
import "package:equatable/equatable.dart";

enum DownloadStatus { initial, inProgress, success, failure }

/// State of a single download attempt (one cubit per detail page).
class DownloadState extends Equatable {
  const DownloadState({
    this.status = DownloadStatus.initial,
    this.progress = 0,
    this.savedAs = "",
    this.errorMessage = "",
  });

  final DownloadStatus status;
  final double progress;
  final String savedAs;
  final String errorMessage;

  DownloadState copyWith({
    DownloadStatus? status,
    double? progress,
    String? savedAs,
    String? errorMessage,
  }) =>
      DownloadState(
        status: status ?? this.status,
        progress: progress ?? this.progress,
        savedAs: savedAs ?? this.savedAs,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => <Object?>[
        status,
        progress,
        savedAs,
        errorMessage,
      ];
}
