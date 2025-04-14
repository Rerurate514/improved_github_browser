import 'package:flutter/material.dart';
import 'package:github_browser/features/auth_github/repositories/auth_repository.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  AuthWrapperState createState() => AuthWrapperState();
}

class AuthWrapperState extends State<AuthWrapper> {
  final GitHubAuthRepository _authRepository = GitHubAuthRepository();
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
      final token = await _authRepository.getToken();
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
      final result = await _authRepository.signIn(context);
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

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authRepository.deleteToken();
      setState(() {
        _authToken = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
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
      return HomePage(
        token: _authToken!,
        onSignOut: _signOut,
      );
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
              const Text(
                'アプリをご利用いただくには、GitHubアカウントでのサインインが必要です。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onSignIn,
                icon: const Icon(Icons.login),
                label: const Text('GitHubでサインイン'),
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

class HomePage extends StatelessWidget {
  final String token;
  final Future<void> Function() onSignOut;

  const HomePage({
    Key? key,
    required this.token,
    required this.onSignOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Browser'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: onSignOut,
            tooltip: 'サインアウト',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('認証済み - メイン画面'),
            const SizedBox(height: 16),
            Text('アクセストークン: ${token.substring(0, 10)}...', 
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
