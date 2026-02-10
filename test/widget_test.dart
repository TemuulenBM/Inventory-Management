/// MyApp widget smoke test
/// App зөв ачаалж, MaterialApp.router үүсч байгааг шалгана
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:retail_control_platform/main.dart';

void main() {
  testWidgets('MyApp smoke test - MaterialApp.router үүсэж байгааг шалгах',
      (WidgetTester tester) async {
    // ProviderScope-тай build хийх (main.dart дээрх шиг)
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // MaterialApp.router зөв ачаалсан эсэхийг шалгах
    expect(find.byType(MaterialApp), findsOneWidget);

    // SplashScreen-ийн 2 секундын Timer-ийг дуусгах
    // (initState → Future.delayed(Duration(seconds: 2)))
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
