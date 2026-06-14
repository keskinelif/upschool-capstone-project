import 'package:flutter_test/flutter_test.dart';

import 'package:gri_client/main.dart';

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GriApp());
    expect(find.text('gri.'), findsOneWidget);
  });
}
