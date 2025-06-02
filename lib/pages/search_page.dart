import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_browser/core/components/search_field.dart';
import 'package:github_browser/core/routes/app_routes.dart';
import 'package:github_browser/features/repo_search/components/repo_result_view.dart';
import 'package:github_browser/features/repo_search/providers/search_state_provider.dart';
import 'package:github_browser/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  // ignore: no_logic_in_create_state
  ConsumerState<SearchPage> createState() => SearchPageState();
}

class SearchPageState extends ConsumerState<SearchPage> {
  String _query = "";

  Future<void> _handleSearch(String query) async {
    setState(() {
      _query = query;
    });
    ref.read(searchStateProvider.notifier).searchRepositories(query);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.home_bar_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push(AppRoutes.settingsPage);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchField(
              onSearch: _handleSearch,
              hint: appLocalizations.home_search_hint,
            ),
            const SizedBox(height: 20),
            
            Expanded(
              child: RepositoryResultView(isEmptySearchQuery: _query.isEmpty,),
            )
          ],
        ),
      ),
    );
  }
}
