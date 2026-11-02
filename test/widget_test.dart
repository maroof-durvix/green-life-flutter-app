
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:green_life/main.dart';
import 'package:green_life/controllers/app_controller.dart';

void main() {
  testWidgets('GreenLife app renders without errors', (WidgetTester tester) async {
    // Build the app wrapped in its required Provider
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppController(),
        child: const GreenLifeApp(),
      ),
    );

    // Verify the GreenLife app title text is present
    expect(find.text('GreenLife'), findsWidgets);
  });
}
