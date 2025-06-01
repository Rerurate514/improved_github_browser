import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_browser/core/providers/navigator_key_provider.dart';
import 'package:github_browser/features/github_auth/components/signin_wrapper.dart';
import 'package:github_browser/features/github_auth/entities/auth_result.dart';
import 'package:github_browser/features/github_auth/providers/github_auth_repository_provider.dart';
import 'package:github_browser/features/github_auth/providers/github_secure_repository_provider.dart';
import 'package:github_browser/features/github_auth/providers/internet_connection_checker_provider.dart';
import 'package:github_browser/features/github_auth/providers/signin_state_provider.dart';
import 'package:github_browser/features/github_auth/repositories/github_auth_repository.dart';
import 'package:github_browser/features/github_auth/repositories/secure_repository.dart';
import 'package:github_browser/l10n/app_localizations.dart';
import 'package:github_browser/pages/search_page.dart';
import 'package:github_browser/pages/signin_page.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([GithubAuthRepository, GithubSecureRepository, InternetConnectionChecker])
import 'signin_wrapper_test.mocks.dart';

class TestAuthNotifier extends SignInNotifier {
  AuthResult _state = AuthResult(isSuccess: false);

  @override
  Future<AuthResult> build() => Future.value(_state);

  // ignore: use_setters_to_change_properties
  void setState(AuthResult newState) {
    _state = newState;
  }
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
  late MockInternetConnectionChecker mockInternetConnectionChecker;
  late TestAuthNotifier testAuthNotifier;
  late GlobalKey<NavigatorState> mockNavigatorKey;

  setUp(() {
    mockAuthRepository = MockGithubAuthRepository();
    mockSecureRepository = MockGithubSecureRepository();
    mockInternetConnectionChecker = MockInternetConnectionChecker();
    testAuthNotifier = TestAuthNotifier();
    mockNavigatorKey = GlobalKey<NavigatorState>();
  });

  Widget createAuthWrapper() {
    return TestApp(
      overrides: [
        signinStateProvider.overrideWith(() => testAuthNotifier),
        githubAuthRepositoryProvider.overrideWithValue(mockAuthRepository),
        internetConnectionCheckerProvider.overrideWith((_) => mockInternetConnectionChecker),
        githubSecureRepositoryProvider.overrideWithValue(mockSecureRepository),
        navigatorKeyProvider.overrideWith((_) => mockNavigatorKey),
      ],
      child: const SignInWrapper(),
    );
  }

  group('SignInWrapper', () {
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

    testWidgets('ネットワークエラーが起きた場合はエラーメッセージを表示すること', (WidgetTester tester) async {
      when(mockSecureRepository.getToken()).thenAnswer((_) => Future.value('valid_token'));
      when(mockInternetConnectionChecker.hasConnection).thenAnswer((_) => Future.value(false));

      await tester.pumpWidget(createAuthWrapper());
      await tester.pumpAndSettle();

      testAuthNotifier.signIn();
      await Future.microtask(() {});
      await tester.pumpAndSettle();

      expect(find.byType(SignInPage), findsOneWidget);
      expect(find.text('Network error'), findsOneWidget);
    });
  });
}
