// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:music_app_admin/pages/quick_picks/alert_msg/alert_msg.dart';
import 'package:music_app_admin/pages/quick_picks/models/song_model.dart';

class QuickPicksController extends GetxController {
  var quickPicks = <Song>[].obs;
  var allSongs = <Song>[].obs;

  // final db = FirebaseFirestore.instance;

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

  // RxBool isAddToQuickPicksLoading = false.obs;
  // addToQuickPicks(Song song) async {
  //   isAddToQuickPicksLoading.value = true;
  //   // Check if the song is already in quick picks 
  //   if (quickPicks.any((element) => element.songid == song.songid)) {
  //     isAddToQuickPicksLoading.value = false;
  //     // showAlert(Get.context!, 'Error', 'Already in Quick Picks', isError: true);
  //     return;
  //   }
  //   db.collection('quickpicks').doc(song.songid).set({
  //     'songid': song.songid,
  //     'title': song.title,
  //     'artist': song.artist,
  //     'cover': song.cover, 
  //     'song': song.song,
  //   }).then((value) {
  //     quickPicks.add(song);
  //   });
  //   isAddToQuickPicksLoading.value = false;
  // }

  // removeQuickPicks(Song song) {
  //   db.collection('quickpicks').doc(song.songid).delete().then((value) {
  //     quickPicks.removeWhere((element) => element.songid == song.songid);
  //   });
  // }
}
