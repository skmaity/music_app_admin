part of 'stats_bloc.dart';

sealed class StatsEvent extends Equatable {
  const StatsEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch the counts. Dispatched once when the card mounts, and again whenever
/// the refresh button is pressed.
class LoadStats extends StatsEvent {
  const LoadStats();
}
