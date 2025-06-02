import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_browser/core/routes/app_routes.dart';
import 'package:github_browser/features/github_auth/providers/signin_state_provider.dart';
import 'package:github_browser/features/repo_search/entities/repository.dart';
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
    initialLocation: AppRoutes.initialPage,
    redirect: (context, state) {
      final signInState = ref.watch(signinStateProvider);
      final currentPath = state.matchedLocation;

      log(currentPath);

      return signInState.when(
        loading: () {
          return null;
        },
        error: (error, stackTrace) {
          if (currentPath != AppRoutes.signInPage) {
            return AppRoutes.signInPage;
          }
          return null;
        },
        data: (auth) {
          if (auth.isSuccess) {
            if (currentPath == AppRoutes.initialPage || currentPath == AppRoutes.signInPage) {
              return AppRoutes.searchPage;
            }
          } else {
            if (currentPath == AppRoutes.initialPage) {
              return AppRoutes.signInPage;
            }
          }
          
          return null;
        },
      );
    },
    routes: [
      GoRoute(
        path: AppRoutes.initialPage,
        name: 'initial',
        pageBuilder: (context, state) {
          return const MaterialPage(
            child: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.signInPage,
        name: 'signin',
        pageBuilder: (context, state) {
          return MaterialPage(
            key: state.pageKey,
            child: const SignInPage()
          );
        },
      ),
      GoRoute(
        path: AppRoutes.searchPage,
        name: 'repositorySearch',
        pageBuilder: (context, state) {
          return MaterialPage(
            key: state.pageKey,
            child: const SearchPage(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.detailPage,
        name: 'repositoryDetail',
        pageBuilder: (context, state) {
          return MaterialPage(
            key: state.pageKey,
            child: RepoDetailsPage(repository: state.extra! as Repository),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.settingsPage,
        name: 'setting',
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
