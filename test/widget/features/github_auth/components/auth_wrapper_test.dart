import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_browser/features/github_auth/components/auth_wrapper.dart';
import 'package:github_browser/features/github_auth/entities/auth_result.dart';
import 'package:github_browser/features/github_auth/repositories/github_auth_repository.dart';
import 'package:github_browser/features/github_auth/repositories/secure_repository.dart';
import 'package:github_browser/l10n/app_localizations.dart';
import 'package:github_browser/pages/search_page.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([GithubAuthRepository, GithubSecureRepository])
import 'auth_wrapper_test.mocks.dart';

class TestApp extends StatelessWidget {
  final Widget child;

  const TestApp({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }
}

class MockSearchPage extends StatelessWidget {
  final String token;

  const MockSearchPage({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Page')),
      body: Center(child: Text('Authenticated with token: $token')),
    );
  }
}

void main() {
  late MockGithubAuthRepository mockAuthRepository;
  late MockGithubSecureRepository mockSecureRepository;

  setUp(() {
    mockAuthRepository = MockGithubAuthRepository();
    mockSecureRepository = MockGithubSecureRepository();
  });

  Widget createAuthWrapper() {
    return TestApp(
      child: AuthWrapper(
        authRepository: mockAuthRepository,
        secureRepository: mockSecureRepository,
      ),
    );
  }

  group('AuthWrapper Widget Tests', () {
    testWidgets('トークンがない場合はSignInPageを表示すること',
        (WidgetTester tester) async {

      when(mockSecureRepository.getToken()).thenAnswer((_) => Future.value(null));

      await tester.pumpWidget(createAuthWrapper());
      
      await tester.pumpAndSettle();

      expect(find.byType(SignInPage), findsOneWidget);
      expect(find.byIcon(Icons.login), findsOneWidget);
    });

    testWidgets('getTokenが例外をスローした場合はエラーメッセージを表示すること',
        (WidgetTester tester) async {
      when(mockSecureRepository.getToken())
          .thenAnswer((_) => Future.error('Failed to get token'));

      await tester.pumpWidget(createAuthWrapper());
      await tester.pumpAndSettle();

      expect(find.byType(SignInPage), findsOneWidget);
      expect(find.text('Failed to get token'), findsOneWidget);
    });

  testWidgets('ボタンが押されたときにサインインが成功すること', 
      (WidgetTester tester) async {
    when(mockSecureRepository.getToken()).thenAnswer((_) => Future.value(null));
    
    final completer = Completer<AuthResult>();
    when(mockAuthRepository.signIn()).thenAnswer((_) => completer.future);

    await tester.pumpWidget(createAuthWrapper());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.login));
    await tester.pump();
    
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    completer.complete(AuthResult.success('new_token'));
    await tester.pumpAndSettle();

    expect(find.byType(SearchPage), findsOneWidget);
  });

    testWidgets('サインインが失敗した場合はエラーメッセージを表示すること',
        (WidgetTester tester) async {
      when(mockSecureRepository.getToken()).thenAnswer((_) => Future.value(null));
      
      when(mockAuthRepository.signIn()).thenAnswer(
          (_) => Future.value(AuthResult.failure('Auth failed')));

      await tester.pumpWidget(createAuthWrapper());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.login));
      await tester.pumpAndSettle();

      expect(find.text('Auth failed'), findsOneWidget);
    });

    testWidgets('サインインが例外をスローした場合はエラーメッセージを表示すること',
        (WidgetTester tester) async {
      when(mockSecureRepository.getToken()).thenAnswer((_) => Future.value(null));
      
      when(mockAuthRepository.signIn())
          .thenAnswer((_) => Future.error('Network error'));

      await tester.pumpWidget(createAuthWrapper());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.login));
      await tester.pumpAndSettle();

      expect(find.text('Network error'), findsOneWidget);
    });
  });
}
