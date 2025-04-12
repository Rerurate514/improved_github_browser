// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'repository.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Repository {

 String get repositoryName; String get ownerIconUrl; String get projectLanguage; int get starCount; int get watcherCount; int get forkCount; int get issueCount;
/// Create a copy of Repository
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RepositoryCopyWith<Repository> get copyWith => _$RepositoryCopyWithImpl<Repository>(this as Repository, _$identity);

  /// Serializes this Repository to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Repository&&(identical(other.repositoryName, repositoryName) || other.repositoryName == repositoryName)&&(identical(other.ownerIconUrl, ownerIconUrl) || other.ownerIconUrl == ownerIconUrl)&&(identical(other.projectLanguage, projectLanguage) || other.projectLanguage == projectLanguage)&&(identical(other.starCount, starCount) || other.starCount == starCount)&&(identical(other.watcherCount, watcherCount) || other.watcherCount == watcherCount)&&(identical(other.forkCount, forkCount) || other.forkCount == forkCount)&&(identical(other.issueCount, issueCount) || other.issueCount == issueCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,repositoryName,ownerIconUrl,projectLanguage,starCount,watcherCount,forkCount,issueCount);

@override
String toString() {
  return 'Repository(repositoryName: $repositoryName, ownerIconUrl: $ownerIconUrl, projectLanguage: $projectLanguage, starCount: $starCount, watcherCount: $watcherCount, forkCount: $forkCount, issueCount: $issueCount)';
}


}

/// @nodoc
abstract mixin class $RepositoryCopyWith<$Res>  {
  factory $RepositoryCopyWith(Repository value, $Res Function(Repository) _then) = _$RepositoryCopyWithImpl;
@useResult
$Res call({
 String repositoryName, String ownerIconUrl, String projectLanguage, int starCount, int watcherCount, int forkCount, int issueCount
});




}
/// @nodoc
class _$RepositoryCopyWithImpl<$Res>
    implements $RepositoryCopyWith<$Res> {
  _$RepositoryCopyWithImpl(this._self, this._then);

  final Repository _self;
  final $Res Function(Repository) _then;

/// Create a copy of Repository
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? repositoryName = null,Object? ownerIconUrl = null,Object? projectLanguage = null,Object? starCount = null,Object? watcherCount = null,Object? forkCount = null,Object? issueCount = null,}) {
  return _then(_self.copyWith(
repositoryName: null == repositoryName ? _self.repositoryName : repositoryName // ignore: cast_nullable_to_non_nullable
as String,ownerIconUrl: null == ownerIconUrl ? _self.ownerIconUrl : ownerIconUrl // ignore: cast_nullable_to_non_nullable
as String,projectLanguage: null == projectLanguage ? _self.projectLanguage : projectLanguage // ignore: cast_nullable_to_non_nullable
as String,starCount: null == starCount ? _self.starCount : starCount // ignore: cast_nullable_to_non_nullable
as int,watcherCount: null == watcherCount ? _self.watcherCount : watcherCount // ignore: cast_nullable_to_non_nullable
as int,forkCount: null == forkCount ? _self.forkCount : forkCount // ignore: cast_nullable_to_non_nullable
as int,issueCount: null == issueCount ? _self.issueCount : issueCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Repository implements Repository {
  const _Repository({required this.repositoryName, required this.ownerIconUrl, required this.projectLanguage, required this.starCount, required this.watcherCount, required this.forkCount, required this.issueCount});
  factory _Repository.fromJson(Map<String, dynamic> json) => _$RepositoryFromJson(json);

@override final  String repositoryName;
@override final  String ownerIconUrl;
@override final  String projectLanguage;
@override final  int starCount;
@override final  int watcherCount;
@override final  int forkCount;
@override final  int issueCount;

/// Create a copy of Repository
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RepositoryCopyWith<_Repository> get copyWith => __$RepositoryCopyWithImpl<_Repository>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RepositoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Repository&&(identical(other.repositoryName, repositoryName) || other.repositoryName == repositoryName)&&(identical(other.ownerIconUrl, ownerIconUrl) || other.ownerIconUrl == ownerIconUrl)&&(identical(other.projectLanguage, projectLanguage) || other.projectLanguage == projectLanguage)&&(identical(other.starCount, starCount) || other.starCount == starCount)&&(identical(other.watcherCount, watcherCount) || other.watcherCount == watcherCount)&&(identical(other.forkCount, forkCount) || other.forkCount == forkCount)&&(identical(other.issueCount, issueCount) || other.issueCount == issueCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,repositoryName,ownerIconUrl,projectLanguage,starCount,watcherCount,forkCount,issueCount);

@override
String toString() {
  return 'Repository(repositoryName: $repositoryName, ownerIconUrl: $ownerIconUrl, projectLanguage: $projectLanguage, starCount: $starCount, watcherCount: $watcherCount, forkCount: $forkCount, issueCount: $issueCount)';
}


}

/// @nodoc
abstract mixin class _$RepositoryCopyWith<$Res> implements $RepositoryCopyWith<$Res> {
  factory _$RepositoryCopyWith(_Repository value, $Res Function(_Repository) _then) = __$RepositoryCopyWithImpl;
@override @useResult
$Res call({
 String repositoryName, String ownerIconUrl, String projectLanguage, int starCount, int watcherCount, int forkCount, int issueCount
});




}
/// @nodoc
class __$RepositoryCopyWithImpl<$Res>
    implements _$RepositoryCopyWith<$Res> {
  __$RepositoryCopyWithImpl(this._self, this._then);

  final _Repository _self;
  final $Res Function(_Repository) _then;

/// Create a copy of Repository
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? repositoryName = null,Object? ownerIconUrl = null,Object? projectLanguage = null,Object? starCount = null,Object? watcherCount = null,Object? forkCount = null,Object? issueCount = null,}) {
  return _then(_Repository(
repositoryName: null == repositoryName ? _self.repositoryName : repositoryName // ignore: cast_nullable_to_non_nullable
as String,ownerIconUrl: null == ownerIconUrl ? _self.ownerIconUrl : ownerIconUrl // ignore: cast_nullable_to_non_nullable
as String,projectLanguage: null == projectLanguage ? _self.projectLanguage : projectLanguage // ignore: cast_nullable_to_non_nullable
as String,starCount: null == starCount ? _self.starCount : starCount // ignore: cast_nullable_to_non_nullable
as int,watcherCount: null == watcherCount ? _self.watcherCount : watcherCount // ignore: cast_nullable_to_non_nullable
as int,forkCount: null == forkCount ? _self.forkCount : forkCount // ignore: cast_nullable_to_non_nullable
as int,issueCount: null == issueCount ? _self.issueCount : issueCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
