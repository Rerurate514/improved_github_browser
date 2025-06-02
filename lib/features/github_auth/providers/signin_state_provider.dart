import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_browser/features/github_auth/entities/auth_result.dart';
import 'package:github_browser/features/github_auth/providers/signin_state_notifier.dart';

final signinStateProvider = AsyncNotifierProvider<SignInNotifier, AuthResult>(() {
  return SignInNotifier();
});
