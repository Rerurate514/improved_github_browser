import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:github_browser/core/exceptions/github_api_exception.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:github_browser/features/repo_search/repositories/github_repository.dart';

import 'github_repository_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient mockClient;
  late GitHubRepository repository;

  setUp(() {
    mockClient = MockClient();
    repository = GitHubRepository(
      httpClient: mockClient,
      baseUrl: 'https://api.github.com',
    );
  });

  group('searchRepositories', () {
    final mockResponse = {
      'items': [
        {
          'name': 'flutter',
          'full_name': 'flutter/flutter',
          'owner': {
            'avatar_url': 'https://example.com/avatar.png',
          },
          'language': 'Dart',
          'stargazers_count': 1000,
          'watchers_count': 100,
          'forks_count': 500,
          'open_issues_count': 50,
        },
        {
          'name': 'sample-repo',
          'full_name': 'user/sample-repo',
          'owner': {
            'avatar_url': 'https://example.com/user-avatar.png',
          },
          'language': 'JavaScript',
          'stargazers_count': 200,
          'watchers_count': 20,
          'forks_count': 30,
          'open_issues_count': 5,
        },
      ]
    };

    test('正常にリポジトリを検索できること', () async {
      when(mockClient.get(
        Uri.parse('https://api.github.com/search/repositories?q=flutter&per_page=10&page=1'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      final results = await repository.searchRepositories('flutter');

      expect(results.length, 2);
      expect(results[0].repositoryName, 'flutter/flutter');
      expect(results[0].projectLanguage, 'Dart');
      expect(results[0].starCount, 1000);
      expect(results[0].issueCount, 50);
      
      expect(results[1].repositoryName, 'user/sample-repo');
      expect(results[1].projectLanguage, 'JavaScript');
      expect(results[1].starCount, 200);

      verify(mockClient.get(
        Uri.parse('https://api.github.com/search/repositories?q=flutter&per_page=10&page=1'),
        headers: anyNamed('headers'),
      )).called(1);
    });

    test('クエリが空の場合は空のリストを返すこと', () async {
      final results = await repository.searchRepositories('');

      expect(results, isEmpty);
      
      verifyNever(mockClient.get(any, headers: anyNamed('headers')));
    });

    test('APIエラーが発生した場合は例外をスローすること', () async {
      when(mockClient.get(
        Uri.parse('https://api.github.com/search/repositories?q=flutter&per_page=10&page=1'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('{"message": "Bad credentials"}', 401));

      expect(
        () => repository.searchRepositories('flutter'),
        throwsA(isA<GitHubApiException>().having(
          (e) => e.statusCode, 
          'statusCode', 
          401
        )),
      );
    });
    
    test('ページネーションパラメータが正しく渡されること', () async {
      when(mockClient.get(
        Uri.parse('https://api.github.com/search/repositories?q=flutter&per_page=20&page=2'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      await repository.searchRepositories('flutter', perPage: 20, page: 2);

      verify(mockClient.get(
        Uri.parse('https://api.github.com/search/repositories?q=flutter&per_page=20&page=2'),
        headers: anyNamed('headers'),
      )).called(1);
    });
  });

  group('getRepositoryDetails', () {
    final mockRepoResponse = {
      'name': 'flutter',
      'full_name': 'flutter/flutter',
      'owner': {
        'avatar_url': 'https://example.com/avatar.png',
      },
      'language': 'Dart',
      'stargazers_count': 1000,
      'watchers_count': 100,
      'forks_count': 500,
      'open_issues_count': 50,
    };

    test('正常にリポジトリ詳細を取得できること', () async {
      when(mockClient.get(
        Uri.parse('https://api.github.com/repos/flutter/flutter'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode(mockRepoResponse), 200));
      
      when(mockClient.get(
        Uri.parse('https://api.github.com/repos/flutter/flutter/issues?state=open&per_page=1'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('[]', 200, headers: {
        'link': '<https://api.github.com/repos/flutter/flutter/issues?state=open&per_page=1&page=42>; rel="last"'
      }));

      final result = await repository.getRepositoryDetails('flutter', 'flutter');

      expect(result.repositoryName, 'flutter/flutter');
      expect(result.projectLanguage, 'Dart');
      expect(result.starCount, 1000);
      expect(result.issueCount, 42);

      verify(mockClient.get(
        Uri.parse('https://api.github.com/repos/flutter/flutter'),
        headers: anyNamed('headers'),
      )).called(1);
      
      verify(mockClient.get(
        Uri.parse('https://api.github.com/repos/flutter/flutter/issues?state=open&per_page=1'),
        headers: anyNamed('headers'),
      )).called(1);
    });

    test('リンクヘッダーがない場合はレスポンスの長さをissueCountとして使用すること', () async {
      when(mockClient.get(
        Uri.parse('https://api.github.com/repos/flutter/flutter'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode(mockRepoResponse), 200));
      
      when(mockClient.get(
        Uri.parse('https://api.github.com/repos/flutter/flutter/issues?state=open&per_page=1'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('[{"id": 1}]', 200));

      final result = await repository.getRepositoryDetails('flutter', 'flutter');

      expect(result.issueCount, 1);
    });

    test('Issue取得でエラーが発生した場合もリポジトリ詳細を返すこと', () async {
      when(mockClient.get(
        Uri.parse('https://api.github.com/repos/flutter/flutter'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode(mockRepoResponse), 200));
      
      when(mockClient.get(
        Uri.parse('https://api.github.com/repos/flutter/flutter/issues?state=open&per_page=1'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('{"message": "API rate limit exceeded"}', 403));

      final result = await repository.getRepositoryDetails('flutter', 'flutter');

      expect(result.repositoryName, 'flutter/flutter');
      expect(result.issueCount, 0);
    });

    test('リポジトリ詳細取得でエラーが発生した場合は例外をスローすること', () async {
      when(mockClient.get(
        Uri.parse('https://api.github.com/repos/flutter/flutter'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('{"message": "Not Found"}', 404));

      expect(
        () => repository.getRepositoryDetails('flutter', 'flutter'),
        throwsA(isA<GitHubApiException>().having(
          (e) => e.statusCode, 
          'statusCode', 
          404
        )),
      );
    });
  });

  group('_executeRequest', () {
    test('正常なレスポンスの場合はそのまま返すこと', () async {
      when(mockClient.get(
        Uri.parse('https://api.github.com/test'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('{"data": "test"}', 200));

      // _executeRequestはプライベートメソッドなので、パブリックメソッド経由でテスト
      when(mockClient.get(
        Uri.parse('https://api.github.com/search/repositories?q=test&per_page=10&page=1'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('{"items": []}', 200));

      await repository.searchRepositories('test');

      verify(mockClient.get(
        Uri.parse('https://api.github.com/search/repositories?q=test&per_page=10&page=1'),
        headers: anyNamed('headers'),
      )).called(1);
    });

    test('エラーレスポンスの場合は例外をスローすること', () async {
      when(mockClient.get(
        Uri.parse('https://api.github.com/search/repositories?q=test&per_page=10&page=1'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
        '{"message": "Validation Failed"}', 
        422
      ));

      expect(
        () => repository.searchRepositories('test'),
        throwsA(isA<GitHubApiException>().having(
          (e) => e.statusCode, 
          'statusCode', 
          422
        )),
      );
    });
  });

  test('dispose メソッドがhttp.Client を閉じること', () {
    repository.dispose();
    
    verify(mockClient.close()).called(1);
  });
}
