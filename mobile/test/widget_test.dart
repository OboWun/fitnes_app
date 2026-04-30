import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/main.dart';

void main() {
  testWidgets('App starts with splash page', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(
        child: FitnessApp(),
      ),
    );

    expect(find.text('FitnessX'), findsOneWidget);
  });
}
