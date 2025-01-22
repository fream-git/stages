import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:stages/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Test', () {
    testWidgets('App startet und Navigation funktioniert',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Überprüfen ob die App startet
      expect(find.text('Stages'), findsOneWidget);
      expect(find.text('Willkommen bei Stages'), findsOneWidget);
    });
  });
} 