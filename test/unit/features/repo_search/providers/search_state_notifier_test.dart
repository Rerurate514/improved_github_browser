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

    expect(container.read(searchStateProvider), isA<AsyncError<dynamic>>());
    expect(container.read(searchStateProvider).error, exception);
    verify(mockGithubRepository.searchRepositories('error_query')).called(1);
  });

  group('無限スクロール機能のテスト', () {
    late List<Repository> firstPageRepositories;
    late List<Repository> secondPageRepositories;

    setUp(() {
      firstPageRepositories = List.generate(10, (index) => Repository(
        repositoryName: "repo_$index",
        ownerIconUrl: "icon_$index",
        projectLanguage: "Dart",
        starCount: index * 10,
        watcherCount: index * 5,
        forkCount: index * 2,
        issueCount: index,
      ));

      secondPageRepositories = List.generate(10, (index) => Repository(
        repositoryName: "repo_${index + 10}",
        ownerIconUrl: "icon_${index + 10}",
        projectLanguage: "Flutter",
        starCount: (index + 10) * 10,
        watcherCount: (index + 10) * 5,
        forkCount: (index + 10) * 2,
        issueCount: index + 10,
      ));
    });

    test('loadMoreRepositoriesが成功した場合、既存のリストに新しいデータが追加されること', () async {
      when(mockGithubRepository.searchRepositories('test'))
        .thenAnswer((_) async => firstPageRepositories);
      when(mockGithubRepository.searchRepositories('test', page: 2))
        .thenAnswer((_) async => secondPageRepositories);

      final notifier = container.read(searchStateProvider.notifier);

      await notifier.searchRepositories('test');
      expect(container.read(searchStateProvider).value, firstPageRepositories);

      await notifier.loadMoreRepositories();

      final combinedResults = [...firstPageRepositories, ...secondPageRepositories];
      expect(container.read(searchStateProvider).value, combinedResults);
      expect(container.read(searchStateProvider).value?.length, 20);

      verify(mockGithubRepository.searchRepositories('test')).called(1);
      verify(mockGithubRepository.searchRepositories('test', page: 2)).called(1);
    });

    test('最後のページの場合、hasMoreDataがfalseになること', () async {
      final lastPageRepositories = List.generate(5, (index) => Repository(
        repositoryName: "repo_$index",
        ownerIconUrl: "icon_$index",
        projectLanguage: "Dart",
        starCount: index,
        watcherCount: index,
        forkCount: index,
        issueCount: index,
      ));

      when(mockGithubRepository.searchRepositories('test'))
          .thenAnswer((_) async => firstPageRepositories);
      when(mockGithubRepository.searchRepositories('test', page: 2))
          .thenAnswer((_) async => lastPageRepositories);

      final notifier = container.read(searchStateProvider.notifier);

      await notifier.searchRepositories('test');
      expect(notifier.hasMoreData, true);

      await notifier.loadMoreRepositories();
      expect(notifier.hasMoreData, false);
    });

    test('loadMoreRepositoriesを連続で呼び出しても、一度しか実行されないこと', () async {
      when(mockGithubRepository.searchRepositories('test'))
          .thenAnswer((_) async => firstPageRepositories);
      when(mockGithubRepository.searchRepositories('test', page: 2))
          .thenAnswer((_) async => secondPageRepositories);

      final notifier = container.read(searchStateProvider.notifier);

      await notifier.searchRepositories('test');

      final futures = [
        notifier.loadMoreRepositories(),
        notifier.loadMoreRepositories(),
        notifier.loadMoreRepositories(),
      ];

      await Future.wait(futures);

      verify(mockGithubRepository.searchRepositories('test', page: 2)).called(1);
    });

    test('loadMoreRepositoriesでエラーが発生した場合、既存のデータは保持されること', () async {
      when(mockGithubRepository.searchRepositories('test'))
          .thenAnswer((_) async => firstPageRepositories);
      when(mockGithubRepository.searchRepositories('test', page: 2))
          .thenThrow(Exception('Network error'));

      final notifier = container.read(searchStateProvider.notifier);

      await notifier.searchRepositories('test');
      expect(container.read(searchStateProvider).value, firstPageRepositories);

      await notifier.loadMoreRepositories();

      expect(container.read(searchStateProvider).value, firstPageRepositories);
      expect(container.read(searchStateProvider).hasError, false);
    });

    test('クエリが空の場合、loadMoreRepositoriesは何もしないこと', () async {
      final notifier = container.read(searchStateProvider.notifier);

      await notifier.loadMoreRepositories();

      verifyNever(mockGithubRepository.searchRepositories(any, perPage: anyNamed('perPage'), page: anyNamed('page')));
      expect(notifier.isLoadingMore, false);
    });

    test('hasMoreDataがfalseの場合、loadMoreRepositoriesは何もしないこと', () async {
      final lastPageRepositories = List.generate(5, (index) => Repository(
        repositoryName: "repo_$index",
        ownerIconUrl: "icon_$index",
        projectLanguage: "Dart",
        starCount: index,
        watcherCount: index,
        forkCount: index,
        issueCount: index,
      ));

      when(mockGithubRepository.searchRepositories('test'))
          .thenAnswer((_) async => lastPageRepositories);

      final notifier = container.read(searchStateProvider.notifier);

      await notifier.searchRepositories('test');
      expect(notifier.hasMoreData, false);

      await notifier.loadMoreRepositories();

      verify(mockGithubRepository.searchRepositories('test')).called(1);
      verifyNever(mockGithubRepository.searchRepositories('test', page: 2));
    });
  });
}
