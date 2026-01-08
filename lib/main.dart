import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/reservation_service.dart';
import 'services/vehicle_service.dart';
import 'services/social_auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'utils/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 카카오 SDK 초기화 (네이티브 앱 키로 변경 필요)
  SocialAuthService.initKakao('f1370b8914ac0bdd538c9dfc7f7c2741');

  runApp(const FineWashApp());
}

class FineWashApp extends StatelessWidget {
  const FineWashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => VehicleService()),
        ChangeNotifierProvider(create: (_) => ReservationService()),
      ],
      child: MaterialApp(
        title: '출장세차',
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          // 화면별 SafeArea 설정
          Widget buildSafeArea(Widget widget) {
            // 현재 라우트 정보 가져오기
            final route = ModalRoute.of(context);
            final routeName = route?.settings.name;

            // 특정 화면에서 SafeArea를 다르게 적용하려면 여기서 조건 추가
            // 예시:
            // - AppBar가 있는 화면: top SafeArea 제외 (AppBar가 자체적으로 처리)
            // - 전체화면 화면: 모든 방향 SafeArea 적용
            // - 기본: 하단만 SafeArea 적용 (안드로이드 네비게이션 바 대응)

            bool topSafeArea = true;
            bool bottomSafeArea = true;
            bool leftSafeArea = false;
            bool rightSafeArea = false;

            // 화면별 조건 추가 예시
            if (routeName != null) {
              // AppBar가 있는 화면들은 top SafeArea 제외
              if (routeName.contains('reservation') ||
                  routeName.contains('shop') ||
                  routeName.contains('my_page') ||
                  routeName.contains('vehicle')) {
                topSafeArea = false;
              }

              // 전체화면이 필요한 화면
              if (routeName.contains('address_search')) {
                topSafeArea = false;
                bottomSafeArea = true;
              }
            }

            return SafeArea(
              top: topSafeArea,
              bottom: bottomSafeArea,
              left: leftSafeArea,
              right: rightSafeArea,
              child: widget,
            );
          }

          return buildSafeArea(child ?? const SizedBox.shrink());
        },
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimary,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        if (authService.isAuthenticated) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
