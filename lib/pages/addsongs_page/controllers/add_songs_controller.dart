import 'dart:typed_data';
import 'package:flutter/material.dart';
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
        showOverlayToast(Get.context!, false, 'Please pick a cover and song file');
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
        showOverlayToast(context, response.data['success'], response.data['message']);
      
      } else {
          showOverlayToast(context, response.data['success'], response.data['message']);
      
      }
    } catch (e) {
        showOverlayToast(context, false, 'Upload failed: $e');
        print(e);
      
    }
  }
}
