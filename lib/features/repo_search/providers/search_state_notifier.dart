import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_browser/features/repo_search/entities/repository.dart';
import 'package:github_browser/features/repo_search/providers/github_repository_provider.dart';

class SearchStateNotifier extends AutoDisposeNotifier<AsyncValue<List<Repository>>> {
  @override
  AsyncValue<List<Repository>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> searchRepositories(String query) async {
    state = const AsyncValue.loading();

    final repository = ref.read(githubRepositoryProvider);

    state = await AsyncValue.guard(() async {
      return repository.searchRepositories(query);
    });
  }
}
