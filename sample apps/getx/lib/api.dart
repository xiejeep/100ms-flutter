import 'package:demo_with_getx_and_100ms/http_client.dart';

//获取房间token
Future<Map<String, dynamic>> requestRoomInfo(
    {required String inviteCode,
    int num = -1,
    String? token = '-1',
    required String code}) async {
  return HttpClient().get('/token', queryParameters: {
    'id': inviteCode,
    'num': num,
    'token': token,
    'code': code,
  });
}

//加入房间
Future<Map<String, dynamic>> requestJoinRoom(String roomId, String code) async {
  return HttpClient().get('/join2', queryParameters: {
    'roomid': roomId,
    'code': code,
  });
}

///退出房间
///type：1房主退出，2成员退出
Future<Map<String, dynamic>> exitRoom(String roomid, int type) async {
  return HttpClient().get('/exits', queryParameters: {
    'roomid': roomid,
    'type': type,
  });
}
