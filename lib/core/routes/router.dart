import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_browser/features/github_auth/providers/signin_state_provider.dart';
import 'package:github_browser/features/repo_search/entities/repository.dart';
import 'package:github_browser/pages/repo_detail_page.dart';
import 'package:github_browser/pages/search_page.dart';
import 'package:github_browser/pages/settings_page.dart';
import 'package:github_browser/pages/signin_page.dart';
import 'package:go_router/go_router.dart';

GoRouter createGoRouter(
  GlobalKey<NavigatorState> navigatorKey,
  WidgetRef ref,
) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final signInState = ref.watch(signinStateProvider);
      
      return signInState.when(
        loading: () {
          return null;
        },
        error: (error, stackTrace) {
          if (state.matchedLocation != '/signin') {
            return '/signin';
          }
          return null;
        },
        data: (auth) {
          if (auth.isSuccess) {
            if (state.matchedLocation == '/' || state.matchedLocation == '/signin') {
              return '/repository-search';
            }
          } else {
            if (state.matchedLocation != '/signin') {
              return '/signin';
            }
          }
          return null;
        },
      );
    },
    routes: [
      GoRoute(
        path: '/',
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
        path: '/signin',
        name: 'signin',
        pageBuilder: (context, state) {
          return MaterialPage(
            key: state.pageKey,
            child: const SignInPage()
          );
        },
      ),
      GoRoute(
        path: '/repository-search',
        name: 'repositorySearch',
        pageBuilder: (context, state) {
          return MaterialPage(
            key: state.pageKey,
            child: const SearchPage(),
          );
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
