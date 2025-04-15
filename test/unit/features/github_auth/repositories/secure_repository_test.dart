import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_browser/features/github_auth/repositories/secure_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([FlutterSecureStorage])
import 'secure_repository_test.mocks.dart';

void main() {
  late GithubSecureRepository repository;
  late MockFlutterSecureStorage mockSecureStorage;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockSecureStorage = MockFlutterSecureStorage();
    
    repository = GithubSecureRepository(
      storage: mockSecureStorage
    );
  });

  group('GithubSecureRepository Tests', () {
    test('saveTokenは正しいパラメータでセキュアストレージのwriteを呼び出すこと', () async {
      const String token = 'test_token';
      when(mockSecureStorage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((_) => Future.value());

      await repository.saveToken(token);

      verify(mockSecureStorage.write(key: 'github_auth_token', value: token)).called(1);
    });

    test('getTokenは正しいキーでセキュアストレージのreadを呼び出すこと', () async {
      const String expectedToken = 'test_token';
      when(mockSecureStorage.read(key: anyNamed('key')))
          .thenAnswer((_) => Future.value(expectedToken));

      final result = await repository.getToken();

      expect(result, equals(expectedToken));
      verify(mockSecureStorage.read(key: 'github_auth_token')).called(1);
    });

    test('deleteTokenは正しいキーでセキュアストレージのdeleteを呼び出すこと', () async {
      when(mockSecureStorage.delete(key: anyNamed('key')))
          .thenAnswer((_) => Future.value());

      await repository.deleteToken();

      verify(mockSecureStorage.delete(key: 'github_auth_token')).called(1);
    });
  });
}
