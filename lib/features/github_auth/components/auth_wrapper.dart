import 'package:flutter/material.dart';
import 'package:github_browser/l10n/app_localizations.dart';
import 'package:github_browser/pages/search_page.dart';

import '../repositories/github_auth_repository.dart';
import '../repositories/secure_repository.dart';

class AuthWrapper extends StatefulWidget {
  final GithubAuthRepository authRepository;
  final GithubSecureRepository secureRepository;

  AuthWrapper({
    super.key,
    GithubAuthRepository? authRepository,
    GithubSecureRepository? secureRepository,
  }) : 
    authRepository = authRepository ?? GithubAuthRepository(),
    secureRepository = secureRepository ?? GithubSecureRepository();

  @override
  AuthWrapperState createState() => AuthWrapperState();
}

class AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  String? _authToken;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final token = await widget.secureRepository.getToken();
      setState(() {
        _authToken = token;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await widget.authRepository.signIn();
      
      setState(() {
        _isLoading = false;
        if (result.isSuccess) {
          _authToken = result.token;
        } else {
          _errorMessage = result.errorMessage;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_authToken != null) {
      return SearchPage(token: _authToken!);
    }

    return SignInPage(
      onSignIn: _signIn,
      errorMessage: _errorMessage,
    );
  }
}

class SignInPage extends StatelessWidget {
  final Future<void> Function() onSignIn;
  final String? errorMessage;

  const SignInPage({
    super.key,
    required this.onSignIn,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.code,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'GitHub Browser',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).auth_wrapper_app_use_explain,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onSignIn,
                icon: const Icon(Icons.login),
                label: Text(AppLocalizations.of(context).appTitle),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  minimumSize: const Size(200, 0),
                ),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 24),
                Text(
                  errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
