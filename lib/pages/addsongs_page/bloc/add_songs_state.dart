part of 'add_songs_bloc.dart';

enum BulkStatus { ready, uploading, done, failed }

class BulkSong {
  BulkSong({
    required this.fileName,
    required this.songBytes,
    required this.title,
    required this.artist,
    required this.album,
    this.cover,
    this.status = BulkStatus.ready,
    this.error,
  });

  final String fileName;
  final Uint8List songBytes;
  final Uint8List? cover;
  final String title;
  final String artist;
  final String album;

  final BulkStatus status;
  final String? error;

  BulkSong copyWith({
    String? fileName,
    Uint8List? songBytes,
    Uint8List? cover,
    String? title,
    String? artist,
    String? album,
    BulkStatus? status,
    String? error,
  }) {
    return BulkSong(
      fileName: fileName ?? this.fileName,
      songBytes: songBytes ?? this.songBytes,
      cover: cover ?? this.cover,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}

class AddSongsState extends Equatable {
  final Uint8List? coverBytes;
  final Uint8List? songBytes;
  final String? coverName;
  final String? songName;
  final String? songSize;
  final String? songExtension;
  final bool isSubmitting;
  final List<BulkSong> bulkSongs;
  final Uint8List? bulkCover;
  final bool isUploading;
  final String? message;
  final bool? isSuccessMessage;
  final bool showBulkDialog;

  const AddSongsState({
    this.coverBytes,
    this.songBytes,
    this.coverName,
    this.songName,
    this.songSize,
    this.songExtension,
    this.isSubmitting = false,
    this.bulkSongs = const [],
    this.bulkCover,
    this.isUploading = false,
    this.message,
    this.isSuccessMessage,
    this.showBulkDialog = false,
  });

  AddSongsState copyWith({
    Uint8List? coverBytes,
    Uint8List? songBytes,
    String? coverName,
    String? songName,
    String? songSize,
    String? songExtension,
    bool? isSubmitting,
    List<BulkSong>? bulkSongs,
    Uint8List? bulkCover,
    bool? isUploading,
    String? message,
    bool? isSuccessMessage,
    bool? showBulkDialog,
  }) {
    return AddSongsState(
      coverBytes: coverBytes ?? this.coverBytes,
      songBytes: songBytes ?? this.songBytes,
      coverName: coverName ?? this.coverName,
      songName: songName ?? this.songName,
      songSize: songSize ?? this.songSize,
      songExtension: songExtension ?? this.songExtension,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      bulkSongs: bulkSongs ?? this.bulkSongs,
      bulkCover: bulkCover ?? this.bulkCover,
      isUploading: isUploading ?? this.isUploading,
      message: message, // Nullable override pattern if needed, but for simplicity let's just use it like this, or we can use a wrapper if we need to clear it.
      isSuccessMessage: isSuccessMessage,
      showBulkDialog: showBulkDialog ?? this.showBulkDialog,
    );
  }
  
  AddSongsState clearMessage() {
    return AddSongsState(
      coverBytes: coverBytes,
      songBytes: songBytes,
      coverName: coverName,
      songName: songName,
      songSize: songSize,
      songExtension: songExtension,
      isSubmitting: isSubmitting,
      bulkSongs: bulkSongs,
      bulkCover: bulkCover,
      isUploading: isUploading,
      message: null,
      isSuccessMessage: null,
      showBulkDialog: showBulkDialog,
    );
  }

  @override
  List<Object?> get props => [
        coverBytes,
        songBytes,
        coverName,
        songName,
        songSize,
        songExtension,
        isSubmitting,
        bulkSongs,
        bulkCover,
        isUploading,
        message,
        isSuccessMessage,
        showBulkDialog,
      ];
}
