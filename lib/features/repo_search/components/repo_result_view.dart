import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_browser/core/exceptions/github_api_exception.dart';
import 'package:github_browser/features/repo_search/components/repo_list_item.dart';
import 'package:github_browser/features/repo_search/entities/repository.dart';
import 'package:github_browser/features/repo_search/providers/search_state_notifier.dart';
import 'package:github_browser/features/repo_search/providers/search_state_provider.dart';
import 'package:github_browser/l10n/app_localizations.dart';

class RepositoryResultView extends ConsumerStatefulWidget {
  final bool isEmptySearchQuery;

  const RepositoryResultView({super.key, required this.isEmptySearchQuery});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RepositoryResultViewState();
}

class _RepositoryResultViewState extends ConsumerState<RepositoryResultView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    const threshold = 200.0;
    if (_scrollController.position.extentAfter < threshold) {
      final notifier = ref.read(searchStateProvider.notifier);
      notifier.loadMoreRepositories();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Repository>> value = ref.watch(searchStateProvider);
    final searchNotifier = ref.read(searchStateProvider.notifier);

    return value.when(
      data: (searchResults) {
        if (searchResults.isEmpty) {
          return Center(
            child: Text(
              widget.isEmptySearchQuery
              ? AppLocalizations.of(context).home_bar_title
              : AppLocalizations.of(context).home_search_empty,
              style: const TextStyle(fontSize: 16),
            ),
          );
        }
        
        return ListView.builder(
          controller: _scrollController,
          itemCount: searchResults.length,
          itemBuilder: (context, index) {
            if (index == searchResults.length) {
              return _buildLoadingIndicator(searchNotifier);
            }

            final repo = searchResults[index];
            return RepositoryListItem(repository: repo);
          },
        );
      }, 
      error: (error, _) {
        String errorMessage;
  
        if (error is SocketException || error is HttpException || error is TimeoutException) {
          errorMessage = AppLocalizations.of(context).error_network;
        } else if (error is FormatException) {
          errorMessage = AppLocalizations.of(context).error_data_format;
        } else if(error is GitHubApiException){
          errorMessage = "${AppLocalizations.of(context).error_general} // ${error.message}";
        } else {
          log('Repository search error: $error');
          errorMessage = AppLocalizations.of(context).error_general;
        }

        return Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.red),
          ),
        );
      },
      loading: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
    );
  }

  Widget _buildLoadingIndicator(SearchStateNotifier notifier) {
    if (notifier.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
}
