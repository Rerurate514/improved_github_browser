import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_browser/features/github_auth/repositories/github_auth_repository.dart';

final githubAuthRepositoryProvider = Provider<GithubAuthRepository>((ref) {
  return GithubAuthRepository();
});
