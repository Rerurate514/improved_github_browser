import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:github_browser/features/github_auth/entities/auth_result.dart';
import 'package:oauth2/oauth2.dart';
import 'package:github_browser/core/env/env.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:github_browser/core/env/env.dart';

class GithubAuthRepository {
  final Uri authorizationEndpoint = Uri.parse('https://github.com/login/oauth/authorize');
  final Uri tokenEndpoint = Uri.parse('https://github.com/login/oauth/access_token');
  
  final String clientId;
  final String clientSecret;
  final Uri redirectUrl;
  
  final List<String> scopes;
  final File credentialsFile;
  
  final AppLinks _appLinks = AppLinks();
  StreamSubscription? _linkSubscription;
  
  GithubAuthRepository({
    String? clientId,
    String? clientSecret,
    String? redirectUrl,
    List<String>? scopes,
    String? credentialsPath,
  }) : 
    clientId = clientId ?? Env.clientId,
    clientSecret = clientSecret ?? Env.clientSecret,
    redirectUrl = Uri.parse(redirectUrl ?? Env.redirectUrl),
    scopes = scopes ?? ['repo', 'user'],
    credentialsFile = File(credentialsPath ?? 'credentials.json');
  
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

      debugPrint('使用するリダイレクトURL: $redirectUrl');
      final authorizationUrl = grant.getAuthorizationUrl(redirectUrl, scopes: scopes);
      debugPrint('GitHub認証URL: $authorizationUrl');

      await _redirectToBrowser(authorizationUrl);
      
      debugPrint('リダイレクトを待機中...');
      final responseUrl = await _listenForAppLink();
      debugPrint('リダイレクトURLを受信: $responseUrl');
      
      debugPrint('認証レスポンスを処理中...');
      debugPrint('レスポンスパラメータ: ${responseUrl.queryParameters}');

      final code = responseUrl.queryParameters['code'];
      if (code != null) {
        final response = await http.post(
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
      }
    } catch (e, stackTrace) {
      debugPrint('認証プロセス中にエラーが発生しました: $e');
      debugPrint('スタックトレース: $stackTrace');
    } finally {
      await _linkSubscription?.cancel();
      _linkSubscription = null;
    }

    return AuthResult.failure("");
  }
  
  Future<Uri> _listenForAppLink() async {
    final completer = Completer<Uri>();
    
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null && initialLink.queryParameters.containsKey('code')) {
        debugPrint('初期App Linkからコードを検出: ${initialLink.queryParameters['code']}');
        completer.complete(initialLink);
        return completer.future;
      }
    } catch (e) {
      debugPrint('初期App Linkの取得エラー: $e');
    }
    
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
      if (!completer.isCompleted && uri.queryParameters.containsKey('code')) {
        debugPrint('App Linkからコードを検出: ${uri.queryParameters['code']}');
        completer.complete(uri);
      }
    }, onError: (error) {
      debugPrint('App Linkエラー: $error');
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    });
    
    return completer.future;
  }
  
  Future<void> _redirectToBrowser(Uri url) async {
    debugPrint('以下のURLをブラウザで開いてGitHubにログインしてください:');
    debugPrint(url.toString());

    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }
}
