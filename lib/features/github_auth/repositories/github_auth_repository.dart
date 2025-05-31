import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:github_browser/features/github_auth/entities/auth_result.dart';
import 'package:oauth2/oauth2.dart';
import 'package:github_browser/core/env/env.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart';
import 'dart:convert';

class GithubAuthRepository {
  final Uri authorizationEndpoint = Uri.parse('https://github.com/login/oauth/authorize');
  final Uri tokenEndpoint = Uri.parse('https://github.com/login/oauth/access_token');
  
  final String clientId;
  final String clientSecret;
  final Uri redirectUrl;
  
  final List<String> scopes;

  final AppLinks appLinks;
  final UrlLauncher urlLauncher;
  
  StreamSubscription<dynamic>? _linkSubscription;
  
  GithubAuthRepository({
    String? clientId,
    String? clientSecret,
    String? redirectUrl,
    List<String>? scopes,
    AppLinks? appLinks,
    UrlLauncher? urlLauncher,
  }) : 
    clientId = clientId ?? Env.clientId,
    clientSecret = clientSecret ?? Env.clientSecret,
    redirectUrl = Uri.parse(redirectUrl ?? Env.redirectUrl),
    scopes = scopes ?? ['repo', 'user'],
    appLinks = appLinks ?? AppLinks(),
    urlLauncher = urlLauncher ?? DefaultUrlLauncher();
  
  Future<AuthResult> signIn() async {

    if(Env.apiKey != ""){
      return AuthResult.success(Env.apiKey);
    }

    try {
      final grant = AuthorizationCodeGrant(
        clientId, 
        authorizationEndpoint, 
        tokenEndpoint,
        secret: clientSecret,
        basicAuth: false,
      );

      log('使用するリダイレクトURL: $redirectUrl');
      final authorizationUrl = grant.getAuthorizationUrl(redirectUrl, scopes: scopes);
      log('GitHub認証URL: $authorizationUrl');

      await _redirectToBrowser(authorizationUrl);
      
      log('リダイレクトを待機中...');
      final responseUrl = await _listenForAppLink();
      log('リダイレクトURLを受信: $responseUrl');
      
      log('認証レスポンスを処理中...');
      log('レスポンスパラメータ: ${responseUrl.queryParameters}');

      final code = responseUrl.queryParameters['code'];
      if (code == null) return AuthResult.failure("responseUrl.queryParameters code is null");
      
      final response = await post(
        tokenEndpoint,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'client_id': clientId,
          'client_secret': clientSecret,
          'code': code,
          'redirect_uri': redirectUrl.toString(),
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final accessToken = data['access_token'];
        
        return AuthResult.success(accessToken);
      } else {
        throw Exception('Failed to get access token: ${response.body}');
      }
    } catch (e, stackTrace) {
      log('認証プロセス中にエラーが発生しました: $e');
      log('スタックトレース: $stackTrace');
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

abstract class UrlLauncher {
  Future<bool> launch(Uri url, {LaunchMode mode});
}

class DefaultUrlLauncher implements UrlLauncher {
  @override
  Future<bool> launch(Uri url, {LaunchMode mode = LaunchMode.platformDefault}) {
    return launchUrl(url, mode: mode);
  }
}
