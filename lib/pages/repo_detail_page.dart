import 'package:flutter/material.dart';
import 'package:github_browser/features/repo_details/components/repository_info_card.dart';
import 'package:github_browser/features/repo_search/entities/repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class RepoDetailsPage extends StatefulWidget {
  final Repository repository;

  const RepoDetailsPage({super.key, required this.repository});

  @override
  State<RepoDetailsPage> createState() => _RepoDetailsPageState();
}

class _RepoDetailsPageState extends State<RepoDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.details_bar_title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RepositoryInfoCard(repository: widget.repository)
      ),
    );
  }
}

