import 'package:demo_with_getx_and_100ms/controllers/RoomController.dart';
import 'package:demo_with_getx_and_100ms/views/VideoWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RoomWidget extends StatelessWidget {
  const RoomWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GetBuilder<RoomController>(
        init: RoomController(),
        builder: (RoomController controller) => Scaffold(
          body: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height -
                    (controller.showBottomBar.value
                        ? kBottomNavigationBarHeight
                        : 0),
                color: Colors.black,
                child: Obx(() => controller.screenShareTrack.value == null
                    ? Center(
                        child: Text(
                          '房间号:${controller.name}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : controller.isMaster
                        ? GestureDetector(
                            onDoubleTap: () {
                              controller.showBottomBar.value =
                                  !controller.showBottomBar.value;
                            },
                            child: VideoWidget(controller),
                          )
                        : const Center(
                            child: Text(
                              '通话中',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: Obx(() => Text(
                      '对方网络:${getDescWithNetworkQuality(controller.networkQuality.value)}',
                      style: const TextStyle(color: Colors.white),
                    )),
              ),
              Positioned(
                top: 20,
                left: 20,
                child: Obx(() => Text(
                      '本地网络:${getDescWithNetworkQuality(controller.networkQualityOfLocal.value)}',
                      style: const TextStyle(color: Colors.white),
                    )),
              ),
            ],
          ),
          bottomNavigationBar: Obx(() => controller.showBottomBar.value
              ? BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.black,
                  selectedItemColor: Colors.grey,
                  unselectedItemColor: Colors.grey,
                  items: <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Obx(() => Icon(controller.isLocalAudioOn.value
                          ? Icons.mic
                          : Icons.mic_off)),
                      label: '麦克风',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.videocam_off),
                      label: '摄像头',
                    ),
                    if (!controller.isMaster)
                      BottomNavigationBarItem(
                          icon: Icon(
                            Icons.screen_share,
                            color: controller.isScreenShareActive.value
                                ? Colors.green
                                : Colors.grey,
                          ),
                          label: controller.isScreenShareActive.value
                              ? "停止"
                              : "共享"),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.cancel),
                      label: '离开',
                    ),
                  ],
                  onTap: (index) => _onItemTapped(index))
              : const SizedBox.shrink()),
        ),
      ),
    );
  }

  String getDescWithNetworkQuality(value) {
    if (value == -1) {
      return '无网络';
    } else if (value == 0) {
      return '极差';
    } else if (value == 1) {
      return '差';
    } else if (value == 2) {
      return '差';
    } else if (value == 3) {
      return '一般';
    } else if (value == 4) {
      return '好';
    } else {
      return '极好';
    }
  }

  void _onItemTapped(int index) {
    RoomController controller = Get.find<RoomController>();
    switch (index) {
      case 0:
        controller.toggleMicMuteState();
        break;
      case 1:
        break;
      case 2:
        if (!controller.isMaster) {
          controller.toggleScreenShare();
        } else {
          showLeaveDialog();
        }
        break;
      case 3:
        showLeaveDialog();
        break;
    }
  }

  showLeaveDialog() {
    RoomController controller = Get.find<RoomController>();
    Get.dialog(
      AlertDialog(
        backgroundColor: Get.theme.primaryColor,
        title: const Text('确认离开'),
        content: const Text('您确定要离开房间吗?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.leaveMeeting();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
