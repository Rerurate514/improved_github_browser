import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_browser/features/github_auth/entities/auth_result.dart';
import 'package:github_browser/features/github_auth/providers/github_auth_repository_provider.dart';
import 'package:github_browser/features/github_auth/providers/github_secure_repository_provider.dart';
import 'package:github_browser/features/repo_search/providers/api_token_provider.dart';

final authStateProvider = AsyncNotifierProvider<AuthNotifier, AuthResult>(() {
  return AuthNotifier();
});

class AuthNotifier extends AsyncNotifier<AuthResult> {
  @override
  Future<AuthResult> build() async {
    return _checkExistingAuth();
  }

  Future<AuthResult> _checkExistingAuth() async {
    try {
      final token = await ref.read(githubSecureRepositoryProvider).getToken();
      if (token != null && token.isNotEmpty && token != "") {

        return AuthResult(isSuccess: true, token: token);
      } else {
          state = AsyncValue.error(
            'Failed to get token', 
            StackTrace.current
          );
        return AuthResult(isSuccess: false);
      }
    } catch (e) {
      state = AsyncValue.error(
        'Failed to get token', 
        StackTrace.current
      );

      return AuthResult(isSuccess: false);
    }
  }

  Future<void> signIn() async {
    state = const AsyncValue.loading();
    
    try {
      final result = await ref.read(githubAuthRepositoryProvider).signIn();
      
      if (result.isSuccess) {
        state = AsyncValue.data(result);

        ref.read(apiTokenProvider.notifier).state = result.token;
      } else {
        state = AsyncValue.error(
          result.errorMessage ?? 'Failed to get token', 
          StackTrace.current
        );
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    
    try {
      await ref.read(githubSecureRepositoryProvider).deleteToken();
      ref.read(apiTokenProvider.notifier).state = null;
      state = AsyncValue.data(AuthResult(isSuccess: false));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
