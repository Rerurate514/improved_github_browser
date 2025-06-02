import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_browser/features/github_auth/components/signin_component.dart';
import 'package:github_browser/features/github_auth/providers/signin_state_provider.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Consumer(
            builder: (context, ref, child) {
              final signInState = ref.watch(signinStateProvider);
              
              return signInState.when(
                loading: () => const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stackTrace) => SignInComponent(
                  onSignIn: () => ref.read(signinStateProvider.notifier).signIn(),
                  errorMessage: error.toString(),
                ),
                data: (auth) => SignInComponent(
                  onSignIn: () => ref.read(signinStateProvider.notifier).signIn(),
                  errorMessage: auth.errorMessage,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
