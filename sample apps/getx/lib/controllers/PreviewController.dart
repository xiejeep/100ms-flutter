import 'dart:async';
import 'dart:io';
import 'package:demo_with_getx_and_100ms/controllers/GlobalService.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';

import '../api.dart';

class PreviewController extends GetxController {
  @override
  void onInit() async {
    super.onInit();
  }

  createRoom(String inviteCode) async {
    EasyLoading.show(status: '加载中...');
    try {
      late Map<String, dynamic> response;
      //检查是否有缓存
      final appInfo = GetStorage().read('appInfo');
      final bool useCache = appInfo != null;
      final code = GlobalService.service.getServiceSecret();
      if (useCache) {
        // 使用缓存数据请求
        response = await requestRoomInfo(
            inviteCode: inviteCode,
            num: appInfo['num'],
            token: appInfo['token'],
            code: code);
      } else {
        // 不使用缓存数据请求
        response = await requestRoomInfo(inviteCode: inviteCode, code: code);
      }
      await GetStorage().write('appInfo', response);
      GetStorage().save();

      final token = response['key'];
      if (token == null) {
        Get.snackbar("错误", "创建会议失败:key为空");
        return;
      }

      final displayName = response['roomid'] ?? "Guest";
      jumpToPage(displayName.toString(), token, true);
    } catch (e) {
      Get.snackbar("错误", e.toString());
    } finally {
      EasyLoading.dismiss();
    }
  }

  joinRoom(String roomId) async {
    final code = GlobalService.service.getServiceSecret();
    EasyLoading.show(status: '加载中...');
    try {
      final response = await requestJoinRoom(roomId, code);
      GetStorage().write('roomId', roomId);
      final token = response['key'];
      if (token == null) {
        Get.snackbar("错误", "加入会议失败:key为空");
        return;
      }

      final displayName = response['roomid'] ?? "Guest";
      jumpToPage(displayName.toString(), token, false);
    } catch (e) {
      Get.snackbar("错误", e.toString());
    } finally {
      EasyLoading.dismiss();
    }
  }

  jumpToPage(userName, meetingUrl, bool isMaster) async {
    await getPermissions();

    Get.toNamed('room', arguments: {
      'meetingUrl': meetingUrl,
      'userName': userName,
      'isMaster': isMaster
    });
  }

  Future<bool> getPermissions() async {
    if (Platform.isIOS) return true;

    await Permission.microphone.request();

    while ((await Permission.camera.isDenied)) {
      await Permission.camera.request();
    }
    while ((await Permission.microphone.isDenied)) {
      await Permission.microphone.request();
    }

    while ((await Permission.bluetoothConnect.isDenied)) {
      await Permission.bluetoothConnect.request();
    }

    return true;
  }
}
