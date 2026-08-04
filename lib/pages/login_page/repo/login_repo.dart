import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:music_app_admin/model/responce_message.dart';
import 'package:music_app_admin/session.dart';
import 'package:music_app_admin/url_admin.dart';

class LoginRepo {
  Dio dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 20),
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
      if (response.statusCode == 200) {
        final message = ResponceMessage.fromJson(response.data);
        // Keep the token so authDio() can authenticate every later request.
        if (message.success == true) {
          Session.token = '${response.data['token'] ?? ''}';
        }
        return message;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
