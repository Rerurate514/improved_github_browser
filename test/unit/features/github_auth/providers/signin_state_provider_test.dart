import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_browser/features/github_auth/entities/auth_result.dart';
import 'package:github_browser/features/github_auth/providers/github_auth_repository_provider.dart';
import 'package:github_browser/features/github_auth/providers/github_secure_repository_provider.dart';
import 'package:github_browser/features/github_auth/providers/signin_state_provider.dart';
import 'package:github_browser/features/github_auth/repositories/github_auth_repository.dart';
import 'package:github_browser/features/github_auth/repositories/secure_repository.dart';
import 'package:github_browser/features/repo_search/providers/api_token_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([GithubAuthRepository, GithubSecureRepository])
import 'signin_state_provider_test.mocks.dart';

void main() {
  late MockGithubAuthRepository mockGithubAuthRepository;
  late MockGithubSecureRepository mockGithubSecureRepository;
  late ProviderContainer container;

  setUp(() {
    mockGithubAuthRepository = MockGithubAuthRepository();
    mockGithubSecureRepository = MockGithubSecureRepository();

    container = ProviderContainer(
      overrides: [
        githubAuthRepositoryProvider.overrideWith((_) => mockGithubAuthRepository),
        githubSecureRepositoryProvider.overrideWith((_) => mockGithubSecureRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test("既存のトークンが存在していて、有効な場合にトークンを取得できる", () async {
    when(mockGithubSecureRepository.getToken()).thenAnswer((_) => Future.value("test_token"));

    await container.read(signinStateProvider.future);

    final state = container.read(signinStateProvider);
    expect(state, isA<AsyncValue<AuthResult>>());
    expect(state.value?.isSuccess, true);
    expect(state.value?.token, 'test_token');
  });

  test("既存のトークンが存在しない、または空文字列の場合にエラーを吐く", () async {
    when(mockGithubSecureRepository.getToken()).thenAnswer((_) => Future.value());

    final state = await container.read(signinStateProvider.future);
    expectLater(state.isSuccess, false);
  });

  test("トークンの取得中にエラーが発生した場合にAuthResultにエラー情報が含まれる", () async {
    when(mockGithubSecureRepository.getToken()).thenThrow(Exception("Test error during token fetch"));

    final authResult = await container.read(signinStateProvider.future);

    expect(authResult.isSuccess, false);
    expect(authResult.errorMessage, isNotNull);
    expect(authResult.errorMessage, contains('Exception: Test error during token fetch'));

    final state = container.read(signinStateProvider);
    expect(state, isA<AsyncData<AuthResult>>());
    expect(state.hasError, false);
    expect(state.value?.isSuccess, false);
    expect(state.value?.errorMessage, isNotNull);
    expect(state.value?.errorMessage, contains('Exception: Test error during token fetch'));
  });

  test("サインインに成功した場合にAuthResult.successが返される", () async {
    when(mockGithubAuthRepository.signIn()).thenAnswer((_) => 
      Future.value(AuthResult.success("test_token"))
    );

    await container.read(signinStateProvider.future);
    await container.read(signinStateProvider.notifier).signIn();

    final state = container.read(signinStateProvider);
    expect(state, isA<AsyncData<AuthResult>>());
    expect(state.hasError, false);
    expect(state.value?.isSuccess, true);
    expect(state.value?.token, "test_token");
    expect(state.value?.errorMessage, isNull);
  });

  test("サインインに失敗した場合にAuthResult.failureが返される", () async {
    when(mockGithubAuthRepository.signIn()).thenAnswer((_) => 
      Future.value(AuthResult.failure("Failed to get token"))
    );

    await container.read(signinStateProvider.future);
    await container.read(signinStateProvider.notifier).signIn();
    await Future.microtask(() {});

    final state = container.read(signinStateProvider);
    expect(state, isA<AsyncError<AuthResult>>());
    expect(state.hasError, true);
    expect(state.value?.isSuccess, false);
    expect(state.value?.token, isNull);
    expect(state.error.toString(), contains("Failed to get token"));
    expect(state.error, isA<String>());
  });

  test("サインイン処理中に例外がスローされた場合にAuthResult.failureが返される", () async {
    final ex = Exception("network error");
    when(mockGithubSecureRepository.getToken()).thenAnswer((_) => Future.value());
    when(mockGithubAuthRepository.signIn()).thenThrow(ex);

    await container.read(signinStateProvider.future);
    await container.read(signinStateProvider.notifier).signIn();

    final state = container.read(signinStateProvider);
    expect(state, isA<AsyncError<AuthResult>>());
    expect(state.hasError, true);
    expect(state.error, ex);
    expect(state.stackTrace, isNotNull);
  });

  test("サインアウト時にtokenの削除に成功する", () async {
    when(mockGithubSecureRepository.deleteToken()).thenAnswer((_) => Future.value());

    await container.read(signinStateProvider.future);
    await container.read(signinStateProvider.notifier).signOut();

    final state = container.read(signinStateProvider);
    expect(state, isA<AsyncData<AuthResult>>());

    final token = container.read(apiTokenProvider);
    expect(token, isNull);
  });

  test("サインアウト時に例外がスローされた場合にAsyncErrorになる", () async {
    final ex = Exception("network error");
    when(mockGithubSecureRepository.deleteToken()).thenThrow(ex);

    await container.read(signinStateProvider.future);
    await container.read(signinStateProvider.notifier).signOut();

    final state = container.read(signinStateProvider);
    expect(state, isA<AsyncError<AuthResult>>());
    expect(state.hasError, true);
    expect(state.error, ex);
    expect(state.stackTrace, isNotNull);
  });
}
