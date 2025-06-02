import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_browser/core/routes/app_routes.dart';
import 'package:github_browser/features/github_auth/providers/signin_state_provider.dart';
import 'package:github_browser/features/repo_search/entities/repository.dart';
import 'package:github_browser/pages/redirect_indicator_page.dart';
import 'package:github_browser/pages/repo_detail_page.dart';
import 'package:github_browser/pages/search_page.dart';
import 'package:github_browser/pages/settings_page.dart';
import 'package:github_browser/pages/signin_page.dart';
import 'package:go_router/go_router.dart';

GoRouter createGoRouter(
  GlobalKey<NavigatorState> navigatorKey,
  Ref ref,
) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.initialPage.path,
    redirect: (context, state) {
      final signInState = ref.watch(signinStateProvider);
      final currentPath = state.matchedLocation;

      log(currentPath);

      return signInState.when(
        loading: () {
          return null;
        },
        error: (error, stackTrace) {
          if (currentPath != AppRoutes.signInPage.path) {
            return AppRoutes.signInPage.path;
          }
          return null;
        },
        data: (auth) {
          if (auth.isSuccess) {
            if (currentPath == AppRoutes.initialPage.path || currentPath == AppRoutes.signInPage.path) {
              return AppRoutes.searchPage.path;
            }
          } else {
            if (currentPath == AppRoutes.initialPage.path) {
              return AppRoutes.signInPage.path;
            }
          }
          
          return null;
        },
      );
    },
    routes: [
      GoRoute(
        path: AppRoutes.initialPage.path,
        name: AppRoutes.initialPage.name,
        pageBuilder: (context, state) {
          return MaterialPage(
            key: state.pageKey,
            child: const RedirectIndicatorPage(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.signInPage.path,
        name: AppRoutes.signInPage.name,
        pageBuilder: (context, state) {
          return MaterialPage(
            key: state.pageKey,
            child: const SignInPage()
          );
        },
      ),
      GoRoute(
        path: AppRoutes.searchPage.path,
        name: AppRoutes.searchPage.name,
        pageBuilder: (context, state) {
          return MaterialPage(
            key: state.pageKey,
            child: const SearchPage(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.detailPage.path,
        name: AppRoutes.detailPage.name,
        pageBuilder: (context, state) {
          return MaterialPage(
            key: state.pageKey,
            child: RepoDetailsPage(repository: state.extra! as Repository),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.settingsPage.path,
        name: AppRoutes.settingsPage.name,
        pageBuilder: (context, state) {
          return MaterialPage(
            key: state.pageKey, 
            child: const SettingsPage()
          );
        },
      ),
    ],
    errorPageBuilder: (context, state) {
      return MaterialPage(
        key: state.pageKey,
        child: Scaffold(
          body: Center(
            child: Text(state.error.toString())
          )
        ),
      );
    },
  );
}
