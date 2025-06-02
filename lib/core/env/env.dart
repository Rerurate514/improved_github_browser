import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'API_KEY', obfuscate: true)
  static String apiKey = _Env.apiKey;

  @EnviedField(varName: 'CLIENT_ID', obfuscate: true)
  static String clientId = _Env.clientId;

  @EnviedField(varName: 'CLIENT_SECRET', obfuscate: true)
  static String clientSecret = _Env.clientSecret;

  @EnviedField(varName: 'REDIRECT_URL')
  static String redirectUrl = _Env.redirectUrl;
}
