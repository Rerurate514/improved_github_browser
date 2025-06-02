enum AppRoutes {
  initialPage,
  signInPage,
  searchPage,
  detailPage,
  settingsPage,
}

extension AppRoutesExtension on AppRoutes {
  String get path {
    switch (this) {
      case AppRoutes.initialPage:
        return "/";
      case AppRoutes.signInPage:
        return "/signin";
      case AppRoutes.searchPage:
        return "/repository-search";
      case AppRoutes.detailPage:
        return "/repository-detail";
      case AppRoutes.settingsPage:
        return "/setting";
    }
  }

  String get name {
    switch (this) {
      case AppRoutes.initialPage:
        return "initial";
      case AppRoutes.signInPage:
        return "signin";
      case AppRoutes.searchPage:
        return "repositorySearch";
      case AppRoutes.detailPage:
        return "repositoryDetail";
      case AppRoutes.settingsPage:
        return "setting";
    }
  }
}
