import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class GithubSecureRepository{
  final FlutterSecureStorage _secureStorage;
  static const String _tokenKey = 'github_auth_token';

  GithubSecureRepository({FlutterSecureStorage? storage})
    : _secureStorage = storage ?? const FlutterSecureStorage();


  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }
}
