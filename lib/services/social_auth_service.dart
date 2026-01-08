import 'package:flutter/foundation.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// 소셜 로그인 제공자 타입
enum SocialProvider { kakao, naver, google }

/// 소셜 로그인 결과 모델
class SocialLoginResult {
  final bool success;
  final String? id;
  final String? email;
  final String? name;
  final String? profileImage;
  final SocialProvider? provider;
  final String? errorMessage;

  SocialLoginResult({
    required this.success,
    this.id,
    this.email,
    this.name,
    this.profileImage,
    this.provider,
    this.errorMessage,
  });
}

/// 소셜 로그인 서비스
class SocialAuthService {
  // Google Sign In 인스턴스
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// 카카오 SDK 초기화 (main.dart에서 호출)
  static void initKakao(String nativeAppKey) {
    KakaoSdk.init(nativeAppKey: nativeAppKey);
  }

  /// 카카오 로그인
  static Future<SocialLoginResult> loginWithKakao() async {
    try {
      // 카카오톡 설치 여부 확인
      bool isInstalled = await isKakaoTalkInstalled();

      OAuthToken token;
      if (isInstalled) {
        // 카카오톡으로 로그인
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        // 카카오 계정으로 로그인
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      debugPrint('카카오 로그인 성공: ${token.accessToken}');

      // 사용자 정보 가져오기
      User user = await UserApi.instance.me();

      debugPrint(
        '카카오 사용자 정보: id=${user.id}, name=${user.kakaoAccount?.profile?.nickname}, email=${user.kakaoAccount?.email}',
      );

      return SocialLoginResult(
        success: true,
        id: user.id.toString(),
        email: user.kakaoAccount?.email,
        name: user.kakaoAccount?.profile?.nickname,
        profileImage: user.kakaoAccount?.profile?.profileImageUrl,
        provider: SocialProvider.kakao,
      );
    } catch (e) {
      debugPrint('카카오 로그인 실패: $e');
      return SocialLoginResult(
        success: false,
        errorMessage: '카카오 로그인에 실패했습니다: $e',
      );
    }
  }

  /// 카카오 로그아웃
  static Future<void> logoutKakao() async {
    try {
      await UserApi.instance.logout();
      debugPrint('카카오 로그아웃 성공');
    } catch (e) {
      debugPrint('카카오 로그아웃 실패: $e');
    }
  }

  /// 네이버 로그인
  static Future<SocialLoginResult> loginWithNaver() async {
    try {
      final result = await FlutterNaverLogin.logIn();

      if (result.status == NaverLoginStatus.loggedIn) {
        debugPrint('네이버 로그인 성공: ${result.accessToken?.accessToken}');

        // 사용자 정보 가져오기 (logIn 결과에 account가 포함되어 있으면 사용, 없으면 별도 조회)
        final account =
            result.account ?? await FlutterNaverLogin.getCurrentAccount();

        debugPrint(
          '네이버 사용자 정보: id=${account.id}, name=${account.name}, email=${account.email}',
        );

        return SocialLoginResult(
          success: true,
          id: account.id,
          email: account.email,
          name: account.name,
          profileImage: account.profileImage,
          provider: SocialProvider.naver,
        );
      } else {
        return SocialLoginResult(
          success: false,
          errorMessage: result.errorMessage ?? '네이버 로그인이 취소되었습니다.',
        );
      }
    } catch (e) {
      debugPrint('네이버 로그인 실패: $e');
      return SocialLoginResult(
        success: false,
        errorMessage: '네이버 로그인에 실패했습니다: $e',
      );
    }
  }

  /// 네이버 로그아웃
  static Future<void> logoutNaver() async {
    try {
      await FlutterNaverLogin.logOut();
      debugPrint('네이버 로그아웃 성공');
    } catch (e) {
      debugPrint('네이버 로그아웃 실패: $e');
    }
  }

  /// 구글 로그인
  static Future<SocialLoginResult> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account != null) {
        debugPrint('구글 로그인 성공');
        debugPrint(
          '구글 사용자 정보: id=${account.id}, name=${account.displayName}, email=${account.email}',
        );

        return SocialLoginResult(
          success: true,
          id: account.id,
          email: account.email,
          name: account.displayName,
          profileImage: account.photoUrl,
          provider: SocialProvider.google,
        );
      } else {
        return SocialLoginResult(
          success: false,
          errorMessage: '구글 로그인이 취소되었습니다.',
        );
      }
    } catch (e) {
      debugPrint('구글 로그인 실패: $e');
      return SocialLoginResult(
        success: false,
        errorMessage: '구글 로그인에 실패했습니다: $e',
      );
    }
  }

  /// 구글 로그아웃
  static Future<void> logoutGoogle() async {
    try {
      await _googleSignIn.signOut();
      debugPrint('구글 로그아웃 성공');
    } catch (e) {
      debugPrint('구글 로그아웃 실패: $e');
    }
  }

  /// 모든 소셜 로그인 로그아웃
  static Future<void> logoutAll() async {
    await Future.wait([logoutKakao(), logoutNaver(), logoutGoogle()]);
  }
}
