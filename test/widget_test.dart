import 'package:flutter_test/flutter_test.dart';

import 'package:atr_book/main.dart';

void main() {
  testWidgets('แสดงชื่อแอปพร้อมจำนวนรายการฟีเจอร์ใน AppBar', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('$kAppName (${kFeatures.length})'), findsOneWidget);
  });

  testWidgets('เรนเดอร์รายการฟีเจอร์และเลื่อนดูรายการท้ายสุดได้', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text(kFeatures.first), findsOneWidget);

    await tester.dragUntilVisible(
      find.text(kFeatures.last),
      find.byType(Scrollable),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();

    expect(find.text(kFeatures.last), findsOneWidget);
  });
}
