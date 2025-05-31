import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_browser/features/github_auth/components/auth_wrapper.dart';
import 'package:github_browser/features/github_auth/entities/auth_result.dart';
import 'package:github_browser/features/github_auth/providers/auth_state_provider.dart';
import 'package:github_browser/features/github_auth/providers/github_auth_repository_provider.dart';
import 'package:github_browser/features/github_auth/providers/github_secure_repository_provider.dart';
import 'package:github_browser/features/github_auth/repositories/github_auth_repository.dart';
import 'package:github_browser/features/github_auth/repositories/secure_repository.dart';
import 'package:github_browser/l10n/app_localizations.dart';
import 'package:github_browser/pages/search_page.dart';
import 'package:github_browser/pages/signin_page.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([GithubAuthRepository, GithubSecureRepository])
import 'auth_wrapper_test.mocks.dart';

class TestAuthNotifier extends AuthNotifier {
  AuthResult _state = AuthResult(isSuccess: false);

  @override
  Future<AuthResult> build() => Future.value(_state);

  // ignore: use_setters_to_change_properties
  void setState(AuthResult newState) {
    _state = newState;
  }

  @override
  Future<void> signIn() async {}
}

class TestApp extends StatelessWidget {
  final Widget child;
  final List<Override> overrides;

  const TestApp({super.key, required this.child, this.overrides = const []});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }
}

void main() {
  late MockGithubAuthRepository mockAuthRepository;
  late MockGithubSecureRepository mockSecureRepository;
  late TestAuthNotifier testAuthNotifier;

  setUp(() {
    mockAuthRepository = MockGithubAuthRepository();
    mockSecureRepository = MockGithubSecureRepository();
    testAuthNotifier = TestAuthNotifier();
  });

  Widget createAuthWrapper() {
    return TestApp(
      overrides: [
        authStateProvider.overrideWith(() => testAuthNotifier),
        githubAuthRepositoryProvider.overrideWithValue(mockAuthRepository),
        githubSecureRepositoryProvider.overrideWithValue(mockSecureRepository),
      ],
      child: const AuthWrapper(),
    );
  }

  group('AuthWrapper Widget Tests', () {
    testWidgets('トークンがない場合はSignInPageを表示すること', (WidgetTester tester) async {
      when(mockSecureRepository.getToken()).thenAnswer((_) => Future.value());

      testAuthNotifier.setState(AuthResult(isSuccess: false));

      await tester.pumpWidget(createAuthWrapper());
      await tester.pumpAndSettle();

      expect(find.byType(SignInPage), findsOneWidget);
      expect(find.byIcon(Icons.login), findsOneWidget);
    });

    testWidgets('getTokenが例外をスローした場合はエラーメッセージを表示すること', (WidgetTester tester) async {
      when(mockSecureRepository.getToken()).thenThrow(Exception());

      testAuthNotifier.setState(AuthResult(isSuccess: false, errorMessage: "Failed to get token"));

      await tester.pumpWidget(createAuthWrapper());
      await tester.pumpAndSettle();

      expect(find.byType(SignInPage), findsOneWidget);
      expect(find.text('Failed to get token'), findsOneWidget);
    });

    testWidgets('ボタンが押されたときにサインインが成功すること', (WidgetTester tester) async {
      when(mockSecureRepository.getToken()).thenAnswer((_) => Future.value());

      testAuthNotifier.setState(AuthResult(isSuccess: true));

      await tester.pumpWidget(createAuthWrapper());
      await tester.pumpAndSettle();

      testAuthNotifier.setState(AuthResult(isSuccess: true));
      await tester.pump();

      testAuthNotifier.setState(AuthResult(isSuccess: true, token: 'new_token'));
      await tester.pumpAndSettle();

      expect(find.byType(SearchPage), findsOneWidget);
    });

    testWidgets('サインインが失敗した場合はエラーメッセージを表示すること', (WidgetTester tester) async {
      when(mockAuthRepository.signIn()).thenThrow(Exception());
      testAuthNotifier.setState(AuthResult(isSuccess: false, errorMessage: "Auth failed"));

      await tester.pumpWidget(createAuthWrapper());
      await tester.pumpAndSettle();

      expect(find.byType(SignInPage), findsOneWidget);
      expect(find.text('Auth failed'), findsOneWidget);
    });

    testWidgets('有効なトークンがある場合はSearchPageを表示すること', (WidgetTester tester) async {
      when(mockSecureRepository.getToken()).thenAnswer((_) => Future.value('valid_token'));

      testAuthNotifier.setState(AuthResult(isSuccess: true, token: 'valid_token'));

      await tester.pumpWidget(createAuthWrapper());
      await tester.pumpAndSettle();

      expect(find.byType(SearchPage), findsOneWidget);
    });
  });
}
