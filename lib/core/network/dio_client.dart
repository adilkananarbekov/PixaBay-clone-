import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/pixabay_api_config.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
  }
}

class DioClient {
  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: PixabayApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(),
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.next(options);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
      LogInterceptor(
        requestHeader: false,
        responseBody: false,
      ),
    ]);
  }

  late final Dio _dio;

  Dio get dio => _dio;
}

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});
