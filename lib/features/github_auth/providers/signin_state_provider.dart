import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_browser/core/providers/navigator_key_provider.dart';
import 'package:github_browser/features/github_auth/entities/auth_result.dart';
import 'package:github_browser/features/github_auth/providers/github_auth_repository_provider.dart';
import 'package:github_browser/features/github_auth/providers/github_secure_repository_provider.dart';
import 'package:github_browser/features/github_auth/providers/internet_connection_checker_provider.dart';
import 'package:github_browser/features/repo_search/providers/api_token_provider.dart';
import 'package:github_browser/l10n/app_localizations.dart';

final signinStateProvider = AsyncNotifierProvider<SignInNotifier, AuthResult>(() {
  return SignInNotifier();
});

class SignInNotifier extends AsyncNotifier<AuthResult> {
  @override
  Future<AuthResult> build() async {
    return _checkExistingAuth();
  }

  Future<AuthResult> _checkExistingAuth() async {
    try {
      final token = await ref.read(githubSecureRepositoryProvider).getToken();
      if (token != null && token.isNotEmpty) {
        return AuthResult(isSuccess: true, token: token);
      } else {
        return AuthResult(isSuccess: false);
      }
    } catch (e) {
      return AuthResult(isSuccess: false, errorMessage: e.toString());
    }
  }

  Future<bool> _checkNetworkConnection() async {
    final checker = ref.read(internetConnectionCheckerProvider);
    final bool isConnected = await checker.hasConnection;

    if (!isConnected) {
      final navigatorKey = ref.read(navigatorKeyProvider);
      final context = navigatorKey.currentContext;
      
      state = AsyncValue.error(
        context != null 
          // ignore: use_build_context_synchronously
          ? AppLocalizations.of(context).error_network
          : 'Network error',
        StackTrace.current
      );
    }

    return isConnected;
  }

  Future<void> signIn() async {
    final bool isConnected = await _checkNetworkConnection();
    if(!isConnected) return;

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
    final bool isConnected = await _checkNetworkConnection();
    if(!isConnected) return;
    
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
