import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_browser/features/repo_search/entities/repository.dart';
import 'package:github_browser/features/repo_search/providers/github_repository_provider.dart';

class SearchStateNotifier extends AutoDisposeNotifier<AsyncValue<List<Repository>>> {
  int _currentPageIndex = 0;
  String _currentQuery = '';
  bool _isLoadingMore = false;

  bool get isLoadingMore => _isLoadingMore;

  @override
  AsyncValue<List<Repository>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> searchRepositories(String query) async {
    state = const AsyncValue.loading();

    _resetState();
    _currentQuery = query.trim();

    final repository = ref.read(githubRepositoryProvider);

    state = await AsyncValue.guard(() async {
      return repository.searchRepositories(query);
    });
  }

  Future<void> loadMoreRepositories() async {
    _isLoadingMore = true;
    final nextPageIndex = _currentPageIndex + 1;

    try{
      final repository = ref.read(githubRepositoryProvider);
      final newResults = await repository.searchRepositories(
        _currentQuery,
        page: _currentPageIndex
      );

      final currentResults = state.value ?? [];
      final combinedResults = [...currentResults, ...newResults];

      _currentPageIndex = nextPageIndex;

      state = AsyncValue.data(combinedResults);
    } catch(e) {
      log("loading failed: $e");
    } finally {
      _isLoadingMore = false;
    }
  }

  void _resetState() {
    _currentPageIndex = 0;
    _currentQuery = '';
    _isLoadingMore = false;
  }
}
