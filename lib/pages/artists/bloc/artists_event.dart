part of 'artists_bloc.dart';

sealed class ArtistsEvent extends Equatable {
  const ArtistsEvent();

  @override
  List<Object?> get props => [];
}

class LoadArtists extends ArtistsEvent {}

class FilterArtists extends ArtistsEvent {
  final String query;
  const FilterArtists(this.query);

  @override
  List<Object?> get props => [query];
}

class CreateArtist extends ArtistsEvent {
  final String name;
  final String bio;
  final PlatformFile? image;

  const CreateArtist(this.name, this.bio, this.image);

  @override
  List<Object?> get props => [name, bio, image];
}

class UpdateArtist extends ArtistsEvent {
  final Artist artist;
  final String name;
  final String bio;

  /// Null leaves the existing image in place.
  final PlatformFile? image;

  const UpdateArtist(this.artist, this.name, this.bio, this.image);

  @override
  List<Object?> get props => [artist, name, bio, image];
}

class DeleteArtist extends ArtistsEvent {
  final Artist artist;
  const DeleteArtist(this.artist);

  @override
  List<Object?> get props => [artist];
}

class ArtistOperationCompleted extends ArtistsEvent {}
