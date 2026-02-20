// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:ets_movil_app/app/app.dart';

void main() {
  testWidgets('La app arranca con la pantalla de inicio de fase 0', (WidgetTester tester) async {
    await tester.pumpWidget(const EtsMovilApp());
    expect(find.text('ETS Movil'), findsOneWidget);
    expect(find.text('Esqueleto de la Fase 0'), findsOneWidget);
  });
}
