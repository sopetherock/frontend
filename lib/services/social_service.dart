import 'api_service.dart';

class SocialService {
  /// 친구 목록 조회
  static Future<List<dynamic>> getFriends() async {
    try {
      // [수정] ApiService.get 사용
      final res = await ApiService.get("/social/friends");
      return res.data;
    } catch (e) {
      print("친구 목록 조회 실패: $e");
      return [];
    }
  }

  /// 친구 검색
  static Future<Map<String, dynamic>?> searchUser(String username) async {
    try {
      // [수정] ApiService.get 사용
      final res = await ApiService.get("/social/search/$username");
      return res.data;
    } catch (_) {
      return null;
    }
  }

  /// 친구 요청 보내기
  static Future<bool> sendRequest(int targetId) async {
    try {
      // [수정] ApiService.post 사용
      await ApiService.post("/social/add/$targetId");
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 받은 요청 목록 조회
  static Future<List<dynamic>> getIncomingRequests() async {
    try {
      // [수정] ApiService.get 사용
      final res = await ApiService.get("/social/requests");
      return res.data;
    } catch (e) {
      print("요청 목록 조회 실패: $e");
      return [];
    }
  }

  /// 요청 수락
  static Future<void> acceptRequest(int friendRelationId) async {
    // [수정] ApiService.post 사용
    await ApiService.post("/social/approve/$friendRelationId");
  }

  /// 그룹 생성
  static Future<Map<String, dynamic>?> createGroup(
      DateTime deadline, List<int> invitedIds) async {
    try {
      // [수정] ApiService.post 사용
      final res = await ApiService.post(
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