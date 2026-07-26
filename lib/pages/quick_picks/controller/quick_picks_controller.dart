import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as d;
import 'package:music_app_admin/pages/quick_picks/models/song_model.dart';
import 'package:music_app_admin/url_admin.dart';
import 'package:music_app_admin/widgets/top_right_msg.dart';

class QuickPicksController extends GetxController {
  var quickPicks = <MySongs>[].obs;
  var allSongs = <MySongs>[].obs;
  d.Dio dio = d.Dio();

  RxBool isLoading = false.obs;

  // final db = FirebaseFirestore.instance;

  Future<void> getAllSongs(BuildContext context) async {
    isLoading.value = true;
    try {
      final value = await dio.get(adminGetAllSongsUrl);
      allSongs.assignAll(
          [for (var element in value.data['data']) MySongs.fromJson(element)]);
    } catch (e) {
      // print(e);
      if (context.mounted) {
        showOverlayToast(context, false, 'Failed to fetch songs');
      }
    } finally {
      isLoading.value = false;
    }
  }
  // getAllSongs() {
  //   db.collection('songs').get().then((value) {
  //     allSongs.clear();
  //     for (var element in value.docs) {
  //       allSongs.add(Song.fromJson(element.data()));
  //     }
  //   });
  // }

  // getQuickPicks() {
  //   db.collection('quickpicks').get().then((value) {
  //     quickPicks.clear();
  //     for (var element in value.docs) {
  //       quickPicks.add(Song.fromJson(element.data()));
  //     }
  //   });
  // }
  Future<void> getQuickPicks(BuildContext context) async {
    isLoading.value = true;
    try {
      d.Response response = await dio.get(getQuickPicksUrl);

      if (response.statusCode == 200 && response.data['success'] == true) {
        // showOverlayToast(context, true, 'Song added to quick picks');
        quickPicks.assignAll([
          for (var element in response.data['data']) MySongs.fromJson(element)
        ]);
      } else if (context.mounted) {
        showOverlayToast(context, false, 'Failed to get quick picks');
      }
    } catch (e) {
      // print('Dio error: $e');
      if (context.mounted) {
        showOverlayToast(context, false, 'Network error: Unable to connect');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Re-fetches both lists so the UI reflects the change.
  Future<void> _reload(BuildContext context) async {
    await getQuickPicks(context);
    if (context.mounted) await getAllSongs(context);
  }

  Future addToQuickPicks(MySongs song, BuildContext context) async {
    isLoading.value = true;
    try {
      d.Response response = await dio.post(addToQuickPicksUrl,
          data: {"songid": song.songid, "isquickpick": 1});

      if (!context.mounted) return;
      if (response.statusCode == 200 && response.data['success'] == true) {
        showOverlayToast(context, true, 'Song added to quick picks');
        await _reload(context);
      } else {
        showOverlayToast(context, false, 'Failed to add song to quick picks');
      }
    } catch (e) {
      // print('Dio error: $e');
      if (context.mounted) {
        showOverlayToast(context, false, 'Network error: Unable to connect');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future removeFromQuickPicks(MySongs song, BuildContext context) async {
    isLoading.value = true;
    try {
      d.Response response = await dio
          .post(removeFromQuickPicksUrl, data: {"songid": song.songid});

      if (!context.mounted) return;
      if (response.statusCode == 200 && response.data['success'] == true) {
        showOverlayToast(context, true, 'Song removed from quick picks');
        await _reload(context);
      } else {
        showOverlayToast(
            context, false, 'Failed to remove song from quick picks');
      }
    } catch (e) {
      // print('Dio error: $e');
      if (context.mounted) {
        showOverlayToast(context, false, 'Network error: Unable to connect');
      }
    } finally {
      isLoading.value = false;
    }
  }
}
