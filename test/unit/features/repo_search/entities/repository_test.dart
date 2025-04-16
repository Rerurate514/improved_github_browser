import 'package:flutter_test/flutter_test.dart';
import 'package:github_browser/features/repo_search/entities/repository.dart';

void main() {
  group('Repository Entity', () {
    test('JsonからRepositoryクラスを作成できる。', () {
      final json = {
        'repositoryName': 'flutter',
        'ownerIconUrl': 'https://example.com/icon.png',
        'projectLanguage': 'Dart',
        'starCount': 1000,
        'watcherCount': 100,
        'forkCount': 500,
        'issueCount': 50,
      };
      
      final repository = Repository.fromJson(json);
      
      expect(repository.repositoryName, 'flutter');
      expect(repository.starCount, 1000);
    });
    
    test('RepositoryクラスからJsonを生成できる。', () {
      final repository = Repository(
        repositoryName: 'flutter',
        ownerIconUrl: 'https://example.com/icon.png',
        projectLanguage: 'Dart',
        starCount: 1000,
        watcherCount: 100,
        forkCount: 500,
        issueCount: 50,
      );
      
      final json = repository.toJson();
      
      expect(json['repositoryName'], 'flutter');
      expect(json['starCount'], 1000);
    });
  });
}
