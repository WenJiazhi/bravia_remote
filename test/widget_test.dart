import 'package:flutter_test/flutter_test.dart';

import 'package:bravia_remote/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const BraviaRemoteApp());

    // Verify the app title appears
    expect(find.text('Bravia Remote'), findsOneWidget);
    expect(find.text('Control your Sony TV'), findsOneWidget);
  });
}
