import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_browser/core/routes/app_routes.dart';
import 'package:github_browser/core/routes/router.dart';
import 'package:github_browser/features/github_auth/entities/auth_result.dart';
import 'package:github_browser/features/github_auth/providers/signin_state_notifier.dart';
import 'package:github_browser/features/github_auth/providers/signin_state_provider.dart';
import 'package:github_browser/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class MockSignInNotifier extends SignInNotifier {
  final AuthResult _authResult;
  final bool _shouldThrowError;
  
  MockSignInNotifier(this._authResult, {bool shouldThrowError = false}) 
      : _shouldThrowError = shouldThrowError;

  @override
  Future<AuthResult> build() async {
    if (_shouldThrowError) {
      throw Exception('Mock error');
    }
    return _authResult;
  }
}

class _DelayedSignInNotifier extends SignInNotifier {
  @override
  Future<AuthResult> build() async {
    await Future<void>.delayed(const Duration(hours: 1));
    return AuthResult(isSuccess: false);
  }
}

class TestRef implements Ref {
  final ProviderContainer _container;
  
  TestRef(this._container);
  
  @override
  T watch<T>(ProviderListenable<T> provider) {
    return _container.read(provider);
  }
  
  @override
  T read<T>(ProviderListenable<T> provider) {
    return _container.read(provider);
  }
  
  @override
  void invalidate(ProviderOrFamily provider) {
    _container.invalidate(provider);
  }
  
  @override
  ProviderSubscription<T> listen<T>(
    ProviderListenable<T> provider,
    void Function(T? previous, T next) listener, {
    bool fireImmediately = false,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    return _container.listen(
      provider,
      listener,
      fireImmediately: fireImmediately,
      onError: onError,
    );
  }
  
  @override
  T refresh<T>(Refreshable<T> provider) {
    return _container.refresh(provider);
  }
  
  @override
  bool exists(ProviderBase<Object?> provider) {
    return _container.exists(provider);
  }
  
  @override
  void onDispose(void Function() callback) {}
  
  @override
  ProviderContainer get container => throw UnimplementedError();
  
  @override
  void invalidateSelf() { }
  
  @override
  KeepAliveLink keepAlive() {
    throw UnimplementedError();
  }
  
  @override
  void listenSelf(void Function(Object? previous, Object? next) listener, {void Function(Object error, StackTrace stackTrace)? onError}) { }
  
  @override
  void notifyListeners() { }
  
  @override
  void onAddListener(void Function() cb) { }
  
  @override
  void onCancel(void Function() cb) { }
  
  @override
  void onRemoveListener(void Function() cb) { }
  
  @override
  void onResume(void Function() cb) { }
}

class TestApp extends StatelessWidget {
  final GoRouter router;
  final List<Override> overrides;

  const TestApp({
    super.key, 
    required this.router, 
    this.overrides = const []
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
  }
}

void main() {
  group('createGoRouter', () {
    late GlobalKey<NavigatorState> navigatorKey;
    late ProviderContainer container;
    late TestRef testRef;

    setUp(() {
      navigatorKey = GlobalKey<NavigatorState>();
    });

    tearDown(() {
      container.dispose();
    });

    group('Redirect Logic', () {
      testWidgets('エラー状態でサインインページ以外にいる場合、サインインページにリダイレクトすること', (tester) async {
        container = ProviderContainer(
          overrides: [
            signinStateProvider.overrideWith(() => MockSignInNotifier(
              AuthResult(isSuccess: false), 
              shouldThrowError: true
            )),
          ],
        );
        testRef = TestRef(container);

        final router = createGoRouter(navigatorKey, testRef);
        
        await tester.pumpWidget(
          TestApp(
            router: router,
            overrides: [
              signinStateProvider.overrideWith(() => MockSignInNotifier(
                AuthResult(isSuccess: false), 
                shouldThrowError: true
              )),
            ],
          ),
        );

        router.go(AppRoutes.searchPage.path);
        await tester.pumpAndSettle();

        expect(router.routerDelegate.currentConfiguration.uri.path, equals(AppRoutes.signInPage.path));
      });

      testWidgets('認証成功時、サインインページから検索ページにリダイレクトすること', (tester) async {
        final mockAuthState = AuthResult(isSuccess: true, token: 'token');
        
        container = ProviderContainer(
          overrides: [
            signinStateProvider.overrideWith(() => MockSignInNotifier(mockAuthState)),
          ],
        );
        testRef = TestRef(container);

        final router = createGoRouter(navigatorKey, testRef);
        
        await tester.pumpWidget(
          TestApp(
            router: router,
            overrides: [
              signinStateProvider.overrideWith(() => MockSignInNotifier(mockAuthState)),
            ],
          ),
        );

        router.go(AppRoutes.signInPage.path);
        await tester.pump();
        await tester.pumpAndSettle();

        expect(router.routerDelegate.currentConfiguration.uri.path, equals(AppRoutes.searchPage.path));
      });

      testWidgets('認証済みで検索ページにいる場合、リダイレクトしないこと', (tester) async {
        final mockAuthState = AuthResult(isSuccess: true, token: 'token');
        
        container = ProviderContainer(
          overrides: [
            signinStateProvider.overrideWith(() => MockSignInNotifier(mockAuthState)),
          ],
        );
        testRef = TestRef(container);

        final router = createGoRouter(navigatorKey, testRef);
        
        await tester.pumpWidget(
          TestApp(
            router: router,
            overrides: [
              signinStateProvider.overrideWith(() => MockSignInNotifier(mockAuthState)),
            ],
          ),
        );

        router.go(AppRoutes.searchPage.path);
        await tester.pumpAndSettle();

        expect(router.routerDelegate.currentConfiguration.uri.path, equals(AppRoutes.searchPage.path));
      });
    });

    group('Route Configuration', () {
      testWidgets('初期ページが正しく設定されていること', (tester) async {
        container = ProviderContainer(
          overrides: [
            signinStateProvider.overrideWith(() => _DelayedSignInNotifier()),
          ],
        );
        testRef = TestRef(container);

        final router = createGoRouter(navigatorKey, testRef);
        expect(router.configuration.routes.length, equals(5));
      });

      testWidgets('すべてのルートが正しく定義されていること', (tester) async {
        container = ProviderContainer(
          overrides: [
            signinStateProvider.overrideWith(() => _DelayedSignInNotifier()),
          ],
        );
        testRef = TestRef(container);

        final router = createGoRouter(navigatorKey, testRef);
        final routes = router.configuration.routes.cast<GoRoute>();

        expect(routes.any((route) => route.path == AppRoutes.initialPage.path), isTrue);
        expect(routes.any((route) => route.path == AppRoutes.signInPage.path), isTrue);
        expect(routes.any((route) => route.path == AppRoutes.searchPage.path), isTrue);
        expect(routes.any((route) => route.path == AppRoutes.detailPage.path), isTrue);
        expect(routes.any((route) => route.path == AppRoutes.settingsPage.path), isTrue);
      });
    });
  });
}
