import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:techstore_360/main.dart';

void main() {
  testWidgets('App arranca sin errores', (WidgetTester tester) async {
    // TechStore360App es la clase correcta definida en main.dart
    await tester.pumpWidget(const TechStore360App());

    // Verifica que el widget raíz renderiza
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}