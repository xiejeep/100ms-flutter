import 'dart:io';

import 'package:demo_with_getx_and_100ms/models/PeerTrackNode.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

import '../api.dart';

class RoomController extends GetxController
    implements HMSUpdateListener, HMSActionResultListener {
  // RxBool isLocalVideoOn = true.obs;
  RxBool isLocalAudioOn = true.obs;
  RxBool isScreenShareActive = false.obs;
  String url = Get.arguments['meetingUrl'] ?? '';
  String name = Get.arguments['userName'] ?? '';
  bool isMaster = Get.arguments['isMaster'] ?? false;

  HMSSDK hmsSdk = Get.find<HMSSDK>();

  final showBottomBar = true.obs;

  Rx<PeerTrackNode?> screenShareTrack = Rx<PeerTrackNode?>(null);
  Rx<int> networkQuality = 0.obs;
  Rx<int> networkQualityOfLocal = 0.obs;
  @override
  void onInit() async {
    super.onInit();

    var token = await hmsSdk.getAuthTokenByRoomCode(roomCode: url);
    if (token == null) return;
    if (token is HMSException) {
      print("错误");
      return;
    }
    hmsSdk.addUpdateListener(listener: this);

    if (token == null) return;
    HMSConfig config = HMSConfig(
      authToken: token,
      userName: name,
      captureNetworkQualityInPreview: true,
    );
    hmsSdk.join(config: config);
    EasyLoading.show(
        status: "加载中...",
        dismissOnTap: false,
        maskType: EasyLoadingMaskType.clear);
    Future.delayed(const Duration(seconds: 20), () {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    });
  }

  // @override
  // void dispose() {
  //   hmsSdk.removeUpdateListener(listener: this);
  //   hmsSdk.destroy();
  //   super.dispose();
  // }

  @override
  void onJoin({required HMSRoom room}) {
    EasyLoading.dismiss();
    if (!isMaster) {
      toggleScreenShare();
    }
  }

  @override
  void onTrackUpdate(
      {required HMSTrack track,
      required HMSTrackUpdate trackUpdate,
      required HMSPeer peer}) {
    if (peer.isLocal) {
      if (track.kind == HMSTrackKind.kHMSTrackKindAudio) {
        isLocalAudioOn.value = !track.isMute;
        isLocalAudioOn.refresh();
      }
      return;
    }

    if (track.kind == HMSTrackKind.kHMSTrackKindVideo &&
        track.source != "REGULAR") {
      if (trackUpdate == HMSTrackUpdate.trackRemoved) {
        screenShareTrack.value = null;
      } else {
        screenShareTrack.value = PeerTrackNode(
            peer.peerId + track.trackId, track as HMSVideoTrack, true, peer);
      }
    }
  }

  @override
  void onHMSError({required HMSException error}) {
    // To know more about handling errors please checkout the docs here: https://www.100ms.live/docs/flutter/v2/how--to-guides/debugging/error-handling
    // Get.snackbar("Error", error.message ?? "");
  }

  void leaveMeeting() async {
    try {
      EasyLoading.show(status: "退出中...");
      await exitRoom(name, isMaster ? 1 : 2);
      if (isScreenShareActive.value && Platform.isIOS) {
        hmsSdk.stopScreenShare(hmsActionResultListener: this);
      }
      hmsSdk.leave(hmsActionResultListener: this);
      Get.back();
    } catch (e) {
      Get.snackbar("错误", e.toString());
    } finally {
      EasyLoading.dismiss();
    }
  }

  void toggleMicMuteState() async {
    await hmsSdk.toggleMicMuteState();
    isLocalAudioOn.toggle();
  }

  void toggleScreenShare() {
    if (!isScreenShareActive.value) {
      hmsSdk.startScreenShare(hmsActionResultListener: this);
    } else {
      hmsSdk.stopScreenShare(hmsActionResultListener: this);
    }
  }

  @override
  void onException(
      {HMSActionResultListenerMethod? methodType,
      Map<String, dynamic>? arguments,
      required HMSException hmsException}) {
    switch (methodType) {
      case HMSActionResultListenerMethod.leave:
        Get.snackbar("离开房间失败", hmsException.message ?? "");
        break;
      case HMSActionResultListenerMethod.startScreenShare:
        Get.snackbar("开始共享失败", hmsException.message ?? "");

        break;
      case HMSActionResultListenerMethod.stopScreenShare:
        Get.snackbar("停止共享失败", hmsException.message ?? "");

        break;
      case HMSActionResultListenerMethod.changeTrackState:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.changeMetadata:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.endRoom:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.removePeer:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.acceptChangeRole:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.changeRoleOfPeer:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.changeTrackStateForRole:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.startRtmpOrRecording:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.stopRtmpAndRecording:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.changeName:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.sendBroadcastMessage:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.sendGroupMessage:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.sendDirectMessage:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.hlsStreamingStarted:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.hlsStreamingStopped:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.startAudioShare:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.stopAudioShare:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.switchCamera:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.changeRoleOfPeersWithRoles:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.setSessionMetadataForKey:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.sendHLSTimedMetadata:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.lowerLocalPeerHand:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.lowerRemotePeerHand:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.raiseLocalPeerHand:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.quickStartPoll:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.addSingleChoicePollResponse:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.addMultiChoicePollResponse:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.unknown:
        // TODO: Handle this case.
        break;
      case null:
        // TODO: Handle this case.
        break;
    }
    Get.snackbar("错误", hmsException.message ?? "");
  }

  @override
  void onSuccess(
      {HMSActionResultListenerMethod? methodType,
      Map<String, dynamic>? arguments}) {
    switch (methodType) {
      case HMSActionResultListenerMethod.leave:
        hmsSdk.removeUpdateListener(listener: this);
        // hmsSdk.destroy();
        Get.back();
        break;
      case HMSActionResultListenerMethod.startScreenShare:
        isScreenShareActive.toggle();
        break;
      case HMSActionResultListenerMethod.stopScreenShare:
        isScreenShareActive.toggle();
        break;
      case HMSActionResultListenerMethod.changeTrackState:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.changeMetadata:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.endRoom:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.removePeer:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.acceptChangeRole:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.changeRoleOfPeer:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.changeTrackStateForRole:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.startRtmpOrRecording:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.stopRtmpAndRecording:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.changeName:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.sendBroadcastMessage:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.sendGroupMessage:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.sendDirectMessage:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.hlsStreamingStarted:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.hlsStreamingStopped:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.startAudioShare:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.stopAudioShare:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.switchCamera:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.changeRoleOfPeersWithRoles:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.setSessionMetadataForKey:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.sendHLSTimedMetadata:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.lowerLocalPeerHand:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.lowerRemotePeerHand:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.raiseLocalPeerHand:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.quickStartPoll:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.addSingleChoicePollResponse:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.addMultiChoicePollResponse:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.unknown:
        // TODO: Handle this case.
        break;
      case null:
        // TODO: Handle this case.
        break;
    }
  }

  @override
  void onAudioDeviceChanged(
      {HMSAudioDevice? currentAudioDevice,
      List<HMSAudioDevice>? availableAudioDevice}) {
    // Checkout the docs about handling onAudioDeviceChanged updates here: https://www.100ms.live/docs/flutter/v2/how--to-guides/listen-to-room-updates/update-listeners
  }

  @override
  void onMessage({required HMSMessage message}) {
    // Checkout the docs for chat messaging here: https://www.100ms.live/docs/flutter/v2/how--to-guides/set-up-video-conferencing/chat
  }

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    if (update == HMSPeerUpdate.networkQualityUpdated) {
      if (peer.isLocal) {
        networkQualityOfLocal.value = peer.networkQuality?.quality ?? 0;
      } else {
        networkQuality.value = peer.networkQuality?.quality ?? 0;
      }
      print(
          "Network Quality of ${peer.name} in Room  ${peer.networkQuality?.quality}");
    }

    // Checkout the docs for peer updates here: https://www.100ms.live/docs/flutter/v2/how--to-guides/listen-to-room-updates/update-listeners
  }

  @override
  void onReconnected() {
    // Checkout the docs for reconnection handling here: https://www.100ms.live/docs/flutter/v2/how--to-guides/handle-interruptions/reconnection-handling
  }

  @override
  void onReconnecting() {
    // Checkout the docs for reconnection handling here: https://www.100ms.live/docs/flutter/v2/how--to-guides/handle-interruptions/reconnection-handling
  }

  @override
  void onRemovedFromRoom(
      {required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer}) {
    // Checkout the docs for handling the peer removal here: https://www.100ms.live/docs/flutter/v2/how--to-guides/interact-with-room/peer/remove-peer
  }

  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {
    // Checkout the docs for handling the role change request here: https://www.100ms.live/docs/flutter/v2/how--to-guides/interact-with-room/peer/change-role#accept-role-change-request
  }

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {
    // Checkout the docs for room updates here: https://www.100ms.live/docs/flutter/v2/how--to-guides/listen-to-room-updates/update-listeners
  }

  @override
  void onChangeTrackStateRequest(
      {required HMSTrackChangeRequest hmsTrackChangeRequest}) {
    // Checkout the docs for handling the unmute request here: https://www.100ms.live/docs/flutter/v2/how--to-guides/interact-with-room/track/remote-mute-unmute
  }

  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {
    // Checkout the docs for handling the updates regarding who is currently speaking here: https://www.100ms.live/docs/flutter/v2/how--to-guides/set-up-video-conferencing/render-video/show-audio-level
  }

  @override
  void onPeerListUpdate(
      {required List<HMSPeer> addedPeers,
      required List<HMSPeer> removedPeers}) {
    // TODO: implement onPeerListUpdate
  }

  @override
  void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore}) {
    // TODO: implement onSessionStoreAvailable
  }
}
