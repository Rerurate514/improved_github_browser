import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_browser/features/repo_search/entities/repository.dart';
import 'package:github_browser/features/repo_search/providers/github_repository_provider.dart';

class SearchStateNotifier extends AutoDisposeNotifier<AsyncValue<List<Repository>>> {
  static const int _perPage = 10;

  //githubAPIはpageクエリに指定したパラメータの0以下は全て{?page=1}として扱うので初期値を1に設定
  int _currentPageIndex = 1;
  String _currentQuery = '';
  bool _hasMoreData = true;
  bool _isLoadingMore = false;

  String get currentQuery => _currentQuery;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMoreData;

  @override
  AsyncValue<List<Repository>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> searchRepositories(String query) async {
    state = const AsyncValue.loading();

    _resetState();
    _currentQuery = query.trim();

    if (_currentQuery.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    final repository = ref.read(githubRepositoryProvider);

    state = await AsyncValue.guard(() async {
      final results = await repository.searchRepositories(
        _currentQuery,
        page: _currentPageIndex,
      );
      
      _hasMoreData = results.length == _perPage;
      
      return results;
    });
  }

  Future<void> loadMoreRepositories() async {
    if (_isLoadingMore || !_hasMoreData || _currentQuery.isEmpty || state.isLoading || state.hasError) return;

    _isLoadingMore = true;
    final nextPageIndex = _currentPageIndex + 1;

    try{
      final repository = ref.read(githubRepositoryProvider);
      final newResults = await repository.searchRepositories(
        _currentQuery,
        page: nextPageIndex
      );

      final currentResults = state.value ?? [];
      final combinedResults = [...currentResults, ...newResults];

      _hasMoreData = newResults.length == _perPage;
      _currentPageIndex = nextPageIndex;

      state = AsyncValue.data(combinedResults);
    } catch(e) {
      log("loading failed: $e");
    } finally {
      _isLoadingMore = false;
    }
  }

  void _resetState() {
    _currentPageIndex = 1;
    _currentQuery = '';
    _hasMoreData = true;
    _isLoadingMore = false;
  }
}
