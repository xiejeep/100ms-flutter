import 'dart:io';

import 'package:demo_with_getx_and_100ms/controllers/PreviewController.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class PreviewWidget extends StatelessWidget {
  const PreviewWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GetBuilder<PreviewController>(
              init: PreviewController(),
              builder: (controller) => SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14)),
                      onPressed: () async {
                        final TextEditingController textEditingController =
                            TextEditingController();
                        //使用缓存的邀请码
                        final appInfo = await GetStorage().read('appInfo');
                        final _inviteCode = appInfo?['id'];
                        if (_inviteCode != null) {
                          textEditingController.text = _inviteCode;
                        }
                        final String? inviteCode = await Get.dialog(
                          AlertDialog(
                            backgroundColor: Get.theme.primaryColor,
                            title: const Text('创建房间'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: textEditingController,
                                  decoration: const InputDecoration(
                                    hintText: '请输入邀请码',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text('取消'),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (textEditingController.text.isEmpty) {
                                    Get.showSnackbar(const GetSnackBar(
                                      message: "请填写邀请码",
                                    ));
                                    return;
                                  }
                                  Get.back(result: textEditingController.text);
                                },
                                child: const Text('确定'),
                              ),
                            ],
                          ),
                        );
                        if (inviteCode != null) {
                          controller.createRoom(inviteCode);
                        }
                      },
                      child: const Text(
                        "创建会议",
                        style: TextStyle(
                            height: 1,
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14)),
                      onPressed: () async {
                        final TextEditingController textEditingController =
                            TextEditingController();

                        final String? roomId = await Get.dialog(
                          AlertDialog(
                            backgroundColor: Get.theme.primaryColor,
                            title: const Text('加入房间'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: textEditingController,
                                  decoration: const InputDecoration(
                                    hintText: '请输入房间号',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text('取消'),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (textEditingController.text.isEmpty) {
                                    Get.showSnackbar(const GetSnackBar(
                                      message: "请填写房间号",
                                    ));
                                    return;
                                  }
                                  Get.back(result: textEditingController.text);
                                },
                                child: const Text('确定'),
                              ),
                            ],
                          ),
                        );
                        if (roomId != null) {
                          controller.joinRoom(roomId);
                        }
                      },
                      child: const Text(
                        "加入会议",
                        style: TextStyle(
                            height: 1,
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14)),
                      onPressed: () async {
                        GetStorage().remove('BASE_URL');
                        BaseOptions options = BaseOptions(
                          baseUrl: 'http://dfsgadsfg.19191919.cc',
                        );

                        final dio = Dio(options);

                        // 获取备用域名
                        final response = await dio.get('');
                        final baseUrl = response.data;
                        GetStorage().write('BASE_URL', baseUrl);
                        Get.dialog(AlertDialog(
                          title: const Text('切换域名成功'),
                          content: const Text('请重新启动应用'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                exit(0);
                              },
                              child: const Text('确定'),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: const Text('取消'),
                            ),
                          ],
                        ));
                      },
                      child: const Text(
                        "切换域名",
                        style: TextStyle(
                            height: 1,
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
