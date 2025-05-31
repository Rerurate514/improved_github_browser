import 'dart:convert';
import 'dart:developer';
import 'package:github_browser/core/exceptions/github_api_exception.dart';
import 'package:github_browser/features/repo_search/entities/repository.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:github_browser/core/env/env.dart';

class GitHubRepository {
  final String _apiToken;

  final String _baseUrl;
  final http.Client _httpClient;

  GitHubRepository({
    http.Client? httpClient,
    String baseUrl = 'https://api.github.com',
    String? apiToken
  })  : 
        _httpClient = httpClient ?? http.Client(),
        _baseUrl = baseUrl,
        _apiToken = apiToken ?? Env.apiKey;

  Future<List<Repository>> searchRepositories(
    String query, {
    int perPage = 10,
    int page = 1,
  }) async {
    if (query.isEmpty) return [];

    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse('$_baseUrl/search/repositories?q=$encodedQuery&per_page=$perPage&page=$page');

    try {
      final response = await _executeRequest(url);
      final data = jsonDecode(response.body);
      final List<dynamic> items = data['items'];

      return items.map((item) => _mapToRepository(item)).toList();
    } catch (e) {
      log('リポジトリ検索中にエラーが発生しました: $e');
      rethrow;
    }
  }

  Future<Repository> getRepositoryDetails(String owner, String repositoryName) async {
    final repoUrl = Uri.parse('$_baseUrl/repos/$owner/$repositoryName');

    try {
      final repoResponse = await _executeRequest(repoUrl);
      final repoData = jsonDecode(repoResponse.body);

      final issueCount = await _fetchIssueCount(owner, repositoryName);

      return _mapToRepository(repoData, issueCount: issueCount);
    } catch (e) {
      log('リポジトリ詳細の取得中にエラーが発生しました: $e');
      rethrow;
    }
  }

  Future<http.Response> _executeRequest(Uri url) async {
    final response = await _httpClient.get(
      url,
      headers: {
        'Accept': 'application/vnd.github.v3+json',
        'Authorization': 'Bearer $_apiToken',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      throw GitHubApiException(
        statusCode: response.statusCode,
        message: 'GitHub API リクエストに失敗しました: ${response.body}',
      );
    }
  }

  Future<int> _fetchIssueCount(String owner, String repositoryName) async {
    final issuesUrl = Uri.parse('$_baseUrl/repos/$owner/$repositoryName/issues?state=open&per_page=1');
    
    try {
      final issuesResponse = await _executeRequest(issuesUrl);
      
      final linkHeader = issuesResponse.headers['link'];
      if (linkHeader != null && linkHeader.contains('rel="last"')) {
        final regex = RegExp(r'page=(\d+)>; rel="last"');
        final match = regex.firstMatch(linkHeader);
        if (match != null && match.groupCount >= 1) {
          return int.parse(match.group(1)!);
        }
      }
      
      final issues = jsonDecode(issuesResponse.body) as List;
      return issues.length;
    } catch (e) {
      log('Issue数の取得中にエラーが発生しました: $e');
      return 0;
    }
  }

  /// GitHub APIレスポンスからRepositoryへのマッピング
  Repository _mapToRepository(Map<String, dynamic> data, {int? issueCount}) {
    return Repository(
      repositoryName: data['full_name'] ?? data['name'] ?? '',
      ownerIconUrl: data['owner']?['avatar_url'] ?? '',
      projectLanguage: data['language'] ?? 'Unknown',
      starCount: data['stargazers_count'] ?? 0,
      watcherCount: data['watchers_count'] ?? 0,
      forkCount: data['forks_count'] ?? 0,
      issueCount: issueCount ?? data['open_issues_count'] ?? 0,
    );
  }

  void dispose() {
    _httpClient.close();
  }
}
