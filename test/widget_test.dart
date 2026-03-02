import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:atr_book/main.dart';

void main() {
  testWidgets('แสดงชื่อแอปและตัวนับเริ่มต้น', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text(kAppName), findsOneWidget);
    expect(find.text('จำนวนโน้ตที่สร้างแล้ว:'), findsOneWidget);
    expect(find.byKey(const ValueKey('noteCounterText')), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('กดปุ่มเพิ่มโน้ตแล้วตัวนับเพิ่มขึ้น', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
    expect(find.byTooltip('เพิ่มโน้ต'), findsOneWidget);
  });
}
