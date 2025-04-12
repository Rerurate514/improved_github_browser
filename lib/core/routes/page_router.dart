import 'package:flutter/material.dart';
import 'package:github_browser/features/repo_search/entities/repository.dart';
import 'package:github_browser/pages/repo_detail_page.dart';

class PageRouter {
  static void navigateDetailsPage(BuildContext context, Repository repository){
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => RepoDetailsPage(
        repository: repository,
      )),
    );
  }

  static void navigateSettingsPage(BuildContext context){
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => const SettingsPage()),
    // );
  }
}
