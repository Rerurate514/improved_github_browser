import 'package:flutter_test/flutter_test.dart';
import 'package:github_browser/features/github_auth/entities/auth_result.dart';

void main() {
  group('AuthResult', () {
    test('必須パラメータでインスタンスを作成できること', () {
      final result = AuthResult(isSuccess: true);

      expect(result.isSuccess, true);
      expect(result.token, isNull);
      expect(result.errorMessage, isNull);
      expect(result.userProfile, isNull);
    });

    test('すべてのパラメータでインスタンスを作成できること', () {
      final Map<String, dynamic> userProfile = {
        'id': 1,
        'name': 'Test User',
        'email': 'test@example.com'
      };

      final result = AuthResult(
        isSuccess: true,
        token: 'test_token',
        errorMessage: 'test_error',
        userProfile: userProfile
      );

      expect(result.isSuccess, true);
      expect(result.token, 'test_token');
      expect(result.errorMessage, 'test_error');
      expect(result.userProfile, userProfile);
    });

    group('factory constructors', () {
      test('AuthResult.successはトークン付きの成功インスタンスを作成すること', () {
        final result = AuthResult.success('test_token');

        expect(result.isSuccess, true);
        expect(result.token, 'test_token');
        expect(result.errorMessage, isNull);
        expect(result.userProfile, isNull);
      });

      test('AuthResult.failureはエラーメッセージ付きの失敗インスタンスを作成すること', () {
        final result = AuthResult.failure('Authentication failed');

        expect(result.isSuccess, false);
        expect(result.token, isNull);
        expect(result.errorMessage, 'Authentication failed');
        expect(result.userProfile, isNull);
      });
    });
  });
}
