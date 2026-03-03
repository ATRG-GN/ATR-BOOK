import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:atr_book/main.dart';

void main() {
  testWidgets('แสดงชื่อแอปและจำนวนรายการใน AppBar', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('$kAppName (${kFeatures.length})'), findsOneWidget);
  });

  testWidgets('แสดงรายการฟีเจอร์สำคัญได้ถูกต้อง', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(ListTile), findsNWidgets(kFeatures.length));
    expect(find.text(kFeatures.first), findsOneWidget);
    expect(find.text(kFeatures.last), findsOneWidget);
  });

  testWidgets('เลื่อนหน้าจอแล้วพบรายการลำดับถัดไป', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    final secondItemText = kFeatures[1];
    expect(find.text(secondItemText), findsNothing);

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(find.text(secondItemText), findsOneWidget);
  });
}
