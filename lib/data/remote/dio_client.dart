import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/constants.dart';
import '../../core/logger.dart';

final dioClientProvider = Provider<DioClient>((ref) => DioClient());

class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(BaseOptions(
      baseUrl: AppConstants.mangadexBaseUrl,
      connectTimeout: AppConstants.apiTimeout,
      receiveTimeout: AppConstants.apiTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(_LoggingInterceptor());
    dio.interceptors.add(_ErrorInterceptor());
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    appLogger.d('→ ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    appLogger.d('← ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    appLogger.e('✕ ${err.response?.statusCode} ${err.requestOptions.path}', error: err);
    handler.next(err);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final message = switch (err.type) {
      DioExceptionType.connectionTimeout => 'Délai de connexion dépassé',
      DioExceptionType.receiveTimeout => 'Délai de réception dépassé',
      DioExceptionType.connectionError => 'Pas de connexion internet',
      DioExceptionType.badResponse => 'Erreur serveur (${err.response?.statusCode})',
      _ => 'Erreur réseau inconnue',
    };

    handler.next(DioException(
      requestOptions: err.requestOptions,
      error: message,
      type: err.type,
      response: err.response,
    ));
  }
}