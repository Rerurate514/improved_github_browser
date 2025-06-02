import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_browser/features/github_auth/providers/signin_state_provider.dart';
import 'package:github_browser/l10n/app_localizations.dart';

class RedirectIndicatorPage extends ConsumerStatefulWidget {
  const RedirectIndicatorPage({super.key});

  @override
  ConsumerState<RedirectIndicatorPage> createState() => _RedirectIndicatorPageState();
}

class _RedirectIndicatorPageState extends ConsumerState<RedirectIndicatorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 200),
              const CircularProgressIndicator(),
              const SizedBox(height: 128),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(signinStateProvider.notifier).signIn();
                },
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context).button_retry),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  minimumSize: const Size(200, 0),
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}
