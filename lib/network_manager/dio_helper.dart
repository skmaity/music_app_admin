import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioHelper {
  static final DioHelper _instance = DioHelper._internal();
  factory DioHelper() => _instance;

  late Dio _dio;

  DioHelper._internal() {
    BaseOptions options = BaseOptions(
      baseUrl: 'https://yourapi.com/api/', // Replace with your base URL
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    _dio = Dio(options);

    // Add interceptors
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      requestHeader: false,
    ));

    // You can add more interceptors here, such as for authentication
  }

  Future<Response> get({
    required String path,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      // Handle errors
      debugPrint('GET request error: ${e.message}');
      rethrow;
    }
  }

  Future<Response> post({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      // Handle errors
      debugPrint('POST request error: ${e.message}');
      rethrow;
    }
  }

  Future<Response> put({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      // Handle errors
      debugPrint('PUT request error: ${e.message}');
      rethrow;
    }
  }

  Future<Response> delete({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      // Handle errors
      debugPrint('DELETE request error: ${e.message}');
      rethrow;
    }
  }
}
   

   