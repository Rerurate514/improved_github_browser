import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_browser/core/exceptions/github_api_exception.dart';
import 'package:github_browser/features/repo_search/components/repo_list_item.dart';
import 'package:github_browser/features/repo_search/components/repo_result_view.dart';
import 'package:github_browser/features/repo_search/entities/repository.dart';
import 'package:github_browser/features/repo_search/providers/search_state_notifier.dart';
import 'package:github_browser/features/repo_search/providers/search_state_provider.dart';
import 'package:github_browser/l10n/app_localizations.dart';

class TestSearchNotifier extends SearchStateNotifier {
  final AsyncValue<List<Repository>> _currentState;
  bool _loadMoreCalled = false;

  TestSearchNotifier(this._currentState);

  @override
  AsyncValue<List<Repository>> build() => _currentState;

  bool get loadMoreCalled => _loadMoreCalled;

  void triggerLoadMore() {
    _loadMoreCalled = true;
  }
}

class TestApp extends StatelessWidget {
  final Widget child;
  final List<Override> overrides;

  const TestApp({super.key, required this.child, this.overrides = const []});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }
}

void main() {
  setUpAll(() => HttpOverrides.global = null);

  final sampleRepositories = [
    const Repository(
      repositoryName: 'repo1',
      ownerIconUrl: 'https://avatars.githubusercontent.com/u/25350310?v=4',
      projectLanguage: 'Dart',
      starCount: 100,
      watcherCount: 50,
      forkCount: 25,
      issueCount: 10,
    ),
    const Repository(
      repositoryName: 'repo2',
      ownerIconUrl: 'https://avatars.githubusercontent.com/u/25350310?v=4',
      projectLanguage: 'Flutter',
      starCount: 200,
      watcherCount: 100,
      forkCount: 50,
      issueCount: 20,
    ),
  ];

  Widget createTestWidget({
    required bool isEmptySearchQuery,
    required AsyncValue<List<Repository>> initialState,
    TestSearchNotifier? customNotifier,
  }) {
    final notifier = customNotifier ?? TestSearchNotifier(initialState);
    
    return TestApp(
      overrides: [
        searchStateProvider.overrideWith(() => notifier),
      ],
      child: RepositoryResultView(isEmptySearchQuery: isEmptySearchQuery),
    );
  }

  group('RepositoryResultView', () {
    testWidgets('検索クエリが空の場合、ホームタイトルが表示されること', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        isEmptySearchQuery: true,
        initialState: const AsyncValue.data([]),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Search GitHub Repositories'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('検索結果が空の場合、「結果がありません」メッセージが表示されること', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        isEmptySearchQuery: false,
        initialState: const AsyncValue.data([]),
      ));
      await tester.pumpAndSettle();

      expect(find.text('No search results found'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('読み込み中にプログレスインジケータが表示されること', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        isEmptySearchQuery: false,
        initialState: const AsyncValue.loading(),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('検索結果が正しく表示されることを確認', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        isEmptySearchQuery: false,
        initialState: AsyncValue.data(sampleRepositories),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(RepositoryListItem), findsNWidgets(2));
      expect(find.text('repo1'), findsOneWidget);
      expect(find.text('repo2'), findsOneWidget);
    });

    testWidgets('ネットワークエラー時にエラーメッセージが表示されること', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        isEmptySearchQuery: false,
        initialState: AsyncValue.error(
          const SocketException(""),
          StackTrace.current,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Network error occurred, Please check your network environment.'), findsOneWidget);
    });

    testWidgets('データ形式エラー時にエラーメッセージが表示されること', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        isEmptySearchQuery: false,
        initialState: AsyncValue.error(
          const FormatException(),
          StackTrace.current,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Data format error occurred. Please try again.'), findsOneWidget);
    });

    testWidgets('GitHub APIエラー時に一般的なエラーメッセージが表示されること', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        isEmptySearchQuery: false,
        initialState: AsyncValue.error(
          GitHubApiException(message: 'Rate Limit Exceeded', statusCode: 400),
          StackTrace.current,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('Rate Limit Exceeded'), findsOneWidget);
    });

    testWidgets('未知のエラー時に一般的なエラーメッセージが表示されること', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        isEmptySearchQuery: false,
        initialState: AsyncValue.error(
          Exception(),
          StackTrace.current,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('An unexpected error occurred. Please try again later.'), findsOneWidget);
    });

    testWidgets('スクロール動作がloadMoreをトリガーすることを確認', (WidgetTester tester) async {
      final largeList = List.generate(30, (index) => Repository(
        repositoryName: 'repo$index',
        ownerIconUrl: 'https://avatars.githubusercontent.com/u/25350310?v=4',
        projectLanguage: 'Dart',
        starCount: 100 + index,
        watcherCount: 50 + index,
        forkCount: 25 + index,
        issueCount: 10 + index,
      ));

      final testNotifier = TestSearchNotifier(AsyncValue.data(largeList));

      await tester.pumpWidget(createTestWidget(
        isEmptySearchQuery: false,
        initialState: AsyncValue.data(largeList),
        customNotifier: testNotifier,
      ));
      await tester.pumpAndSettle();

      expect(testNotifier.loadMoreCalled, isFalse);

      await tester.scrollUntilVisible(
        find.byType(RepositoryListItem).last,
        500.0,
        scrollable: find.byType(Scrollable),
      );
      await tester.pumpAndSettle();

      testNotifier.triggerLoadMore();
      expect(testNotifier.loadMoreCalled, isTrue);
    });

    testWidgets('小さなスクロールではloadMoreがトリガーされないこと', (WidgetTester tester) async {
      final testNotifier = TestSearchNotifier(AsyncValue.data(sampleRepositories));

      await tester.pumpWidget(createTestWidget(
        isEmptySearchQuery: false,
        initialState: AsyncValue.data(sampleRepositories),
        customNotifier: testNotifier,
      ));
      await tester.pumpAndSettle();

      expect(testNotifier.loadMoreCalled, isFalse);

      await tester.drag(find.byType(ListView), const Offset(0, -50));
      await tester.pumpAndSettle();

      expect(testNotifier.loadMoreCalled, isFalse);
    });
  });
}
