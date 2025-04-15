import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_browser/core/components/search_field.dart';

void main() {
  group('SearchField Widget Tests', () {
    testWidgets('検索フィールドが正しくレンダリングされること', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchField(
              onSearch: (_) {},
              hint: 'リポジトリを検索',
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);
      expect(find.text('リポジトリを検索'), findsOneWidget);
    });

    testWidgets('テキスト入力時にonSearchが呼ばれること', (WidgetTester tester) async {
      String searchedText = '';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchField(
              onSearch: (text) {
                searchedText = text;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'flutter');
      await tester.pump();

      expect(searchedText, 'flutter');
    });

    testWidgets('クリアボタンをタップするとテキストがクリアされること', (WidgetTester tester) async {
      String searchedText = '';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchField(
              onSearch: (text) {
                searchedText = text;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'flutter');
      await tester.pump();
      expect(searchedText, 'flutter');

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(find.text('flutter'), findsNothing);
      expect(searchedText, '');
    });

    testWidgets('検索ボタンを押したときにonSearchが呼ばれること', (WidgetTester tester) async {
      String searchedText = '';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchField(
              onSearch: (text) {
                searchedText = text;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'flutter');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      expect(searchedText, 'flutter');
    });

    testWidgets('コントローラーが正常に動作すること', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchField(
              onSearch: (_) {},
            ),
          ),
        ),
      );

      final TextField textField = tester.widget<TextField>(find.byType(TextField));
      final TextEditingController controller = textField.controller!;

      await tester.enterText(find.byType(TextField), 'flutter');
      await tester.pump();

      expect(controller.text, 'flutter');
    });

    testWidgets('デフォルトのヒントテキストが表示されること', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchField(
              onSearch: (_) {},

            ),
          ),
        ),
      );

      expect(find.text('検索'), findsOneWidget);
    });
  });
}
