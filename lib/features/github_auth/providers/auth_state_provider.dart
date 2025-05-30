import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_browser/features/github_auth/entities/auth_result.dart';
import 'package:github_browser/features/github_auth/repositories/github_auth_repository.dart';
import 'package:github_browser/features/github_auth/repositories/secure_repository.dart';
import 'package:github_browser/features/repo_search/providers/api_token_provider.dart';

final authStateProvider = AsyncNotifierProvider<AuthNotifier, AuthResult>(() {
  return AuthNotifier();
});

class AuthNotifier extends AsyncNotifier<AuthResult> {
  late GithubAuthRepository _authRepository;
  late GithubSecureRepository _secureRepository;

  @override
  Future<AuthResult> build() async {
    _authRepository = GithubAuthRepository();
    _secureRepository = GithubSecureRepository();
    
    return _checkExistingAuth();
  }

  Future<AuthResult> _checkExistingAuth() async {
    try {
      final token = await _secureRepository.getToken();
      if (token != null && token.isNotEmpty) {
        return AuthResult(isSuccess: true, token: token);
      } else {
        return AuthResult(isSuccess: false);
      }
    } catch (e) {
      throw Exception('Failed to check existing auth: $e');
    }
  }

  Future<void> signIn() async {
    state = const AsyncValue.loading();
    
    try {
      final result = await _authRepository.signIn();
      
      if (result.isSuccess) {
        state = AsyncValue.data(result);

        ref.read(apiTokenProvider.notifier).state = result.token;
      } else {
        state = AsyncValue.error(
          result.errorMessage ?? 'Sign in failed', 
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
      await _secureRepository.deleteToken();
      ref.read(apiTokenProvider.notifier).state = null;
      state = AsyncValue.data(AuthResult(isSuccess: false));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
