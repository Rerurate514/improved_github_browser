import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_browser/features/repo_search/providers/api_token_provider.dart';
import 'package:github_browser/features/repo_search/repositories/github_repository.dart';

final githubRepositoryProvider = Provider<GitHubRepository>((ref) {
  final String? apiToken = ref.read(apiTokenProvider);
  final repository = GitHubRepository(apiToken: apiToken);
  
  ref.onDispose(() {
    repository.dispose();
  });
  
  return repository;
});
