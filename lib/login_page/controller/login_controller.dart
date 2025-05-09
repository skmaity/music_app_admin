import 'package:get/get.dart';
import 'package:music_app_admin/home_page.dart';
import 'package:music_app_admin/login_page/repo/login_repo.dart';
import 'package:music_app_admin/model/responce_message.dart';
import 'package:music_app_admin/widgets/top_right_msg.dart';

class LoginController extends GetxController {
  LoginRepo repo = LoginRepo();
  logAdmin(String user, String pass) async {
    ResponceMessage? responceMessage = await repo.adminLogin(user, pass); 
    if (responceMessage != null) {
      if (responceMessage.success == true) {
        Get.offAll(() => HomePage());
        showOverlayToast(Get.context!, responceMessage.success, responceMessage.message);
        
      } else {
        showOverlayToast(Get.context!, responceMessage.success, responceMessage.message);

      }
    }
  }
}
 