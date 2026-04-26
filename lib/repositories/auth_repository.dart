import '../repositories/api_client.dart';

class AuthRepository {
  // AuthController.SaveLogic1: 회원가입
  Future<Map<String, dynamic>> saveLogic1(Map<String, dynamic> body) {
    return ApiClient.post('/auth/signup', body);
  }

  // AuthController.SaveLogic2: 로그인
  Future<Map<String, dynamic>> saveLogic2({
    required String email,
    required String password,
  }) {
    return ApiClient.post('/auth/login', {
      'email': email,
      'password': password,
    });
  }

  // AuthController.SearchLogic1: 현재 사용자 정보 조회
  Future<Map<String, dynamic>> searchLogic1() {
    return ApiClient.get('/auth/me');
  }

  Future<Map<String, dynamic>> socialLogin({
    required String provider,
    required String? socialId,
    required String? email,
    required String? name,
    required String? profileImage,
  }) {
    return ApiClient.post('/auth/social-login', {
      'provider': provider,
      'socialId': socialId,
      'email': email,
      'name': name,
      'profileImage': profileImage,
    });
  }
}
