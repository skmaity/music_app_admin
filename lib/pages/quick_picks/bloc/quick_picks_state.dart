part of 'quick_picks_bloc.dart';

class QuickPicksState extends Equatable {
  final List<MySongs> quickPicks;
  final List<MySongs> allSongs;
  final bool isLoading;

  /// The one song currently being toggled, so a single row spins.
  final int? busyId;
  final String? toastMessage;
  final bool? toastSuccess;

  const QuickPicksState({
    this.quickPicks = const [],
    this.allSongs = const [],
    this.isLoading = false,
    this.busyId,
    this.toastMessage,
    this.toastSuccess,
  });

  QuickPicksState copyWith({
    List<MySongs>? quickPicks,
    List<MySongs>? allSongs,
    bool? isLoading,
    int? Function()? busyId,
    String? Function()? toastMessage,
    bool? Function()? toastSuccess,
  }) {
    return QuickPicksState(
      quickPicks: quickPicks ?? this.quickPicks,
      allSongs: allSongs ?? this.allSongs,
      isLoading: isLoading ?? this.isLoading,
      busyId: busyId != null ? busyId() : this.busyId,
      toastMessage: toastMessage != null ? toastMessage() : this.toastMessage,
      toastSuccess: toastSuccess != null ? toastSuccess() : this.toastSuccess,
    );
  }

  @override
  List<Object?> get props =>
      [quickPicks, allSongs, isLoading, busyId, toastMessage, toastSuccess];
}
