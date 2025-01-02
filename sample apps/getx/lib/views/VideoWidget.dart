import 'package:demo_with_getx_and_100ms/controllers/RoomController.dart';
import 'package:demo_with_getx_and_100ms/views/VideoView.dart';
import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:get/get.dart';

class VideoWidget extends StatelessWidget {
  final RoomController roomController;

  const VideoWidget(this.roomController, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FocusDetector(
      onFocusGained: () {
        roomController.screenShareTrack.update((val) {
          val?.isOffScreen = false;
        });
      },
      onFocusLost: () {
        roomController.screenShareTrack.update((val) {
          val?.isOffScreen = true;
        });
      },
      child: Obx(() {
        var track = roomController.screenShareTrack.value!;
        return SizedBox.expand(
          child: (track.hmsVideoTrack != null && !track.hmsVideoTrack!.isMute)
              ? ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned.fill(
                        child: VideoView(
                          track.hmsVideoTrack!,
                          track.peer.name,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 16,
                        child: Text(
                          track.peer.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : Container(
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: CircleAvatar(
                          backgroundColor: Colors.green,
                          radius: 36,
                          child: Text(
                            track.peer.name[0],
                            style: const TextStyle(
                              fontSize: 36,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            track.peer.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
        );
      }),
    );
  }
}
