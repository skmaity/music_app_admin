part of 'all_songs_bloc.dart';

sealed class AllSongsEvent extends Equatable {
  const AllSongsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllSongs extends AllSongsEvent {}

class FilterSongs extends AllSongsEvent {
  final String query;
  const FilterSongs(this.query);

  @override
  List<Object?> get props => [query];
}

class UpdateSong extends AllSongsEvent {
  final MySongs song;
  final String title;
  final String artist;
  final PlatformFile? cover;
  final PlatformFile? audio;

  const UpdateSong(this.song, this.title, this.artist, this.cover, this.audio);

  @override
  List<Object?> get props => [song, title, artist, cover, audio];
}

class DeleteSong extends AllSongsEvent {
  final MySongs song;
  const DeleteSong(this.song);

  @override
  List<Object?> get props => [song];
}

class SongOperationCompleted extends AllSongsEvent {}
