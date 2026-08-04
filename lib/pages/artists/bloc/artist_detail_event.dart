part of 'artist_detail_bloc.dart';

sealed class ArtistDetailEvent extends Equatable {
  const ArtistDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadArtistDetails extends ArtistDetailEvent {}

/// Fetches the whole song library for the link dialog. A no-op once loaded.
class LoadLibrary extends ArtistDetailEvent {}

/// Renames / re-banners the artist from their own page. Named apart from the
/// grid's `UpdateArtist` so a file importing both blocs stays unambiguous.
class EditArtist extends ArtistDetailEvent {
  final String name;
  final String bio;

  /// Null leaves the existing image in place.
  final PlatformFile? image;

  const EditArtist(this.name, this.bio, this.image);

  @override
  List<Object?> get props => [name, bio, image];
}

class LinkSongs extends ArtistDetailEvent {
  final List<MySongs> songs;
  const LinkSongs(this.songs);

  @override
  List<Object?> get props => [songs];
}

class UnlinkSong extends ArtistDetailEvent {
  final MySongs song;
  const UnlinkSong(this.song);

  @override
  List<Object?> get props => [song];
}

class AddSongToArtist extends ArtistDetailEvent {
  final String title;
  final PlatformFile cover;
  final PlatformFile audio;

  const AddSongToArtist(this.title, this.cover, this.audio);

  @override
  List<Object?> get props => [title, cover, audio];
}

class DetailOperationCompleted extends ArtistDetailEvent {}
