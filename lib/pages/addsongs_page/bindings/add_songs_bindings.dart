import 'package:get/get.dart';
import 'package:music_app_admin/pages/addsongs_page/add_songs_functions.dart';
import 'package:music_app_admin/pages/addsongs_page/controllers/add_songs_controller.dart';

class AddSongsBindings implements Bindings {
  @override
  void dependencies() {
    Get.put(AddSongsFunctions());
    Get.put(AddSongsController());
  }
}