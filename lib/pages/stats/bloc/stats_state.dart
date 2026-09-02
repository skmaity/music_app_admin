part of 'stats_bloc.dart';

class StatsState extends Equatable {
  final bool isLoading;

  /// Null until the first successful load. Kept across a refresh and across a
  /// failed refresh, so a dropped connection leaves the last known figures up
  /// with an error beside them rather than blanking the card.
  final AppStats? stats;

  final String? error;

  const StatsState({
    this.isLoading = false,
    this.stats,
    this.error,
  });

  /// [error] is getter-wrapped so `null` means "leave it alone" and
  /// `() => null` means "clear it" — the same convention `AllSongsState` uses
  /// for `toastMessage`. [stats] is not wrapped because nothing ever needs to
  /// un-load it.
  StatsState copyWith({
    bool? isLoading,
    AppStats? stats,
    String? Function()? error,
  }) =>
      StatsState(
        isLoading: isLoading ?? this.isLoading,
        stats: stats ?? this.stats,
        error: error != null ? error() : this.error,
      );

  /// The very first load, with nothing yet to show. Distinct from a refresh,
  /// which keeps the old numbers visible underneath.
  bool get isFirstLoad => isLoading && stats == null;

  @override
  List<Object?> get props => [isLoading, stats, error];
}
