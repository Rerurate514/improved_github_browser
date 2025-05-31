import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_browser/core/utils/check_network_connection.dart';
import 'package:github_browser/features/repo_search/entities/repository.dart';
import 'package:github_browser/features/repo_search/providers/github_repository_provider.dart';
import 'package:github_browser/l10n/app_localizations.dart';

class SearchStateNotifier extends AutoDisposeNotifier<AsyncValue<List<Repository>>> {
  @override
  AsyncValue<List<Repository>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> searchRepositories(String query) async {
    state = const AsyncValue.loading();

    final bool isConnected = await checkNetworkConnection(
      ref: ref,
      isNotConnectedHandler: (context) {
        state = AsyncValue.error(
          context != null 
            ? AppLocalizations.of(context).error_network
            : 'Network error',
          StackTrace.current
        );
      }
    );
    if(!isConnected) return;

    final repository = ref.read(githubRepositoryProvider);

    state = await AsyncValue.guard(() async {
      return repository.searchRepositories(query);
    });
  }
}
