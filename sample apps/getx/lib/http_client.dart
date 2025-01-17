import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'controllers/GlobalService.dart';

class HttpClient {
  static Dio? _dio;

  static Dio getInstance() {
    if (_dio == null) {
      _dio = Dio();

      // 添加拦截器
      _dio!.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          print('请求: ${options.method} ${options.uri}');
          print('请求头: ${options.headers}');
          print('请求数据: ${options.data}');

          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('响应状态: ${response.statusCode}');
          print('响应数据: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('错误: ${error.message}');
          return handler.next(error);
        },
      ));
    }

    return _dio!;
  }

  Future<Map<String, dynamic>> get(String url,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final baseUrl = GetStorage().read('BASE_URL') ?? hostList[0];

      final code = GlobalService.service.getServiceSecret();
      queryParameters?['code'] = code;
      final response = await getInstance()
          .get(baseUrl + '/api/ms100' + url, queryParameters: queryParameters);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['code'] == 1) {
          return data;
        } else {
          return Future.error(data['msg']);
        }
      } else {
        return Future.error('请求失败1: ${response.statusCode}');
      }
    } catch (e) {
      return Future.error('请求失败2: ${e.toString()}');
    }
  }
}
