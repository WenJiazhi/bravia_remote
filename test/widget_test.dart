import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bravia_remote/main.dart';
import 'package:bravia_remote/services/app_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App launches successfully', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'locale': 'en',
      'theme_mode': 'light',
    });

    final appSettings = AppSettings();
    await appSettings.loadSettings();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appSettings,
        child: const BraviaRemoteApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify the app title appears (AppBar title and body title = 2 instances)
    expect(find.text('Bravia Remote'), findsNWidgets(2));
    expect(find.text('Tap to connect to your Sony TV'), findsOneWidget);
  });
}
