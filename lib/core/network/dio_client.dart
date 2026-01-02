import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/api_constants.dart';

class DioClient {
  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: kPixabayBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.next(options);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestHeader: false,
        responseBody: false,
      ),
    );
  }

  late final Dio _dio;

  Dio get dio => _dio;
}

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});
