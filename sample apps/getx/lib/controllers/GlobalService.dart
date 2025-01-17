import 'dart:async';
import 'dart:convert';

import 'package:demo_with_getx_and_100ms/utils/totp.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

const hostList = [
  'http://hdfbsdwef.19191919.cc/',
  'http://dfbregr.19191919.cc/',
  'http://asfcvwse.19191919.cc/',
  'http://ergtyur.19191919.cc/',
  'http://sjrthe.19191919.cc/',
  'http://fdgdfger.19191919.cc/',
  'http://fbdf.19191919.cc/',
  'http://dfbfdg.19191919.cc/',
  'http://dhghsdfh.19191919.cc/',
  'http://cvdsv.19191919.cc/',
  'http://yyertret.19191919.cc/',
  'http://sdfgesfevb.19191919.cc/',
  'http://ftjherg.19191919.cc/',
  'http://grtertg.19191919.cc/',
  'http://dfbvrg.19191919.cc/',
  'http://thrs.19191919.cc/',
  'http://trfthr.19191919.cc/',
  'http://fvbdfvs.19191919.cc/',
  'http://naer.19191919.cc/',
  'http://bdfbfsd.19191919.cc/',
  'http://vcbfr.19191919.cc/',
  'http://fgnfg.19191919.cc/',
  'http://cvbrfb.19191919.cc/',
  'http://bdfbfd.19191919.cc/',
  'http://sdfsdfe.19191919.cc/',
  'http://sdfwef.19191919.cc/',
  'http://dfsgadsfg.19191919.cc/',
  'http://sdfsdf.19191919.cc/',
  'http://fsaaf.19191919.cc/',
  'http://sadfjhkljwe.19191919.cc',
];

class GlobalService extends GetxService {
  static GlobalService service = Get.find<GlobalService>();
  int leftTime = 30;
  final _names = <String>[];
  final _codes = <String>[];
  bool urlChanged = false;

  @override
  void onInit() {
    super.onInit();
    _addCode("code", "OVIPQEWJJAOEQN7V");
    _retrieveData();
    Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      leftTime = DateTime.now().second % 30;
      _retrieveData();
    });
  }

  Future<void> _retrieveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var keys = prefs.getKeys();
    _names.clear();
    _codes.clear();
    for (var element in keys) {
      _names.add(element);
      _codes.add(prefs.getString(element) ?? "");
    }
    if (_names.length > 100) {
      String firstKey = _names[0];
      await prefs.remove(firstKey);
      _names.removeAt(0);
      _codes.removeAt(0);
    }
  }

  String getServiceSecret() {
    return TOTP(_codes[0]).now();
  }

  _addCode(String key, value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  //检查当前域名是否可用
  Future<bool> checkDomain() async {
    GetStorage().remove('BASE_URL');
    final code = getServiceSecret();

    for (var host in hostList) {
      try {
        BaseOptions options = BaseOptions(
          contentType: 'application/json',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 5),
        );

        final dio = Dio(options);
        print('正在检查域名: $host');

        final response = await dio.get(
          host,
          queryParameters: {'code': code},
          cancelToken: CancelToken(),
        );

        if (response.statusCode == 200) {
          final baseUrl = jsonDecode(response.data)['url'] ?? '';
          if (baseUrl.isNotEmpty) {
            print('找到可用域名: $baseUrl');
            GetStorage().write('BASE_URL', 'http://' + baseUrl);
            GetStorage().save();
            return true; // 找到可用域名，返回成功
          }
        }
      } catch (e) {
        if (e is DioException) {
          print('域名 $host 检查失败: ${e.type} - ${e.message}');
        } else {
          print('域名 $host 检查失败: ${e.toString()}');
        }
        continue;
      }
    }

    print('警告: 所有域名检查完毕，未找到可用域名');
    return false; // 所有域名都检查失败，返回失败
  }

  Future<bool> checkDomainByEnv() async {
    final host = hostList[0];
    final code = getServiceSecret();
    try {
      BaseOptions options = BaseOptions(
        baseUrl: host,
        contentType: 'application/json',
        // 增加超时时间
        connectTimeout: const Duration(seconds: 10), // 从5秒改为10秒
        receiveTimeout: const Duration(seconds: 5), // 从3秒改为5秒
      );

      final dio = Dio(options);
      print('正在检查域名: $host');

      final response = await dio.get(
        '',
        queryParameters: {'code': code},
        // 添加取消令牌
        cancelToken: CancelToken(),
      );

      if (response.statusCode == 200) {
        final baseUrl = jsonDecode(response.data)['url'] ?? '';
        if (baseUrl.isNotEmpty) {
          print('当前域名可用: $host，真实域名: $baseUrl');
          urlChanged = true;
          //保存域名，用于下次请求房间
          GetStorage().write('BASE_URL', 'http://' + baseUrl);
          GetStorage().save();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('当前域名不可用,从域名列表中检查: $e');
      return false;
    }
  }
}
