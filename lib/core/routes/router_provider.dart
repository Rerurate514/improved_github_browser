import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_browser/core/providers/navigator_key_provider.dart';
import 'package:github_browser/core/routes/router.dart';
import 'package:go_router/go_router.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final navigatorKey = ref.read(navigatorKeyProvider);
  return createGoRouter(navigatorKey, ref);
});
