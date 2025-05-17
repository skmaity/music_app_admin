import 'package:get/get.dart';
import 'package:music_app_admin/pages/login_page/controller/login_controller.dart';

class RootBinding implements Bindings {
  @override
  void dependencies() {
  Get.lazyPut(() => LoginController());
  }
}