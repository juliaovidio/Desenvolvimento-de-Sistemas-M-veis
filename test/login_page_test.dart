import 'package:app_mobile/src/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});

    await Supabase.initialize(
      url: 'https://bogymaxfgwvjbozwnybd.supabase.co',
      anonKey: 'sb_publishable_e3zyGGtObJiIG9v3-0RVFQ_LQXXu9ae',
    );
  });

  testWidgets('TC01 - Login com e-mail inválido mostra SnackBar', (tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginPage()));

    await tester.enterText(find.byType(TextField).at(0), 'usuarioemail.com');
    await tester.enterText(find.byType(TextField).at(1), '123456');

    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(
      find.text('❌ Por favor, insira um e-mail válido (deve conter @ e .)'),
      findsOneWidget,
    );
  });

  testWidgets('TC02 - Login com senha vazia mostra SnackBar', (tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginPage()));

    await tester.enterText(find.byType(TextField).at(0), 'teste@empresa.com');
    await tester.enterText(find.byType(TextField).at(1), '');

    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.text('❌ A senha não pode estar vazia'), findsOneWidget);
  });

  testWidgets('TC03 - Alternar visibilidade da senha', (tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginPage()));

    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();

    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });
}