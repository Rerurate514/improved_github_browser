import 'package:flutter/material.dart';
import 'package:github_browser/core/components/info_chip.dart';
import 'package:github_browser/core/routes/page_router.dart';
import 'package:github_browser/features/repo_search/entities/repository.dart';

class RepositoryListItem extends StatelessWidget {
  final Repository repository;
  
  const RepositoryListItem({
    super.key,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: () {
          PageRouter.navigateDetailsPage(context, repository);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(repository.ownerIconUrl),
                    radius: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      repository.repositoryName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  InfoChip(
                    icon: Icons.code,
                    label: repository.projectLanguage,
                  ),
                ],
              ),
            ],
          ),
        ),
      )
    );
  }
}
