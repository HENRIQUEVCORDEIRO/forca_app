import 'package:flutter_test/flutter_test.dart';

import 'package:hangman_game/domain/answer_category.dart';
import 'package:hangman_game/main.dart';
import 'package:hangman_game/screens/game_screen.dart';

void main() {
  testWidgets('home screen shows title and play button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ForcaApp());

    expect(find.text('HANGMAN'), findsOneWidget);
    expect(find.text('JOGAR'), findsOneWidget);

    await tester.tap(find.text('JOGAR'));
    await tester.pumpAndSettle();

    expect(find.byType(GameScreen), findsOneWidget);
    expect(find.text(AnswerCategory.animals.label), findsOneWidget);
    expect(find.text('_'), findsWidgets);

    await tester.tap(find.text(AnswerCategory.animals.label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AnswerCategory.technology.label).last);
    await tester.pumpAndSettle();

    expect(find.text(AnswerCategory.technology.label), findsOneWidget);
    expect(find.text('_'), findsWidgets);
  });
}
