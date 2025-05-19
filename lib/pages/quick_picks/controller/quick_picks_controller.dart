import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as d;
import 'package:music_app_admin/pages/quick_picks/models/song_model.dart';
import 'package:music_app_admin/url_admin.dart';
import 'package:music_app_admin/widgets/top_right_msg.dart';

class QuickPicksController extends GetxController {
  var quickPicks = <MySongs>[].obs;
  var allSongs = <MySongs>[].obs;
  d.Dio dio =d.Dio();

  RxBool isLoading = false.obs;

  // final db = FirebaseFirestore.instance;

  getAllSongs(BuildContext context) { 
    isLoading.value = true;
    try {
      dio.get(adminGetAllSongsUrl).then((value) {
        allSongs.clear();
        for (var element in value.data['data']) { 
          allSongs.add(MySongs.fromJson(element));
        }
      }); 
    } catch (e) {
      print(e);
      showOverlayToast(context, false, 'Failed to fetch songs');
    }
    isLoading.value = false;
    
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

addToQuickPicks(MySongs song,context) async {
  isLoading.value = true;
  try {
    d.Response response = await dio.post(addToQuickPicksUrl, data:
    {"songid": song.songid, "isquickpick": 1}
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      showOverlayToast(context, true, 'Song added to quick picks');
    } else {
      showOverlayToast(context, false, 'Failed to add song to quick picks');
    }
  } catch (e) {
    isLoading.value = false;

    print('Dio error: $e');
    showOverlayToast(context, false, 'Network error: Unable to connect');
  }
  isLoading.value = false;
}

}
