import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:music_app_admin/login_page/repo/login_repo.dart';

class LoginController extends GetxController {

  LoginRepo repo = LoginRepo();
  logAdmin(String user, String pass){
    repo.adminLogin(user, pass);
  }
}