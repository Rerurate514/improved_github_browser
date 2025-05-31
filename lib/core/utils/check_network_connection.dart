  import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_browser/core/providers/navigator_key_provider.dart';
import 'package:github_browser/features/github_auth/providers/internet_connection_checker_provider.dart';

Future<bool> checkNetworkConnection(
  {
    required Ref<dynamic> ref, 
    required void Function(BuildContext?) isNotConnectedHandler
  }
) async {
    final checker = ref.read(internetConnectionCheckerProvider);
    final bool isConnected = await checker.hasConnection;

    if (!isConnected) {
      final navigatorKey = ref.read(navigatorKeyProvider);
      final context = navigatorKey.currentContext;
      
      // ignore: use_build_context_synchronously
      isNotConnectedHandler(context);
    }

    return isConnected;
  }
