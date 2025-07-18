import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_browser/core/providers/shared_prefs_cache_provider.dart';
import 'package:github_browser/core/routes/router_provider.dart';
import 'package:github_browser/features/settings_lang_switch/providers/language_provider.dart';
import 'package:github_browser/features/settings_theme_switch/providers/theme_mode_provider.dart';
import 'package:github_browser/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  await container.read(initSharedPrefsCacheProvider.future);

  runApp(
    UncontrolledProviderScope(
      container: container, 
      child: const MyApp()
    )
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(languageProvider).locale;
    final router = ref.watch(goRouterProvider);
    
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

      title: 'Github_browser',

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return supportedLocales.first;

        for (final supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }

        return supportedLocales.first;
      },

      themeMode: themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),

      routerConfig: router,
    );
  }
}
