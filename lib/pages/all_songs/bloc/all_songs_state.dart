part of 'all_songs_bloc.dart';

class AllSongsState extends Equatable {
  final List<MySongs> songs;
  final String query;
  final bool isLoading;
  final int? busyId;
  final String? toastMessage;
  final bool? toastSuccess;

  const AllSongsState({
    this.songs = const [],
    this.query = '',
    this.isLoading = false,
    this.busyId,
    this.toastMessage,
    this.toastSuccess,
  });

  List<MySongs> get visibleSongs {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return songs;
    return songs
        .where((s) => s.title.toLowerCase().contains(q) || s.artist.toLowerCase().contains(q))
        .toList();
  }

  AllSongsState copyWith({
    List<MySongs>? songs,
    String? query,
    bool? isLoading,
    int? Function()? busyId,
    String? Function()? toastMessage,
    bool? Function()? toastSuccess,
  }) {
    return AllSongsState(
      songs: songs ?? this.songs,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      busyId: busyId != null ? busyId() : this.busyId,
      toastMessage: toastMessage != null ? toastMessage() : this.toastMessage,
      toastSuccess: toastSuccess != null ? toastSuccess() : this.toastSuccess,
    );
  }

  @override
  List<Object?> get props => [songs, query, isLoading, busyId, toastMessage, toastSuccess];
}
