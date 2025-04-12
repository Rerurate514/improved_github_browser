// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Repository _$RepositoryFromJson(Map<String, dynamic> json) => _Repository(
  repositoryName: json['repositoryName'] as String,
  ownerIconUrl: json['ownerIconUrl'] as String,
  projectLanguage: json['projectLanguage'] as String,
  starCount: (json['starCount'] as num).toInt(),
  watcherCount: (json['watcherCount'] as num).toInt(),
  forkCount: (json['forkCount'] as num).toInt(),
  issueCount: (json['issueCount'] as num).toInt(),
);

Map<String, dynamic> _$RepositoryToJson(_Repository instance) =>
    <String, dynamic>{
      'repositoryName': instance.repositoryName,
      'ownerIconUrl': instance.ownerIconUrl,
      'projectLanguage': instance.projectLanguage,
      'starCount': instance.starCount,
      'watcherCount': instance.watcherCount,
      'forkCount': instance.forkCount,
      'issueCount': instance.issueCount,
    };
