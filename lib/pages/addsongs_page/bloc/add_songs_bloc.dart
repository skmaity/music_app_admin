import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart' as d;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:uuid/uuid.dart';
import 'package:music_app_admin/session.dart';
import 'package:music_app_admin/url_admin.dart';

part 'add_songs_event.dart';
part 'add_songs_state.dart';

class AddSongsBloc extends Bloc<AddSongsEvent, AddSongsState> {
  final d.Dio _dio = authDio();

  AddSongsBloc() : super(const AddSongsState()) {
    on<PickCoverImage>(_onPickCoverImage);
    on<PickSongFile>(_onPickSongFile);
    on<SubmitSong>(_onSubmitSong);
    on<PickBulkSongs>(_onPickBulkSongs);
    on<PickBulkCover>(_onPickBulkCover);
    on<UploadBulkSongs>(_onUploadBulkSongs);
    on<RemoveBulkSong>(_onRemoveBulkSong);
    on<ClearForm>(_onClearForm);
  }

  Future<void> _onPickCoverImage(PickCoverImage event, Emitter<AddSongsState> emit) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        Uint8List filePath = result.files.single.bytes!;
        emit(state.copyWith(coverBytes: filePath));
      }
    } catch (e) {
      // Ignore or emit error
    }
  }

  Future<void> _onPickSongFile(PickSongFile event, Emitter<AddSongsState> emit) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.single;
        
        String fileName = file.name;
        String? fileExtension = file.extension;
        int fileSize = file.size;
        double fileSizeMB = fileSize / (1024 * 1024);
        Uint8List fileBytes = file.bytes!;

        emit(state.copyWith(
          songBytes: fileBytes,
          songName: fileName,
          songExtension: fileExtension ?? 'error',
          songSize: fileSizeMB.toStringAsFixed(2),
        ));
      }
    } catch (e) {
      // Ignore
    }
  }

  Future<void> _onSubmitSong(SubmitSong event, Emitter<AddSongsState> emit) async {
    if (state.coverBytes == null || state.songBytes == null) {
      emit(state.copyWith(message: 'Please pick a cover and song file', isSuccessMessage: false));
      emit(state.clearMessage());
      return;
    }

    emit(state.copyWith(isSubmitting: true));

    try {
      final response = await _post(state.coverBytes!, state.songBytes!, event.artist, event.title);
      emit(state.copyWith(
        isSubmitting: false,
        message: response.data['message'] ?? 'Success',
        isSuccessMessage: response.data['success'] ?? true,
      ));
      emit(state.clearMessage());
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        message: 'Upload failed: $e',
        isSuccessMessage: false,
      ));
      emit(state.clearMessage());
    }
  }

  Future<void> _onPickBulkSongs(PickBulkSongs event, Emitter<AddSongsState> emit) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['mp3'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      List<BulkSong> newBulkSongs = [];

      for (final file in result.files) {
        final bytes = file.bytes;
        if (bytes == null) continue;

        Metadata? meta;
        try {
          meta = kIsWeb
              ? await MetadataRetriever.fromBytes(bytes)
              : await MetadataRetriever.fromFile(File(file.path!));
        } catch (e) {
          debugPrint('No metadata in ${file.name}: $e');
        }

        newBulkSongs.add(BulkSong(
          fileName: file.name,
          songBytes: bytes,
          title: _tag(meta?.trackName, file.name.replaceAll('.mp3', '')),
          artist: _tag(meta?.trackArtistNames?.join(', '), _tag(meta?.albumArtistName, 'Unknown Artist')),
          album: _tag(meta?.albumName, ''),
          cover: meta?.albumArt,
        ));
      }

      if (newBulkSongs.isEmpty) {
        emit(state.copyWith(message: 'Could not read the picked files', isSuccessMessage: false));
        emit(state.clearMessage());
      } else {
        emit(state.copyWith(
          bulkSongs: newBulkSongs, 
          showBulkDialog: true,
          bulkCover: state.coverBytes, // default to main cover if picked
        ));
        emit(state.copyWith(showBulkDialog: false)); // Reset the trigger
      }
    } catch (e) {
      emit(state.copyWith(message: 'Failed to pick files: $e', isSuccessMessage: false));
      emit(state.clearMessage());
    }
  }

  Future<void> _onPickBulkCover(PickBulkCover event, Emitter<AddSongsState> emit) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        withData: true,
      );
      final bytes = result?.files.single.bytes;
      if (bytes != null) {
        emit(state.copyWith(bulkCover: bytes));
      }
    } catch (_) {
      // Picker cancelled or file unreadable — keep the existing cover.
    }
  }

  void _onRemoveBulkSong(RemoveBulkSong event, Emitter<AddSongsState> emit) {
    if (state.isUploading) return;
    final List<BulkSong> currentSongs = List.from(state.bulkSongs);
    currentSongs.removeAt(event.index);
    emit(state.copyWith(bulkSongs: currentSongs));
  }

  Future<void> _onUploadBulkSongs(UploadBulkSongs event, Emitter<AddSongsState> emit) async {
    if (state.isUploading || state.bulkSongs.isEmpty) return;
    
    emit(state.copyWith(isUploading: true));

    int done = 0, failed = 0;
    List<BulkSong> currentSongs = List.from(state.bulkSongs);

    for (int i = 0; i < currentSongs.length; i++) {
      BulkSong song = currentSongs[i];
      if (song.status == BulkStatus.done) continue;

      final cover = song.cover ?? state.bulkCover;
      if (cover == null) {
        currentSongs[i] = song.copyWith(status: BulkStatus.failed, error: 'No album art — pick a cover below');
        failed++;
        emit(state.copyWith(bulkSongs: List.from(currentSongs)));
        continue;
      }

      currentSongs[i] = song.copyWith(status: BulkStatus.uploading);
      emit(state.copyWith(bulkSongs: List.from(currentSongs)));

      try {
        final response = await _post(cover, song.songBytes, song.artist, song.title);
        
        if (response.statusCode == 200 && response.data['success'] == true) {
          currentSongs[i] = currentSongs[i].copyWith(status: BulkStatus.done, error: null);
          done++;
        } else {
          currentSongs[i] = currentSongs[i].copyWith(
            status: BulkStatus.failed, 
            error: '${response.data is Map ? response.data['message'] : response.data}'
          );
          failed++;
        }
      } on d.DioException catch (e) {
        currentSongs[i] = currentSongs[i].copyWith(
          status: BulkStatus.failed, 
          error: '${e.response?.statusCode ?? ''} ${e.response?.data ?? e.message}'
        );
        failed++;
      } catch (e) {
        currentSongs[i] = currentSongs[i].copyWith(status: BulkStatus.failed, error: '$e');
        failed++;
      }
      emit(state.copyWith(bulkSongs: List.from(currentSongs)));
    }

    emit(state.copyWith(
      isUploading: false,
      message: 'Uploaded $done song${done == 1 ? '' : 's'}${failed > 0 ? ', $failed failed' : ''}',
      isSuccessMessage: failed == 0
    ));
    emit(state.clearMessage());
  }

  void _onClearForm(ClearForm event, Emitter<AddSongsState> emit) {
    emit(const AddSongsState());
  }

  Future<d.Response> _post(
    Uint8List coverImg,
    Uint8List songFile,
    String artist,
    String title,
  ) {
    final String songId = const Uuid().v4();
    return _dio.post(
      adminAddSongsUrl,
      data: d.FormData.fromMap({
        'title': title,
        'artist': artist,
        'coverfile': d.MultipartFile.fromBytes(coverImg, filename: "$songId.jpg"),
        'songfile': d.MultipartFile.fromBytes(songFile, filename: "$songId.mp3"),
      }),
      options: d.Options(contentType: 'multipart/form-data'),
    );
  }

  String _tag(String? value, String fallback) =>
      (value != null && value.trim().isNotEmpty) ? value.trim() : fallback;
}
