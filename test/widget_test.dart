import 'package:flutter_test/flutter_test.dart';

import 'package:atr_book/main.dart';

void main() {
  testWidgets('แสดงชื่อแอปพร้อมจำนวนรายการใน AppBar', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('$kAppName (${kFeatures.length})'), findsOneWidget);
  });

  testWidgets('แสดงรายการฟีเจอร์จากข้อมูล backlog ได้', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text(kFeatures.first), findsOneWidget);
    expect(find.text(kFeatures[1]), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });
}
