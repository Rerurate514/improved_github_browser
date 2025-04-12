import 'package:flutter/material.dart';
import 'package:github_browser/core/components/search_field.dart';
import 'package:github_browser/features/repo_search/components/repo_result_view.dart';
import 'package:github_browser/features/repo_search/entities/repository.dart';
import 'package:github_browser/features/repo_search/repositories/github_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _searchQuery = '';
  bool _isLoading = false;
  List<Repository> _searchResults = [];
  String? _errorMessage;
  
  final GitHubRepository _repository = GitHubRepository();
  
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
        title: Text("home_bar_title"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              //TODO ページルート -> settings_page
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
              hint: "home_search_hint",
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

