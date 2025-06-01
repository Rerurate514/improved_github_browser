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
  final AsyncValue<List<Repository>> _state = const AsyncData([]);

  @override
  AsyncValue<List<Repository>> build() => _state;

  // ignore: use_setters_to_change_properties
  void setState(AsyncValue<List<Repository>> newState) {
    state = newState;
  }

  bool _loadMoreCalled = false;

  bool get loadMoreCalled => _loadMoreCalled;

  void triggerLoadMore() {
    _loadMoreCalled = true;
  }

  // ignore: unreachable_from_main
  void resetLoadMore() {
    _loadMoreCalled = false;
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
        localizationsDelegates: const [
          AppLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
          DefaultMaterialLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }
}

void main() {
  final sampleRepositories = [
    const Repository(
      repositoryName: 'repo1',
      ownerIconUrl: 'url1',
      projectLanguage: 'Dart',
      starCount: 100,
      watcherCount: 50,
      forkCount: 25,
      issueCount: 10,
    ),
    const Repository(
      repositoryName: 'repo2',
      ownerIconUrl: 'url2',
      projectLanguage: 'Kotlin',
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
    final notifier = customNotifier ?? TestSearchNotifier();
    notifier.setState(initialState);
    
    return TestApp(
      overrides: [
        searchStateProvider.overrideWith(() => notifier),
      ],
      child: RepositoryResultView(isEmptySearchQuery: isEmptySearchQuery),
    );
  }

  group('RepositoryResultView', () {
    testWidgets('Empty search query shows home title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        isEmptySearchQuery: true,
        initialState: const AsyncValue.data([]),
      ));
      await tester.pumpAndSettle();

      expect(find.text('GitHub リポジトリ検索'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('Empty results show no results message', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        isEmptySearchQuery: false,
        initialState: const AsyncValue.data([]),
      ));
      await tester.pumpAndSettle();

      expect(find.text('検索結果がありません。'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('Search results display correctly', (WidgetTester tester) async {
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

    testWidgets('Loading state shows progress indicator', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        isEmptySearchQuery: false,
        initialState: const AsyncValue.loading(),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('Network error shows error message', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        isEmptySearchQuery: false,
        initialState: AsyncValue.error(
          const SocketException('No Internet'),
          StackTrace.current,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('ネットワークエラーが発生しました。'), findsOneWidget);
    });

    testWidgets('Format error shows data format error message', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        isEmptySearchQuery: false,
        initialState: AsyncValue.error(
          const FormatException('Invalid JSON'),
          StackTrace.current,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('データの形式が正しくありません。'), findsOneWidget);
    });

    testWidgets('GitHub API error shows general error message', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        isEmptySearchQuery: false,
        initialState: AsyncValue.error(
          GitHubApiException(message: 'Rate Limit Exceeded', statusCode: 400),
          StackTrace.current,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('エラーが発生しました。'), findsOneWidget);
    });

    testWidgets('Unknown error shows general error message', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        isEmptySearchQuery: false,
        initialState: AsyncValue.error(
          Exception('Unknown Error'),
          StackTrace.current,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('エラーが発生しました。'), findsOneWidget);
    });

    testWidgets('Scrolling behavior test', (WidgetTester tester) async {
      final testNotifier = TestSearchNotifier();
      final largeList = List.generate(30, (index) => Repository(
        repositoryName: 'repo$index',
        ownerIconUrl: 'url$index',
        projectLanguage: 'Dart',
        starCount: 100 + index,
        watcherCount: 50 + index,
        forkCount: 25 + index,
        issueCount: 10 + index,
      ));

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

    testWidgets('Small scroll does not trigger load more', (WidgetTester tester) async {
      final testNotifier = TestSearchNotifier();

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
