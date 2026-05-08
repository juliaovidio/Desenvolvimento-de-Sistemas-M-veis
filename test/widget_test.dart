import 'package:flutter_test/flutter_test.dart';

import 'package:app_mobile/main.dart';

void main() {
  testWidgets('App carrega tela de login', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Verifica se aparece "Entrar"
    expect(find.text('Entrar'), findsOneWidget);
  });
}