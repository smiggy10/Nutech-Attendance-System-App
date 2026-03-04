import 'package:flutter_test/flutter_test.dart';
import 'package:nutech_app/app.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    await tester.pumpWidget(const NutechApp());
    expect(find.byType(NutechApp), findsOneWidget);
  });
}