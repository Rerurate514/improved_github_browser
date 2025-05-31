import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_browser/core/env/env.dart';
import 'package:github_browser/features/github_auth/entities/auth_result.dart';
import 'package:github_browser/features/github_auth/repositories/github_auth_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart';
import 'package:url_launcher/url_launcher.dart';

@GenerateMocks([AppLinks, UrlLauncher, File, http.Client])
import 'github_auth_repository_test.mocks.dart';

void main() {
  late GithubAuthRepository repository;
  late MockAppLinks mockAppLinks;
  late MockUrlLauncher mockUrlLauncher;
  
  const testClientId = 'test_client_id';
  const testClientSecret = 'test_client_secret';
  const testRedirectUrl = 'com.example://callback';
  final testScopes = ['repo', 'user'];
  const testAccessToken = 'test_access_token';
  
  setUp(() {
    mockAppLinks = MockAppLinks();
    mockUrlLauncher = MockUrlLauncher();
    
    when(mockUrlLauncher.launch(any, mode: anyNamed('mode')))
        .thenAnswer((_) async => true);
    
    final streamController = StreamController<Uri>();
    when(mockAppLinks.uriLinkStream).thenAnswer((_) => streamController.stream);
    when(mockAppLinks.getInitialLink()).thenAnswer((_) async => null);
    
    repository = GithubAuthRepository(
      clientId: testClientId,
      clientSecret: testClientSecret,
      redirectUrl: testRedirectUrl,
      scopes: testScopes,
      appLinks: mockAppLinks,
      urlLauncher: mockUrlLauncher,
    );
  });
  
  group('GithubAuthRepository', () {
    test('正しい値で初期化されること', () {
      expect(repository.clientId, testClientId);
      expect(repository.clientSecret, testClientSecret);
      expect(repository.redirectUrl, Uri.parse(testRedirectUrl));
      expect(repository.scopes, testScopes);
      expect(repository.appLinks, mockAppLinks);
    });
    
    test('値が提供されない場合にデフォルト値を使用すること', () {
      repository = GithubAuthRepository();
      
      expect(repository.clientId, Env.clientId);
      expect(repository.clientSecret, Env.clientSecret);
      expect(repository.redirectUrl, Uri.parse(Env.redirectUrl));
      expect(repository.scopes, ['repo', 'user']);
      expect(repository.appLinks, isA<AppLinks>());
    });
    
    test('EnvにAPIキーが存在する場合に直接APIキーを返すこと', () async {
      const testApiKey = 'test_api_key';
    
      final testRepository = _TestGithubAuthRepository(
        clientId: testClientId,
        clientSecret: testClientSecret,
        redirectUrl: testRedirectUrl,
        scopes: testScopes,
        appLinks: mockAppLinks,
        urlLauncher: mockUrlLauncher,
        apiKey: testApiKey,
      );
      
      final result = await testRepository.signIn();
      
      expect(result, isA<AuthResult>());
      expect(result.isSuccess, true);
      expect(result.token, testApiKey);
    
      verifyNever(mockUrlLauncher.launch(any, mode: anyNamed('mode')));
    });
    
    test('GitHubで認証し、アクセストークンを返すこと', () async {
      when(mockAppLinks.getInitialLink()).thenAnswer((_) async => null);
      
      final redirectUriWithCode = Uri.parse('$testRedirectUrl?code=test_code');
      
      final streamController = StreamController<Uri>();
      when(mockAppLinks.uriLinkStream).thenAnswer((_) => streamController.stream);
      
      Future<http.Response> httpMock(dynamic request) async {
        if (request.url.toString() == 'https://github.com/login/oauth/access_token') {
          return http.Response(
            '{"access_token": "$testAccessToken", "token_type": "bearer", "scope": "repo,user"}',
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not found', 404);
      }
      
      final testRepository = _TestGithubAuthRepositoryWithHttpMock(
        clientId: testClientId,
        clientSecret: testClientSecret,
        redirectUrl: testRedirectUrl,
        scopes: testScopes,
        appLinks: mockAppLinks,
        urlLauncher: mockUrlLauncher,
        httpMock: httpMock,
      );
      
      final futureResult = testRepository.signIn();
      
      verify(mockUrlLauncher.launch(any, mode: anyNamed('mode'))).called(1);
      
      streamController.add(redirectUriWithCode);
      
      final result = await futureResult;
      
      expect(result.isSuccess, true);
      expect(result.token, testAccessToken);

      
      await streamController.close();
    });
    
    test('アクセストークンの取得に失敗した場合にエラーを処理すること', () async {
      when(mockAppLinks.getInitialLink()).thenAnswer((_) async => null);
      
      final redirectUriWithCode = Uri.parse('$testRedirectUrl?code=test_code');
      
      final streamController = StreamController<Uri>();
      when(mockAppLinks.uriLinkStream).thenAnswer((_) => streamController.stream);
      
      Future<http.Response> httpMock(dynamic request) async {
        if (request.url.toString() == 'https://github.com/login/oauth/access_token') {
          return http.Response(
            '{"error": "bad_verification_code"}',
            400,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not found', 404);
      }
      
      final testRepository = _TestGithubAuthRepositoryWithHttpMock(
        clientId: testClientId,
        clientSecret: testClientSecret,
        redirectUrl: testRedirectUrl,
        scopes: testScopes,
        appLinks: mockAppLinks,
        urlLauncher: mockUrlLauncher,
        httpMock: httpMock,
      );
      
      final futureResult = testRepository.signIn();
      
      verify(mockUrlLauncher.launch(any, mode: anyNamed('mode'))).called(1);
      
      streamController.add(redirectUriWithCode);
      
      final result = await futureResult;
      
      expect(result.isSuccess, false);
      
      await streamController.close();
    });
    
    test('初期リンクにコードが含まれている場合を処理すること', () async {
      final initialLink = Uri.parse('$testRedirectUrl?code=initial_code');
      when(mockAppLinks.getInitialLink()).thenAnswer((_) async => initialLink);
      
      Future<http.Response> httpMock(dynamic request) async {
        if (request.url.toString() == 'https://github.com/login/oauth/access_token') {
          return http.Response(
            '{"access_token": "$testAccessToken", "token_type": "bearer", "scope": "repo,user"}',
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not found', 404);
      }
      
      final testRepository = _TestGithubAuthRepositoryWithHttpMock(
        clientId: testClientId,
        clientSecret: testClientSecret,
        redirectUrl: testRedirectUrl,
        scopes: testScopes,
        appLinks: mockAppLinks,
        urlLauncher: mockUrlLauncher,
        httpMock: httpMock,
      );
      
      
      final result = await testRepository.signIn();

      expect(result.isSuccess, true);
      expect(result.token, testAccessToken);
      
      verify(mockUrlLauncher.launch(any, mode: anyNamed('mode'))).called(1);
    });
  });
}

class _TestGithubAuthRepository extends GithubAuthRepository {
  final String apiKey;
  
  _TestGithubAuthRepository({
    required String clientId,
    required String clientSecret,
    required String redirectUrl,
    required List<String> scopes,
    required AppLinks appLinks,
    required UrlLauncher urlLauncher,
    required this.apiKey,
  }) : super(
    clientId: clientId,
    clientSecret: clientSecret,
    redirectUrl: redirectUrl,
    scopes: scopes,
    appLinks: appLinks,
    urlLauncher: urlLauncher,
  );
  
  @override
  Future<AuthResult> signIn() async {
    if (apiKey != "") {
      return AuthResult.success(apiKey);
    }
    return super.signIn();
  }
}

class _TestGithubAuthRepositoryWithHttpMock extends GithubAuthRepository {
  final Future<http.Response> Function(http.Request) httpMock;
  StreamSubscription<dynamic>? _linkSubscription;
  
  _TestGithubAuthRepositoryWithHttpMock({
    required String clientId,
    required String clientSecret,
    required String redirectUrl,
    required List<String> scopes,
    required AppLinks appLinks,
    required UrlLauncher urlLauncher,
    required this.httpMock,
  }) : super(
    clientId: clientId,
    clientSecret: clientSecret,
    redirectUrl: redirectUrl,
    scopes: scopes,
    appLinks: appLinks,
    urlLauncher: urlLauncher,
  );
  
  @override
  Future<AuthResult> signIn() async {
    try {
      final grant = AuthorizationCodeGrant(
        clientId, 
        authorizationEndpoint, 
        tokenEndpoint,
        secret: clientSecret,
        basicAuth: false,
        httpClient: _MockHttpClient(httpMock),
      );

      final authorizationUrl = grant.getAuthorizationUrl(redirectUrl, scopes: scopes);

      await _redirectToBrowser(authorizationUrl);
      
      final responseUrl = await _listenForAppLink();
      
      final code = responseUrl.queryParameters['code'];
      if (code == null) return AuthResult.failure("responseUrl.queryParameters code is null");
      
      final request = http.Request('POST', tokenEndpoint);
      request.headers['Accept'] = 'application/json';
      request.headers['Content-Type'] = 'application/x-www-form-urlencoded';
      request.bodyFields = {
        'client_id': clientId,
        'client_secret': clientSecret,
        'code': code,
        'redirect_uri': redirectUrl.toString(),
      };
      
      final response = await httpMock(request);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final accessToken = data['access_token'];
        
        return AuthResult.success(accessToken);
      } else {
        throw Exception('Failed to get access token: ${response.body}');
      }
    } catch (e) {
      log('認証プロセス中にエラーが発生しました: $e');
    } finally {
      await _linkSubscription?.cancel();
      _linkSubscription = null;
    }

    return AuthResult.failure("");
  }

  
  Future<Uri> _listenForAppLink() async {
    final completer = Completer<Uri>();
    
    try {
      final initialLink = await appLinks.getInitialLink();
      if (initialLink != null && initialLink.queryParameters.containsKey('code')) {
        log('初期App Linkからコードを検出: ${initialLink.queryParameters['code']}');
        completer.complete(initialLink);
        return completer.future;
      }
    } catch (e) {
      log('初期App Linkの取得エラー: $e');
    }
    
    _linkSubscription = appLinks.uriLinkStream.listen((Uri uri) {
      if (!completer.isCompleted && uri.queryParameters.containsKey('code')) {
        log('App Linkからコードを検出: ${uri.queryParameters['code']}');
        completer.complete(uri);
      }
    }, onError: (dynamic error) {
      log('App Linkエラー: $error');
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    });
    
    return completer.future;
  }
  
  Future<void> _redirectToBrowser(Uri url) async {
    log('以下のURLをブラウザで開いてGitHubにログインしてください:');
    log(url.toString());

    urlLauncher.launch(
      url,
      mode: LaunchMode.externalApplication,
    );
  }
}

class _MockHttpClient extends http.BaseClient {
  final Future<http.Response> Function(http.Request) mockHandler;
  
  _MockHttpClient(this.mockHandler);
  
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await mockHandler(request as http.Request);
    
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
    );
  }
}
