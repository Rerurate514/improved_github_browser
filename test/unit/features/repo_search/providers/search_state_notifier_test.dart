import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_browser/features/repo_search/entities/repository.dart';
import 'package:github_browser/features/repo_search/providers/github_repository_provider.dart';
import 'package:github_browser/features/repo_search/providers/search_state_provider.dart';
import 'package:github_browser/features/repo_search/repositories/github_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([GitHubRepository])
import 'search_state_notifier_test.mocks.dart';

void main() {
  late ProviderContainer container;
  late MockGitHubRepository mockGithubRepository;

  setUp(() {
    mockGithubRepository = MockGitHubRepository();
    container = ProviderContainer(
      overrides: [githubRepositoryProvider.overrideWithValue(mockGithubRepository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('初期状態は空のリストであること', () {
    expect(container.read(searchStateProvider), const AsyncValue<List<Repository>>.data([]));
  });

  test('searchRepositoriesが成功した場合、状態が更新されること', () async {
    final repositories = [
      const Repository(
        repositoryName: "repositoryName",
        ownerIconUrl: "ownerIconUrl",
        projectLanguage: "projectLanguage",
        starCount: 0,
        watcherCount: 0,
        forkCount: 0,
        issueCount: 0,
      ),
    ];

    when(mockGithubRepository.searchRepositories('test')).thenAnswer((_) async => repositories);

    final notifier = container.read(searchStateProvider.notifier);
    await notifier.searchRepositories('test');

    expect(container.read(searchStateProvider), AsyncValue.data(repositories));
    verify(mockGithubRepository.searchRepositories('test')).called(1);
  });

  test('searchRepositoriesが失敗した場合、状態がエラーになること', () async {
    final exception = Exception('Network error');

    when(mockGithubRepository.searchRepositories('error_query')).thenThrow(exception);

    final notifier = container.read(searchStateProvider.notifier);
    await notifier.searchRepositories('error_query');

    // ignore: strict_raw_type
    expect(container.read(searchStateProvider), isA<AsyncError>());
    expect(container.read(searchStateProvider).error, exception);
    verify(mockGithubRepository.searchRepositories('error_query')).called(1);
  });
}
