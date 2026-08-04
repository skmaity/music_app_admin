part of 'quick_picks_bloc.dart';

sealed class QuickPicksEvent extends Equatable {
  const QuickPicksEvent();

  @override
  List<Object?> get props => [];
}

class LoadQuickPicks extends QuickPicksEvent {}

class AddToQuickPicks extends QuickPicksEvent {
  final MySongs song;
  const AddToQuickPicks(this.song);

  @override
  List<Object?> get props => [song];
}

class RemoveFromQuickPicks extends QuickPicksEvent {
  final MySongs song;
  const RemoveFromQuickPicks(this.song);

  @override
  List<Object?> get props => [song];
}

class QuickPicksOperationCompleted extends QuickPicksEvent {}
