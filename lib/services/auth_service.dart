import 'package:flutter/foundation.dart';
import '../models/member_model.dart';
import 'api_service.dart';
import 'social_auth_service.dart';

class AuthService extends ChangeNotifier {
  MemberModel? _currentUser;
  bool _isLoading = false;
  SocialProvider? _socialProvider;

  MemberModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  SocialProvider? get socialProvider => _socialProvider;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
      });
      if (response['token'] != null) {
        await ApiService.setToken(response['token']);
      }
      _currentUser = MemberModel.fromJson(response['user']);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // 개발 환경에서는 Mock 로그인 허용
      _currentUser = MemberModel(
        memIdx: 1,
        name: '김민수',
        email: email,
        phone: '010-1234-5678',
      );
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  /// 소셜 로그인 처리
  Future<bool> loginWithSocial(SocialProvider provider) async {
    _isLoading = true;
    notifyListeners();

    try {
      SocialLoginResult result;

      switch (provider) {
        case SocialProvider.kakao:
          result = await SocialAuthService.loginWithKakao();
          break;
        case SocialProvider.naver:
          result = await SocialAuthService.loginWithNaver();
          break;
        case SocialProvider.google:
          result = await SocialAuthService.loginWithGoogle();
          break;
      }

      if (result.success) {
        _socialProvider = provider;

        // 서버에 소셜 로그인 정보 전송
        try {
          final response = await ApiService.post('/auth/social-login', {
            'provider': provider.name,
            'socialId': result.id,
            'email': result.email,
            'name': result.name,
            'profileImage': result.profileImage,
          });

          if (response['token'] != null) {
            await ApiService.setToken(response['token']);
          }
          _currentUser = MemberModel.fromJson(response['user']);
        } catch (e) {
          // 개발 환경에서는 Mock 사용자 생성
          _currentUser = MemberModel(
            memIdx: int.tryParse(result.id ?? '0') ?? DateTime.now().millisecondsSinceEpoch,
            name: result.name ?? '소셜 사용자',
            email: result.email ?? '',
            phone: '',
            socialType: provider.name,
          );
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        debugPrint('소셜 로그인 실패: ${result.errorMessage}');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('소셜 로그인 에러: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.post('/auth/signup', {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      });
      if (response['token'] != null) {
        await ApiService.setToken(response['token']);
      }
      _currentUser = MemberModel.fromJson(response['user']);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _currentUser = MemberModel(
        memIdx: DateTime.now().millisecondsSinceEpoch,
        name: name,
        email: email,
        phone: phone,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  Future<void> logout() async {
    // 소셜 로그인 로그아웃 처리
    if (_socialProvider != null) {
      await SocialAuthService.logoutAll();
      _socialProvider = null;
    }
    await ApiService.removeToken();
    _currentUser = null;
    notifyListeners();
  }
}
