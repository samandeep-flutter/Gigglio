import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gigglio/services/extension_services.dart';
import '../utils/app_constants.dart';
import 'api_response.dart';

class DioClient {
  late Dio dio;
  final LoggingInterceptor interceptor;

  DioClient({Dio? dio, required this.interceptor}) {
    this.dio = dio ?? Dio();
    if (kDebugMode) this.dio.interceptors.add(interceptor);
  }
  Future<Response> _get(String url, {Options? options}) async {
    final response = await dio.get(url, options: options);
    return response;
  }

  Future<Response> _post(String url, {data, Options? options}) async {
    final response = await dio.post(url, data: data, options: options);
    return response;
  }

  Future<ApiResponse> get(String url,
      {Options? options, required DioClient client}) async {
    try {
      Response response = await client._get(url, options: options);
      return ApiResponse.withSuccess(response);
    } catch (error) {
      return ApiResponse.withError(error);
    }
  }

  Future<ApiResponse> post(String url,
      {required data, Options? options, required DioClient client}) async {
    try {
      Response response = await client._post(url, data: data, options: options);
      return ApiResponse.withSuccess(response);
    } catch (error) {
      return ApiResponse.withError(error);
    }
  }
}

class LoggingInterceptor extends InterceptorsWrapper {
  // @override
  // void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
  //   final path = options.uri.path;
  //   dprint('$path\n ${options.data}');
  //   super.onRequest(options, handler);
  // }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;
    final status = response.statusCode;

    final time = DateTime.now().formatTime;
    dprint('$status | ${options.method} [$time] | ${options.path}\n'
        // '${response.data.toString()}\n'
        '<--------------------------END HTTP-------------------------->');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final status = err.response?.statusCode;
    logPrint(
        'ERROR [$status] ${options.method} | ${options.path}'
            '\n${err.response?.data}',
        'DIO');
    super.onError(err, handler);
  }
}
