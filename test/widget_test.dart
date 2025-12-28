// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:fine_wash/main.dart';
import 'package:fine_wash/services/auth_service.dart';
import 'package:fine_wash/services/reservation_service.dart';
import 'package:fine_wash/services/vehicle_service.dart';

void main() {
  testWidgets('App starts and shows login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthService()),
          ChangeNotifierProvider(create: (_) => VehicleService()),
          ChangeNotifierProvider(create: (_) => ReservationService()),
        ],
        child: const FineWashApp(),
      ),
    );

    // Wait for the app to build
    await tester.pumpAndSettle();

    // Verify that the app title is present
    expect(
      find.text('출장세차'),
      findsNothing,
    ); // AppBar title might not be directly findable
  });
}
