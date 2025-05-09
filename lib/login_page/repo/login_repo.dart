import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:music_app_admin/model/responce_message.dart';
import 'package:music_app_admin/url_admin.dart';

class LoginRepo {
  Dio dio = Dio(BaseOptions(
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  Future<ResponceMessage?> adminLogin(String user, String pass) async {
    Map<String, dynamic> data = {
      "admin_pass": pass,
      "admin_id": user,
    };

    try {
      Response response = await dio.post(adminLoginUrl, data: jsonEncode(data));
      return ResponceMessage.fromJson(jsonDecode(response.data));
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }
}
