import 'dart:math';

import 'package:flutter/material.dart';
import 'package:github_browser/features/repo_search/entities/repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RepositoryInfoCard extends StatelessWidget {
  final Repository repository;
  
  const RepositoryInfoCard({
    super.key,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                repository.repositoryName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              
              const SizedBox(height: 12),

              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(repository.ownerIconUrl),
                    radius: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          repository.projectLanguage,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              LayoutBuilder(
                builder: (context, constraints) {
                  final int columns = max(1, (constraints.maxWidth / 150).floor());
                  
                  // リポジトリ統計情報の項目リスト
                  final List<Map<String, dynamic>> statsItems = [
                    {
                      'icon': Icons.code, 
                      'value': repository.projectLanguage, 
                      'label': AppLocalizations.of(context).details_repository_language
                    },
                    {
                      'icon': Icons.star, 
                      'value': repository.starCount.toString(), 
                      'label': AppLocalizations.of(context).details_repository_stars
                    },
                    {
                      'icon': Icons.remove_red_eye, 
                      'value': repository.watcherCount.toString(), 
                      'label': AppLocalizations.of(context).details_repository_watchers
                    },
                    {
                      'icon': Icons.call_split, 
                      'value': repository.forkCount.toString(), 
                      'label': AppLocalizations.of(context).details_repository_forks
                    },
                    {
                      'icon': Icons.error_outline, 
                      'value': repository.issueCount.toString(), 
                      'label': AppLocalizations.of(context).details_repository_issues
                    },
                  ];
                  
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: statsItems.length,
                    itemBuilder: (context, index) {
                      final item = statsItems[index];
                      return _buildStatItem(
                        item['icon'],
                        item['value'],
                        item['label'],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      )
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
