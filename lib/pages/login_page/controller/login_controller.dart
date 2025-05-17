import 'package:get/get.dart';
import 'package:music_app_admin/home_page.dart';
import 'package:music_app_admin/pages/login_page/repo/login_repo.dart';
import 'package:music_app_admin/model/responce_message.dart';
import 'package:music_app_admin/widgets/top_right_msg.dart';

class LoginController extends GetxController {
  LoginRepo repo = LoginRepo();
  logAdmin(context ,String user, String pass) async {
    try {
      ResponceMessage? responceMessage = await repo.adminLogin(user, pass);
      if (responceMessage != null) {
        showOverlayToast(context, responceMessage.success, responceMessage.message);
        if (responceMessage.success == true) {
          Get.offAll(() => HomePage()); 
        }
      }
    } catch (e, stackTrace) {
      print("Login error: $e\n$stackTrace");
      showOverlayToast(context, false, "An unexpected error occurred.");
    }
  }

}