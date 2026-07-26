import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:music_app_admin/pages/login_page/repo/login_repo.dart';
import 'package:music_app_admin/model/responce_message.dart';
import 'package:music_app_admin/widgets/top_right_msg.dart';
import 'package:go_router/go_router.dart';

class LoginController extends GetxController {
  LoginRepo repo = LoginRepo();
  logAdmin(BuildContext context, String user, String pass) async {
    try {
      ResponceMessage? responceMessage = await repo.adminLogin(user, pass);
      if (!context.mounted) return;
      if (responceMessage != null) {
        showOverlayToast(
            context, responceMessage.success, responceMessage.message);
        if (responceMessage.success == true) {
          context.go('/home');
        }
      }
    } catch (e) {
      // print("Login error: $e\n$stackTrace");
      showOverlayToast(context, false, "An unexpected error occurred.");
    }
  }
}
