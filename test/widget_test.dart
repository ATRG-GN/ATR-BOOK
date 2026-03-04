import 'package:flutter_test/flutter_test.dart';

import 'package:atr_book/main.dart';

void main() {
  testWidgets('แสดงชื่อแอปพร้อมจำนวนรายการใน AppBar', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('$kAppName (${kFeatures.length})'), findsOneWidget);
  });

  testWidgets('แสดงรายการฟีเจอร์ครบถ้วนและเรียงเลขถูกต้อง', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(ListTile), findsNWidgets(kFeatures.length));
    expect(find.text(kFeatures.first), findsOneWidget);
    expect(find.text(kFeatures.last), findsOneWidget);

    // ตรวจสอบว่าหมายเลขลำดับแรกและสุดท้ายถูกแสดงบนหน้าจอ
    expect(find.widgetWithText(CircleAvatar, '1'), findsOneWidget);
    expect(
      find.widgetWithText(CircleAvatar, '${kFeatures.length}'),
      findsOneWidget,
    );
  });

  testWidgets('มีตัวคั่นระหว่างรายการตามจำนวนที่คาดหวัง', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(Divider), findsNWidgets(kFeatures.length - 1));
  });
}
