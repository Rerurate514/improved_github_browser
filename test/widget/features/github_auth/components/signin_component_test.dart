import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_browser/features/github_auth/components/signin_component.dart';
import 'package:github_browser/l10n/app_localizations.dart';

void main() {
  group('SignInComponent', () {
    Future<void> pumpSignInComponent(
      WidgetTester tester, {
      required VoidCallback onSignIn,
      String? errorMessage,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SignInComponent(
            onSignIn: onSignIn,
            errorMessage: errorMessage,
          ),
        ),
      );
    }

    testWidgets('ウィジェットの主要な要素が表示されること', (WidgetTester tester) async {
      await pumpSignInComponent(tester, onSignIn: () {});

      expect(find.byIcon(Icons.code), findsOneWidget);
      expect(find.text('GitHub Browser'), findsNWidgets(2));
    });

    testWidgets('onSignInが呼び出されること', (WidgetTester tester) async {
      bool signInCalled = false;
      await pumpSignInComponent(tester, onSignIn: () {
        signInCalled = true;
      });

      await tester.tap(find.byIcon(Icons.login));
      await tester.pumpAndSettle();

      expect(signInCalled, isTrue);
    });

    testWidgets('エラーメッセージが表示されること', (WidgetTester tester) async {
      const String testErrorMessage = 'サインインに失敗しました。';
      await pumpSignInComponent(tester, onSignIn: () {}, errorMessage: testErrorMessage);

      expect(find.text(testErrorMessage), findsOneWidget);
      expect(find.byKey(const Key('error_message_text')), findsNothing);
    });

    testWidgets('アプリの説明テキストが正しいこと', (WidgetTester tester) async {
      await pumpSignInComponent(tester, onSignIn: () {});

      final AppLocalizations appLocalizations = await AppLocalizations.delegate.load(const Locale('en'));
      expect(find.text(appLocalizations.auth_wrapper_app_use_explain), findsOneWidget);
    });
  });
}
