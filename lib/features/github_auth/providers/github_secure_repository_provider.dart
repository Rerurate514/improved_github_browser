import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_browser/features/github_auth/repositories/secure_repository.dart';

final githubSecureRepositoryProvider = Provider<GithubSecureRepository>((ref) {
  return GithubSecureRepository();
});
