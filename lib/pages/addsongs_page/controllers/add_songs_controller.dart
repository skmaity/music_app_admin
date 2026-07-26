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

class AddSongsController extends GetxController {
  final d.Dio _dio = d.Dio();

  Future<void> addSong(
    Uint8List? coverImg,
    Uint8List? songFile,
    String artist,
    String title,
    BuildContext context,
  ) async {
    try {
      if (coverImg == null || songFile == null) {
        showOverlayToast(
            Get.context!, false, 'Please pick a cover and song file');
        return;
      }

      String songId = const Uuid().v4();

      d.FormData formData = d.FormData.fromMap({
        'title': title,
        'artist': artist,
        'coverfile': d.MultipartFile.fromBytes(
          coverImg,
          filename: "$songId.jpg",
        ),
        'songfile': d.MultipartFile.fromBytes(
          songFile,
          filename: "$songId.mp3",
        ),
      });

      d.Response response = await _dio.post(
        adminAddSongsUrl,
        data: formData,
        options: d.Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        showOverlayToast(
            Get.context!, response.data['success'], response.data['message']);
      } else {
        showOverlayToast(
            Get.context!, response.data['success'], response.data['message']);
      }
    } catch (e) {
      showOverlayToast(Get.context!, false, 'Upload failed: $e');
      // print(e);
    }
  }

  Future<void> pickAndBulkUpload(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['mp3'],
        withData: kIsWeb, // Needed for `fromBytes`
      );

      if (result == null || result.count == 0) {
        showOverlayToast(Get.context!, false, 'No files selected.');
        return;
      }

      List<Map<String, dynamic>> metadataList = [];

      for (final file in result.files) {
        try {
          Metadata metadata;

          if (kIsWeb) {
            metadata = await MetadataRetriever.fromBytes(file.bytes!);
          } else {
            metadata = await MetadataRetriever.fromFile(File(file.path!));
          }

          final data = {
            'title': metadata.trackName ?? 'Unknown Title',
            'artist': metadata.trackArtistNames ?? 'Unknown Artist',
            'album': metadata.albumName ?? 'Unknown Album',
            'duration': metadata.trackDuration ?? 0,
            'fileName': file.name,
          };

          metadataList.add(data);
        } catch (e) {
          debugPrint('Error reading metadata from ${file.name}: $e');
        }
      }

      debugPrint(
          'Finished extracting metadata for ${metadataList.length} files.');

      showOverlayToast(Get.context!, true,
          'Metadata extracted for ${metadataList.length} files.');
    } catch (e) {
      showOverlayToast(Get.context!, false, 'Failed to pick files: $e');
    }
  }
}
