import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:github_browser/core/components/search_field.dart';
import 'package:github_browser/core/routes/app_routes.dart';
import 'package:github_browser/features/repo_search/components/repo_result_view.dart';
import 'package:github_browser/features/repo_search/providers/search_state_provider.dart';
import 'package:github_browser/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SearchPage extends HookConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = useState<String>("");

    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    void handleSearch(String newQuery) {
      query.value = newQuery;
      ref.read(searchStateProvider.notifier).searchRepositories(newQuery);
    }

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
              onSearch: handleSearch,
              hint: appLocalizations.home_search_hint,
            ),
            const SizedBox(height: 20),
            
            Expanded(
              child: RepositoryResultView(isEmptySearchQuery: query.value.isEmpty),
            )
          ],
        ),
      ),
    );
  }
}
