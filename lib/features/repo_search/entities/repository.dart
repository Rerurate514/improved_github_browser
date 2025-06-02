import 'package:freezed_annotation/freezed_annotation.dart';

part 'repository.freezed.dart';
part 'repository.g.dart';

@freezed
abstract class Repository with _$Repository {
  const factory Repository({
    required String repositoryName,
    required String ownerIconUrl,
    required String projectLanguage,
    required int starCount,
    required int watcherCount,
    required int forkCount,
    required int issueCount,
  }) = _Repository;

  factory Repository.fromJson(Map<String, dynamic> json) => _$RepositoryFromJson(json);
}
