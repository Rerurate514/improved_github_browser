import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_browser/features/github_auth/providers/auth_state_provider.dart';
import 'package:github_browser/l10n/app_localizations.dart';
import 'package:github_browser/pages/search_page.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => SignInPage(
        onSignIn: () => ref.read(authStateProvider.notifier).signIn(),
        errorMessage: error.toString(),
      ),
      data: (auth) {
        if (auth.isSuccess) {
          return const SearchPage();
        } else {
          return SignInPage(
            onSignIn: () => ref.read(authStateProvider.notifier).signIn(),
            errorMessage: auth.errorMessage,
          );
        }
      },
    );
  }
}

class SignInPage extends StatelessWidget {
  final VoidCallback onSignIn;
  final String? errorMessage;

  const SignInPage({
    super.key,
    required this.onSignIn,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

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
                appLocalizations.auth_wrapper_app_use_explain,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onSignIn,
                icon: const Icon(Icons.login),
                label: Text(appLocalizations.appTitle),
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
