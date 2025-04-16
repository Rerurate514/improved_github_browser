import 'package:flutter/material.dart';
import 'package:github_browser/core/components/search_field.dart';
import 'package:github_browser/core/routes/page_router.dart';
import 'package:github_browser/features/repo_search/components/repo_result_view.dart';
import 'package:github_browser/features/repo_search/entities/repository.dart';
import 'package:github_browser/features/repo_search/repositories/github_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchPage extends StatefulWidget {
  final String token;
  const SearchPage({super.key, required this.token});

  @override
  // ignore: no_logic_in_create_state
  State<SearchPage> createState() => SearchPageState(token);
}

class SearchPageState extends State<SearchPage> {
  String _searchQuery = '';
  bool _isLoading = false;
  List<Repository> _searchResults = [];
  // ignore: unused_field
  String? _errorMessage;
  
  late final GitHubRepository _repository;

  //ここでtokenをwidget.token経由で渡そうとすると、
  //late final フィールドの初期化タイミングの問題が発生するためコンストラクタで
  //直接渡す方式を採用
  SearchPageState(String token) : _repository = GitHubRepository(apiToken: token);
  
  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  // 検索処理
  Future<void> _handleSearch(String query) async {
    setState(() {
      _searchQuery = query;
      _isLoading = true;
      _errorMessage = null;
    });
    
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }
    
    try {
      final results = await _repository.searchRepositories(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '${"error_general"}: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.home_bar_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              PageRouter.navigateSettingsPage(context);
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
              hint: AppLocalizations.of(context)!.home_search_hint,
            ),
            const SizedBox(height: 20),
            
            Expanded(
              child: RepositoryResultsView(
                isLoading: _isLoading, 
                searchResults: _searchResults, 
                searchQuery: _searchQuery
              ),
            )
          ],
        ),
      ),
    );
  }
}

