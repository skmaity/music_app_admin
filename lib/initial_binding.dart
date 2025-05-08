import 'package:get/get.dart';
import 'package:music_app_admin/login_page/controller/login_controller.dart';

class RootBinding implements Bindings {
  @override
  void dependencies() {
  Get.lazyPut(() => LoginController());
  }
}