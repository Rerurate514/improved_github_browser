import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_browser/features/github_auth/providers/signin_state_provider.dart';
import 'package:github_browser/pages/search_page.dart';
import 'package:github_browser/pages/signin_page.dart';

class SignInWrapper extends ConsumerWidget {
  const SignInWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signInState = ref.watch(signinStateProvider);

    return signInState.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => SignInPage(
        onSignIn: () => ref.read(signinStateProvider.notifier).signIn(),
        errorMessage: error.toString(),
      ),
      data: (auth) {
        if (auth.isSuccess) {
          return const SearchPage();
        } else {
          return SignInPage(
            onSignIn: () => ref.read(signinStateProvider.notifier).signIn(),
            errorMessage: auth.errorMessage,
          );
        }
      },
    );
  }
}
