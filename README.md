# FineWash Client - 출장세차 앱

Flutter 기반의 출장세차 모바일 앱입니다.

---

## 📁 프로젝트 구조

```
lib/
├── main.dart              # 앱 시작점
├── models/                # 데이터 모델
│   ├── booking_model.dart
│   ├── product_model.dart
│   ├── reservation_model.dart
│   ├── service_type_model.dart
│   ├── user_model.dart
│   └── vehicle_model.dart
├── screens/               # 화면 UI
│   ├── booking_confirmation_screen.dart
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── mobile_wash_booking_screen.dart
│   ├── my_page_screen.dart
│   ├── partner_wash_booking_screen.dart
│   ├── shop_screen.dart
│   ├── signup_screen.dart
│   └── vehicle_registration_screen.dart
├── services/              # API 통신 서비스
│   ├── api_service.dart
│   ├── auth_service.dart
│   ├── booking_service.dart
│   └── vehicle_service.dart
├── utils/                 # 유틸리티
│   └── app_colors.dart
└── widgets/               # 재사용 위젯
```

---

## 📂 폴더별 역할

| 폴더            | 역할               | 비유           |
| --------------- | ------------------ | -------------- |
| `lib/screens/`  | 화면 UI            | 건물의 방들 🏠 |
| `lib/services/` | 서버와 통신        | 배달부 📦      |
| `lib/models/`   | 데이터 형태 정의   | 주문서 양식 📋 |
| `lib/utils/`    | 유틸리티 (색상 등) | 도구함 🧰      |
| `lib/widgets/`  | 재사용 가능한 위젯 | 레고 블록 🧱   |

---

## 🚀 시작하기

### 의존성 설치 및 실행

```bash
# 의존성 설치
flutter pub get

# 앱 실행
flutter run
```

### Android Studio에서 실행하기

1. Android Studio 실행 → `Open` 클릭
2. 프로젝트 폴더 선택
3. **에뮬레이터 설정**: `Tools` → `Device Manager` → `Create Device`
4. **앱 실행**: ▶️ Run 버튼 클릭

### Xcode (iOS)에서 실행하기

```bash
# iOS 설정 초기화
cd ios
pod install

# Xcode에서 열기
open Runner.xcworkspace
```

1. Xcode에서 `Runner.xcworkspace` 열기
2. 상단에서 시뮬레이터 선택 (예: iPhone 15 Pro)
3. ▶️ Run 버튼 클릭

### 터미널에서 바로 실행

```bash
# 연결된 기기 확인
flutter devices

# Android 실행
flutter run -d android

# iOS 실행
flutter run -d ios

# 웹 실행
flutter run -d chrome
```

---

## 🔌 API 서버 URL 설정

`lib/services/api_service.dart` 파일에서 환경에 맞게 수정:

```dart
// iOS 시뮬레이터
static const String baseUrl = 'http://localhost:3000/api';

// Android 에뮬레이터 (⚠️ localhost 대신 10.0.2.2 사용!)
static const String baseUrl = 'http://10.0.2.2:3000/api';

// 실제 기기 테스트 (컴퓨터 IP 주소)
static const String baseUrl = 'http://192.168.x.x:3000/api';
```

---

## 🛠 기술 스택

- Flutter 3.x
- Provider (상태 관리)
- HTTP (네트워크 통신)
- SharedPreferences (로컬 저장소)

---

## ⚠️ 문제 해결

| 문제                         | 해결 방법                               |
| ---------------------------- | --------------------------------------- |
| 서버가 안 켜져 있음          | 서버 프로젝트에서 `npm run dev` 실행    |
| 포트가 다름                  | baseUrl과 서버 PORT 확인                |
| Android 에뮬레이터 연결 안됨 | `localhost` → `10.0.2.2`로 변경         |
| CORS 오류                    | 서버에 `app.use(cors())` 확인           |
| 네트워크 오류                | 같은 Wi-Fi 연결 확인 (실기기 테스트 시) |

---

## 📝 개발 규칙

- 파일 이름: `snake_case.dart` (예: `user_profile.dart`)
- 클래스 이름: `PascalCase` (예: `UserProfile`)
- 변수 및 함수 이름: `camelCase` (예: `userName`, `getUserInfo()`)

---

## 📄 라이선스

MIT License
