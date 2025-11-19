import 'package:dio/dio.dart';
import 'api_service.dart';

class SocialService {
  /// 친구 목록 조회
  static Future<List<dynamic>> getFriends() async {
    final res = await ApiService.dio.get("/social/friends");
    return res.data;
  }

  /// 친구 검색
  static Future<Map<String, dynamic>?> searchUser(String username) async {
    try {
      final res = await ApiService.dio.get("/social/search/$username");
      return res.data;
    } catch (_) {
      return null;
    }
  }

  /// 친구 요청 보내기
  static Future<bool> sendRequest(int targetId) async {
    try {
      await ApiService.dio.post("/social/add/$targetId");
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 받은 요청 목록 조회
  static Future<List<dynamic>> getIncomingRequests() async {
    final res = await ApiService.dio.get("/social/requests");
    return res.data;
  }

  /// 요청 수락
  static Future<void> acceptRequest(int friendRelationId) async {
    await ApiService.dio.post("/social/approve/$friendRelationId");
  }

  /// 그룹 생성
  static Future<Map<String, dynamic>?> createGroup(
      DateTime deadline, List<int> invitedIds) async {
    try {
      final res = await ApiService.dio.post(
        "/social/groups",
        data: {
          "deadline": deadline.toIso8601String(),
          "invitedFriendIds": invitedIds,
        },
      );
      return res.data;
    } catch (_) {
      return null;
    }
  }
}
