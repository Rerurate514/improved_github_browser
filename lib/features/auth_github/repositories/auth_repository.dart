import 'package:flutter/material.dart';
import 'package:github_browser/features/auth_github/entities/auth_resutl.dart';
import 'package:github_oauth/github_oauth.dart';
import 'package:github_browser/core/env/env.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GitHubAuthRepository {
  final GitHubSignIn _githubSignIn;
  final FlutterSecureStorage _secureStorage;
  static const String _tokenKey = 'github_auth_token';

  GitHubAuthRepository()
      : _githubSignIn = GitHubSignIn(
          clientId: Env.clientId,
          clientSecret: Env.clientSecret,
          redirectUrl: Env.redirectUrl,
        ),
        _secureStorage = const FlutterSecureStorage();

  Future<AuthResult> signIn(BuildContext context) async {
    final result = await _githubSignIn.signIn(context);

    if (result.status == GitHubSignInResultStatus.ok) {
      await saveToken(result.token!);
      return AuthResult.success(result.token!);
    } else {
      return AuthResult.failure(result.errorMessage ?? 'Unknown error');
    }
  }

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }
}
