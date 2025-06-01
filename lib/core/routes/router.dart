import 'package:flutter/material.dart';
import 'package:github_browser/features/github_auth/components/signin_wrapper.dart';
import 'package:github_browser/features/repo_search/entities/repository.dart';
import 'package:github_browser/pages/repo_detail_page.dart';
import 'package:github_browser/pages/settings_page.dart';
import 'package:go_router/go_router.dart';

GoRouter createGoRouter(GlobalKey<NavigatorState> navigatorKey) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'initial',
        pageBuilder: (context, state) {
          return MaterialPage(key: state.pageKey, child: const SignInWrapper());
        },
      ),
      GoRoute(
        path: '/repository-detail',
        name: 'repositoryDetail',
        pageBuilder: (context, state) {
          return MaterialPage(
            key: state.pageKey,
            child: RepoDetailsPage(repository: state.extra! as Repository),
          );
        },
      ),
      GoRoute(
        path: '/setting',
        name: 'setting',
        pageBuilder: (context, state) {
          return MaterialPage(key: state.pageKey, child: const SettingsPage());
        },
      ),
    ],
    errorPageBuilder:
        (context, state) => MaterialPage(
          key: state.pageKey,
          child: Scaffold(body: Center(child: Text(state.error.toString()))),
        ),
  );
}
