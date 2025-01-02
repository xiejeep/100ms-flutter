import 'dart:io';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';

import '../api.dart';

class PreviewController extends GetxController {
  final String appGroup = "group.com.ksmdklsd.app";
  final String preferredExtension = "com.ksmdklsd.app.FlutterBroadcast";
  HMSSDK hmsSdk = Get.put(HMSSDK());

  @override
  void onInit() async {
    hmsSdk.iOSScreenshareConfig = HMSIOSScreenshareConfig(
      appGroup: appGroup,
      preferredExtension: preferredExtension,
    );
    hmsSdk.hmsTrackSetting = HMSTrackSetting(
      videoTrackSetting: HMSVideoTrackSetting(
        trackInitialState: HMSTrackInitState.MUTED,
      ),
    );
    await hmsSdk.build();
    super.onInit();
  }

  createRoom(String inviteCode) async {
    EasyLoading.show(status: '加载中...');
    try {
      late Map<String, dynamic> response;
      //检查是否有缓存
      final appInfo = GetStorage().read('appInfo');
      final bool useCache = appInfo != null && appInfo['id'] == inviteCode;

      if (useCache) {
        // 使用缓存数据请求
        response = await requestRoomInfo(
            inviteCode: appInfo['id'],
            num: appInfo['num'],
            token: appInfo['token']);
      } else {
        // 不使用缓存数据请求
        response = await requestRoomInfo(inviteCode: inviteCode);
      }
      GetStorage().write('appInfo', response);

      final token = response['key'];
      if (token == null) {
        Get.snackbar("错误", "创建会议失败:key为空");
        return;
      }

      final displayName = response['roomid'] ?? "Guest";
      jumpToPage(displayName, token, true);
    } catch (e) {
      Get.snackbar("错误", e.toString());
    } finally {
      EasyLoading.dismiss();
    }
  }

  joinRoom(String roomId) async {
    EasyLoading.show(status: '加载中...');
    try {
      final response = await requestJoinRoom(roomId);

      final token = response['key'];
      if (token == null) {
        Get.snackbar("错误", "加入会议失败:key为空");
        return;
      }

      final displayName = response['roomid'] ?? "Guest";
      jumpToPage(displayName, token, false);
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

  // void leaveMeeting() async {
  //   hmsSdk.leave(hmsActionResultListener: this);
  // }

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
