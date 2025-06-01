import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_browser/features/settings_lang_switch/entities/language.dart';
import 'package:github_browser/features/settings_lang_switch/providers/language_provider.dart';
import 'package:github_browser/features/settings_lang_switch/providers/language_repositry_provider.dart';
import 'package:github_browser/features/settings_lang_switch/repositories/language_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([LanguageRepository])
import 'language_provider_test.mocks.dart';

void main() {
  late MockLanguageRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockLanguageRepository();

    when(mockRepository.loadLang()).thenAnswer((_) async => Language.japanese);

    container = ProviderContainer(
      overrides: [languageRepositoryProvider.overrideWithValue(mockRepository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group("language_provider", () {
    test('初期状態はLanguage.japaneseであること', () async {
      expect(container.read(languageProvider), Language.japanese);

      await Future<dynamic>.delayed(Duration.zero);

      verify(mockRepository.loadLang()).called(1);
    });

    test('setThemeModeを呼び出すと、リポジトリが更新され状態が変わること', () async {
      when(mockRepository.saveLang(any)).thenAnswer((_) async {});

      await container.read(languageProvider.notifier).setLanguage(Language.japanese);

      verify(mockRepository.saveLang(Language.japanese)).called(1);

      expect(container.read(languageProvider), Language.japanese);
    });
  });
}
