part of 'add_songs_bloc.dart';

abstract class AddSongsEvent extends Equatable {
  const AddSongsEvent();
  @override
  List<Object?> get props => [];
}

class PickCoverImage extends AddSongsEvent {}

class PickSongFile extends AddSongsEvent {}

class SubmitSong extends AddSongsEvent {
  final String title;
  final String artist;
  const SubmitSong({required this.title, required this.artist});
  @override
  List<Object?> get props => [title, artist];
}

class PickBulkSongs extends AddSongsEvent {}

class PickBulkCover extends AddSongsEvent {}

class UploadBulkSongs extends AddSongsEvent {}

class RemoveBulkSong extends AddSongsEvent {
  final int index;
  const RemoveBulkSong(this.index);
  @override
  List<Object?> get props => [index];
}

class ClearForm extends AddSongsEvent {}
