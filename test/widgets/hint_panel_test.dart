import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangman_game/widgets/hint_panel.dart';

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('solicita a dica ao tocar no botão', (tester) async {
    int requested = 0;
    await tester.pumpWidget(
      _host(
        HintPanel(
          hint: null,
          isHintUsed: false,
          enabled: true,
          onRequestHint: () => requested++,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.lightbulb_outline));

    expect(requested, 1);
  });

  testWidgets('não solicita novamente quando a dica já foi usada', (
    tester,
  ) async {
    int requested = 0;
    await tester.pumpWidget(
      _host(
        HintPanel(
          hint: 'Uma pista',
          isHintUsed: true,
          enabled: true,
          onRequestHint: () => requested++,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.lightbulb_outline));

    expect(requested, 0);
  });

  testWidgets('não solicita quando desabilitado', (tester) async {
    int requested = 0;
    await tester.pumpWidget(
      _host(
        HintPanel(
          hint: null,
          isHintUsed: false,
          enabled: false,
          onRequestHint: () => requested++,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.lightbulb_outline));

    expect(requested, 0);
  });

  testWidgets('mostra a dica quando disponível', (tester) async {
    await tester.pumpWidget(
      _host(
        HintPanel(
          hint: 'Estrutura óssea que sustenta o tronco',
          isHintUsed: true,
          enabled: true,
          onRequestHint: () {},
        ),
      ),
    );

    expect(find.text('Estrutura óssea que sustenta o tronco'), findsOneWidget);
  });

  testWidgets('não mostra nada quando a dica é nula', (tester) async {
    await tester.pumpWidget(
      _host(
        HintPanel(
          hint: null,
          isHintUsed: false,
          enabled: true,
          onRequestHint: () {},
        ),
      ),
    );

    expect(find.byType(Text), findsNothing);
  });
}
