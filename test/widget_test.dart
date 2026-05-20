import 'package:flutter_test/flutter_test.dart';
import 'package:cognitap/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CogniTapApp());
    expect(find.byType(CogniTapApp), findsOneWidget);
  });
}