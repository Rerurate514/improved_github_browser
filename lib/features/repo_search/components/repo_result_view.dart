import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_browser/features/repo_search/components/repo_list_item.dart';
import 'package:github_browser/features/repo_search/entities/repository.dart';
import 'package:github_browser/features/repo_search/providers/search_state_provider.dart';
import 'package:github_browser/l10n/app_localizations.dart';

class RepositoryResultView extends ConsumerStatefulWidget {
  final bool isEmptySearchQuery;

  const RepositoryResultView({super.key, required this.isEmptySearchQuery});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RepositoryResultViewState();
}

class _RepositoryResultViewState extends ConsumerState<RepositoryResultView> {
  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Repository>> value = ref.watch(searchStateProvider);

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
          itemCount: searchResults.length,
          itemBuilder: (context, index) {
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
}
