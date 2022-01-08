import 'package:hmssdk_flutter/hmssdk_flutter.dart';

class HMSSDKInteractor implements HMSActionResultListener {
  late HMSConfig config;
  late List<HMSMessage> messages;
  late HMSMeeting _meeting;

  HMSSDKInteractor() {
    _meeting = HMSMeeting();
    _meeting.build();
  }

  Future<void> joinMeeting({required HMSConfig config}) async {
    this.config = config;
    await _meeting.joinMeeting(config: this.config);
  }

  void leaveMeeting() async {
    _meeting.leaveMeeting(hmsActionResultListener: this);
  }

  Future<HMSException?> switchAudio({bool isOn = false}) async {
    return await _meeting.switchAudio(isOn: isOn);
  }

  Future<HMSException?> switchVideo({bool isOn = false}) async {
    return await _meeting.switchVideo(isOn: isOn);
  }

  Future<void> switchCamera() async {
    return await _meeting.switchCamera();
  }

  void sendMessage(String message) {
    _meeting.sendMessage(message, "chat");
  }

  void sendDirectMessage(String message, String peerId) async {
    _meeting.sendDirectMessage(
      message,
      peerId,
      "chat",
    );
  }

  void sendGroupMessage(String message, String roleName) async {
    _meeting.sendGroupMessage(
      message,
      roleName,
      "chat",
    );
  }

  Future<void> previewVideo({required HMSConfig config}) async {
    this.config = config;
    return _meeting.previewVideo(config: config);
  }

  void startHMSLogger(HMSLogLevel webRtclogLevel, HMSLogLevel logLevel) {
    _meeting.startHMSLogger(webRtclogLevel, logLevel);
  }

  void removeHMSLogger() {
    _meeting.removeHMSLogger();
  }

  void addLogsListener(HMSLogListener hmsLogListener) {
    _meeting.addLogListener(hmsLogListener);
  }

  void removeLogsListener(HMSLogListener hmsLogListener) {
    _meeting.removeLogListener(hmsLogListener);
  }

  void addMeetingListener(HMSUpdateListener listener) {
    _meeting.addMeetingListener(listener);
  }

  void removeMeetingListener(HMSUpdateListener listener) {
    _meeting.removeMeetingListener(listener);
  }

  void addPreviewListener(HMSPreviewListener listener) {
    _meeting.addPreviewListener(listener);
  }

  void removePreviewListener(HMSPreviewListener listener) {
    _meeting.removePreviewListener(listener);
  }

  void acceptRoleChangeRequest() {
    _meeting.acceptRoleChangeRequest(hmsActionResultListener: this);
  }

  void stopCapturing() {
    _meeting.stopCapturing();
  }

  Future<HMSPeer?> getLocalPeer() async {
    return await _meeting.getLocalPeer();
  }

  Future<bool> startCapturing() async {
    return await _meeting.startCapturing();
  }

  void changeTrackRequest(String peerId, bool mute, bool isVideoTrack) {
    _meeting.changeTrackRequest(peerId, mute, isVideoTrack,
        hmsActionResultListener: this);
  }

  // TODO: implement accept change Track request

  void endRoom(bool lock,String reason) {
    _meeting.endRoom(lock, reason,
        hmsActionResultListener: this);
  }

  void removePeer(String peerId) {
    _meeting.removePeer(peerId, "Removing Peer from Flutter",
        hmsActionResultListener: this);
  }

  void changeRole(
      {required String peerId,
      required String roleName,
      bool forceChange = false}) {
    _meeting.changeRole(
        peerId: peerId,
        roleName: roleName,
        forceChange: forceChange,
        hmsActionResultListener: this);
  }

  Future<List<HMSRole>> getRoles() async {
    return _meeting.getRoles();
  }

  Future<bool> isAudioMute(HMSPeer? peer) async {
    // TODO: add permission checks in exmaple app UI
    return await _meeting.isAudioMute(peer);
  }

  Future<bool> isVideoMute(HMSPeer? peer) async {
    // TODO: add permission checks in exmaple app UI
    return await _meeting.isVideoMute(peer);
  }

  void muteAll() {
    // TODO: add permission checks in exmaple app UI
    _meeting.muteAll();
  }

  void unMuteAll() {
    // TODO: add permission checks in exmaple app UI
    _meeting.unMuteAll();
  }

  void setPlayBackAllowed(bool allow) {
    // TODO: add permission checks in exmaple app UI
    _meeting.setPlayBackAllowed(allow);
  }

  void startRtmpOrRecording(HMSRecordingConfig hmsRecordingConfig) {
    _meeting.startRtmpOrRecording(hmsRecordingConfig,
        hmsActionResultListener: this);
  }

  void stopRtmpAndRecording() {
    _meeting.stopRtmpAndRecording(hmsActionResultListener: this);
  }

  Future<HMSRoom?> getRoom() async {
    return await _meeting.getRoom();
  }

  void raiseHand() {
    _meeting.raiseHand("Raised Hand from Flutter",
        hmsActionResultListener: this);
  }

// TODO: implement changes based on action listener
  @override
  void onError({HMSException? hmsException}) {
    print("HMSSdkInteractor onError");
  }

  @override
  void onSuccess(String? method) {
    switch (method) {
      case "leave-meeting":
        
        break;

      case "change-track-request":
        break;

      case "raise-hand":
        break;

      case "end-room":
        break;

      case "remove-peer":
        break;

      case "accept-role-change-request":
        break;

      case "change-role":
        break;

      case "change-track-state-for-role":
        break;

      case "start-rtmp-or-recording":
        break;

      case "stop-rtmp-or-recording":
        break;

      default:
    }
  }
}
