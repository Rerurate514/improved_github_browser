import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_browser/features/repo_search/entities/repository.dart';
import 'package:github_browser/features/repo_search/providers/search_state_notifier.dart';

final searchStateProvider = NotifierProvider.autoDispose<SearchStateNotifier, AsyncValue<List<Repository>>>(
  SearchStateNotifier.new
);
