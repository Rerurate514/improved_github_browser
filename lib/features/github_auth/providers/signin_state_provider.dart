import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_browser/core/utils/check_network_connection.dart';
import 'package:github_browser/features/github_auth/entities/auth_result.dart';
import 'package:github_browser/features/github_auth/providers/github_auth_repository_provider.dart';
import 'package:github_browser/features/github_auth/providers/github_secure_repository_provider.dart';
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

  Future<void> signIn() async {
    state = const AsyncValue.loading();

    final bool isConnected = await checkNetworkConnection(
      ref: ref,
      isNotConnectedHandler: (context) {
        state = AsyncValue.error(
          context != null 
            ? AppLocalizations.of(context).error_network
            : 'Network error',
          StackTrace.current
        );
      }
    );

    if(!isConnected) return;
    
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
    
    final bool isConnected = await checkNetworkConnection(
      ref: ref,
      isNotConnectedHandler: (context) {
        state = AsyncValue.error(
          context != null 
            ? AppLocalizations.of(context).error_network
            : 'Network error',
          StackTrace.current
        );
      }
    );
    if(!isConnected) return;
    
    try {
      await ref.read(githubSecureRepositoryProvider).deleteToken();
      ref.read(apiTokenProvider.notifier).state = null;
      state = AsyncValue.data(AuthResult(isSuccess: false));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
