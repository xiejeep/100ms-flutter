import 'dart:async';

import 'package:demo_with_getx_and_100ms/utils/totp.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalService extends GetxService {
  static GlobalService service = Get.find<GlobalService>();
  int leftTime = 30;
  final _names = <String>[];
  final _codes = <String>[];

  @override
  void onInit() {
    super.onInit();
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
  }

  String getServiceSecret() {
    return TOTP(_codes[0]).now();
  }
}
