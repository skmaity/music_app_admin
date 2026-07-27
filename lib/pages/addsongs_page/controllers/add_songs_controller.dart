import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:get/get.dart';
import 'package:music_app_admin/widgets/top_right_msg.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart' as d;
import 'package:music_app_admin/url_admin.dart';

enum BulkStatus { ready, uploading, done, failed }

/// A song queued for bulk upload, with title / artist / album / cover art
/// filled in from the file's own tags.
class BulkSong {
  BulkSong({
    required this.fileName,
    required this.songBytes,
    required this.title,
    required this.artist,
    required this.album,
    this.cover,
  });

  final String fileName;
  final Uint8List songBytes;
  final Uint8List? cover;
  final String title;
  final String artist;
  final String album;

  BulkStatus status = BulkStatus.ready;
  String? error;
}

class AddSongsController extends GetxController {
  final d.Dio _dio = d.Dio();

  final RxList<BulkSong> bulkSongs = <BulkSong>[].obs;
  final RxBool isUploading = false.obs;

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

  Future<void> addSong(
    Uint8List? coverImg,
    Uint8List? songFile,
    String artist,
    String title,
    BuildContext context,
  ) async {
    try {
      if (coverImg == null || songFile == null) {
        showOverlayToast(context, false, 'Please pick a cover and song file');
        return;
      }

      final response = await _post(coverImg, songFile, artist, title);

      if (!context.mounted) return;
      showOverlayToast(
          context, response.data['success'], response.data['message']);
    } catch (e) {
      if (!context.mounted) return;
      showOverlayToast(context, false, 'Upload failed: $e');
    }
  }

  /// Lets the user select any number of mp3 files and fills [bulkSongs] with
  /// the title, artist, album and cover art read from each file's tags.
  Future<void> pickBulkSongs(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['mp3'],
        withData: true, // bytes are what we upload
      );

      if (result == null || result.files.isEmpty) return;

      bulkSongs.clear();

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

        bulkSongs.add(BulkSong(
          fileName: file.name,
          songBytes: bytes,
          title: _tag(meta?.trackName, file.name.replaceAll('.mp3', '')),
          artist: _tag(meta?.trackArtistNames?.join(', '),
              _tag(meta?.albumArtistName, 'Unknown Artist')),
          album: _tag(meta?.albumName, ''),
          cover: meta?.albumArt,
        ));
      }

      if (bulkSongs.isEmpty && context.mounted) {
        showOverlayToast(context, false, 'Could not read the picked files');
      }
    } catch (e) {
      if (!context.mounted) return;
      showOverlayToast(context, false, 'Failed to pick files: $e');
    }
  }

  /// Cover used for the files that carry no embedded album art.
  final Rx<Uint8List?> bulkCover = Rx<Uint8List?>(null);

  Future<void> pickBulkCover() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      withData: true,
    );
    final bytes = result?.files.single.bytes;
    if (bytes != null) bulkCover.value = bytes;
  }

  /// Uploads the queue one song at a time.
  Future<void> uploadBulkSongs(BuildContext context) async {
    if (isUploading.value || bulkSongs.isEmpty) return;
    isUploading.value = true;

    int done = 0, failed = 0;

    for (final song in bulkSongs.toList()) {
      if (song.status == BulkStatus.done) continue;

      final cover = song.cover ?? bulkCover.value;
      if (cover == null) {
        _mark(song, BulkStatus.failed, 'No album art — pick a cover below');
        failed++;
        continue;
      }

      _mark(song, BulkStatus.uploading);
      try {
        final response =
            await _post(cover, song.songBytes, song.artist, song.title);
        debugPrint(
            'Bulk upload ${song.fileName}: ${response.statusCode} ${response.data}');

        if (response.statusCode == 200 && response.data['success'] == true) {
          _mark(song, BulkStatus.done);
          done++;
        } else {
          _mark(song, BulkStatus.failed,
              '${response.data is Map ? response.data['message'] : response.data}');
          failed++;
        }
      } on d.DioException catch (e) {
        debugPrint('Bulk upload ${song.fileName} failed: ${e.response?.data}');
        _mark(song, BulkStatus.failed,
            '${e.response?.statusCode ?? ''} ${e.response?.data ?? e.message}');
        failed++;
      } catch (e) {
        debugPrint('Bulk upload ${song.fileName} failed: $e');
        _mark(song, BulkStatus.failed, '$e');
        failed++;
      }
    }

    isUploading.value = false;
    if (!context.mounted) return;
    showOverlayToast(context, failed == 0,
        'Uploaded $done song${done == 1 ? '' : 's'}${failed > 0 ? ', $failed failed' : ''}');
  }

  void _mark(BulkSong song, BulkStatus status, [String? error]) {
    song.status = status;
    song.error = error;
    bulkSongs.refresh();
  }

  String _tag(String? value, String fallback) =>
      (value != null && value.trim().isNotEmpty) ? value.trim() : fallback;
}
