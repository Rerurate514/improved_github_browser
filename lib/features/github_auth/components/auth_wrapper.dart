import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_browser/features/github_auth/providers/auth_state_provider.dart';
import 'package:github_browser/pages/search_page.dart';
import 'package:github_browser/pages/signin_page.dart';

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
