# README
## 今回の修正にあたって
今回の修正について、yumemi様からのフィードバック内容と、自分自身で行ったリファクタリング内容一覧はIssueにて確認することができます。Issueに行ったことをタグですべてまとめています。
[Issue URL](https://github.com/Rerurate514/improved_github_browser/issues?q=is%3Aissue)

## 概要
これはGithubのリポジトリを検索することができるアプリです。主に、以下の内容を載せています。
- リポジトリ名
- オーナー
- 言語
- スター数
- ウォッチャー数
- フォーク数

情報の取得にはGithubAPIを使用しています。

## 開発概要
### 全体アーキテクチャ
このGitHubブラウザアプリケーションは、**フィーチャーファースト**アーキテクチャを採用し、**リポジトリパターン**と**プロバイダーパターン**を状態管理に活用しています。

### コアコンポーネント
#### アプリケーション構造
- **フィーチャーベースの構成**: コードは技術的レイヤーではなく、主に機能（repo_search, repo_details, settings_lang_switch, settings_theme_switch, github_auth）によって整理
- **コア**: 共有コンポーネント、環境設定、例外処理、ルーティングはcoreディレクトリに分離
- **ローカライゼーション**: ARBファイルと`flutter_localizations`を通じて英語と日本語のローカライゼーションをサポート
- **CI/CD**: GitHub Actionsワークフローを通した、テスト、リントの自動化

#### データフロー
- **リポジトリパターン**: データアクセスはリポジトリを通じて分離 例：github_repository.dart）
- **プロバイダーパターン**: 言語やテーマ設定などの機能に対してプロバイダーを使用した状態管理
- **エンティティクラス**: コード生成サポート（Freezedを使用）による構造化データモデル

#### 機能内訳
1. **リポジトリ検索**
    - GitHubリポジトリの検索と表示
    - 検索結果の視覚化のためのコンポーネントを使用
2. **リポジトリ詳細**
    - 選択されたリポジトリに関する詳細情報の表示
    - 情報表示のためのカードコンポーネント
3. **言語設定**
    - 言語切り替え（英語/日本語）のサポート
    - 言語設定の永続化
4. **テーマ設定**
    - ライト/ダークモードのサポート
    - テーマ設定の永続化
5. **GithubへのOAuth認証**
	- GithubをOAuthを通して認証

#### テスト
- **ユニットテスト**: ビジネスロジック、リポジトリ、プロバイダーのテスト
- **ウィジェットテスト**: UI要素の分離テスト
- **モックサポート**: 依存性のモック化にmockitoを使用

### 技術的特徴
- **状態管理**: 状態管理にRiverpodを使用
- **コード生成**: イミュータブルなデータクラスにFreezedを使用
- **画面遷移**: 画面遷移にはgo_routerを使用してロジックを統一化

## セットアップ
### 環境変数の設定
最初にプロジェクトルートに`.env`ファイルを作成する。

`.env.exmple`を参考にして`.env`ファイルにGithub personal access token key、またはGithubのOAuth AppsのClientIdとClientSecretを記入する。
おそらく、メールにて`.env`の中身が送信されているかと思います。

### 資格情報の生成
おそらく、メールにて`key.jks`と`key.properties`の中身が送信されているかと思います。
- `key.jks`は`android/app/`内に格納
- `key.properties`は`android/`直下に格納

### パッケージの取得と実行ファイルの生成
次に、以下のコマンド群を実行します。
```
fvm use 3.32.0
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter pub get
```

## システム要件
- Flutter 3.32.0
  - 使用しているバージョンはプロジェクトルートの`.fvmrc`に記載しています。
- Dart 3.8.0
- Android: API level 21以上
- iOS: 今回はiOSについて考慮していません。

### Dependencies
- cupertino_icons : 1.0.8
- freezed : 3.0.6
- build_runner : 2.4.15
- freezed_annotation : 3.0.0
- json_annotation : 4.9.0
- json_serializable : 6.9.4
- flutter_riverpod : 2.6.1
- shared_preferences : 2.5.3
- envied : 1.1.1
- mockito : 5.4.5
- intl : 0.20.2
- oauth2 : 2.0.3
- flutter_secure_storage : 9.2.4
- url_launcher : 6.3.1
- app_links : 6.4.0
- internet_connection_checker : 3.0.1
- go_router : 15.1.2
- flutter_hooks : 0.21.2
- hooks_riverpod : 2.6.1

### Dev Dependencies
- flutter_lints : 5.0.0
- envied_generator : 1.1.1

## ディレクトリ構成詳細
```
Directory structure:
└── rerurate514-improved_github_browser/
    ├── README.md
    ├── analysis_options.yaml
    ├── l10n.yaml
    ├── pubspec.lock
    ├── pubspec.yaml
    ├── .env.example
    ├── .fvmrc
    ├── .metadata
    ├── lib/
    │   ├── main.dart
    │   ├── core/
    │   │   ├── components/
    │   │   │   ├── info_chip.dart
    │   │   │   ├── search_field.dart
    │   │   │   └── toggle_button.dart
    │   │   ├── env/
    │   │   │   └── env.dart
    │   │   ├── exceptions/
    │   │   │   ├── domain_exception.dart
    │   │   │   └── github_api_exception.dart
    │   │   ├── providers/
    │   │   │   ├── navigator_key_provider.dart
    │   │   │   └── shared_prefs_cache_provider.dart
    │   │   ├── routes/
    │   │   │   ├── app_routes.dart
    │   │   │   ├── router.dart
    │   │   │   └── router_provider.dart
    │   │   └── utils/
    │   │       └── check_network_connection.dart
    │   ├── features/
    │   │   ├── github_auth/
    │   │   │   ├── components/
    │   │   │   │   └── signin_component.dart
    │   │   │   ├── entities/
    │   │   │   │   └── auth_result.dart
    │   │   │   ├── providers/
    │   │   │   │   ├── github_auth_repository_provider.dart
    │   │   │   │   ├── github_secure_repository_provider.dart
    │   │   │   │   ├── internet_connection_checker_provider.dart
    │   │   │   │   └── signin_state_provider.dart
    │   │   │   └── repositories/
    │   │   │       ├── github_auth_repository.dart
    │   │   │       └── secure_repository.dart
    │   │   ├── repo_details/
    │   │   │   ├── components/
    │   │   │   │   └── repository_info_card.dart
    │   │   │   └── entities/
    │   │   │       └── stats_item.dart
    │   │   ├── repo_search/
    │   │   │   ├── components/
    │   │   │   │   ├── repo_list_item.dart
    │   │   │   │   └── repo_result_view.dart
    │   │   │   ├── entities/
    │   │   │   │   ├── repository.dart
    │   │   │   │   ├── repository.freezed.dart
    │   │   │   │   └── repository.g.dart
    │   │   │   ├── providers/
    │   │   │   │   ├── api_token_provider.dart
    │   │   │   │   ├── github_repository_provider.dart
    │   │   │   │   ├── search_state_notifier.dart
    │   │   │   │   └── search_state_provider.dart
    │   │   │   └── repositories/
    │   │   │       └── github_repository.dart
    │   │   ├── settings_lang_switch/
    │   │   │   ├── components/
    │   │   │   │   └── language_setting_buttons.dart
    │   │   │   ├── entities/
    │   │   │   │   ├── langs.dart
    │   │   │   │   └── language.dart
    │   │   │   ├── providers/
    │   │   │   │   ├── language_provider.dart
    │   │   │   │   └── language_repositry_provider.dart
    │   │   │   └── repositories/
    │   │   │       └── language_repository.dart
    │   │   └── settings_theme_switch/
    │   │       ├── components/
    │   │       │   └── theme_settings_toggle.dart
    │   │       ├── providers/
    │   │       │   ├── theme_mode_provider.dart
    │   │       │   └── theme_repository_provider.dart
    │   │       └── repositories/
    │   │           └── theme_repository.dart
    │   ├── l10n/
    │   │   ├── app_en.arb
    │   │   └── app_ja.arb
    │   └── pages/
    │       ├── redirect_indicator_page.dart
    │       ├── repo_detail_page.dart
    │       ├── search_page.dart
    │       ├── settings_page.dart
    │       └── signin_page.dart
    ├── test/
    │   ├── unit/
    │   │   └── features/
    │   │       ├── github_auth/
    │   │       │   ├── entities/
    │   │       │   │   └── auth_result_test.dart
    │   │       │   ├── providers/
    │   │       │   │   └── signin_state_provider_test.dart
    │   │       │   └── repositories/
    │   │       │       ├── github_auth_repository_test.dart
    │   │       │       └── secure_repository_test.dart
    │   │       ├── repo_search/
    │   │       │   ├── entities/
    │   │       │   │   └── repository_test.dart
    │   │       │   ├── providers/
    │   │       │   │   └── search_state_notifier_test.dart
    │   │       │   └── repositories/
    │   │       │       ├── github_repository_test.dart
    │   │       ├── settings_switch_language/
    │   │       │   ├── providers/
    │   │       │   │   └── language_provider_test.dart
    │   │       │   └── repositories/
    │   │       │       └── language_repository_test.dart
    │   │       └── settings_switch_theme/
    │   │           ├── providers/
    │   │           │   └── theme_mode_provider_test.dart
    │   │           └── repositories/
    │   │               └── theme_repository_test.dart
    │   └── widget/
    │       ├── core/
    │       │   ├── components/
    │       │   │   └── search_field_test.dart
    │       │   └── routes/
    │       │       └── router_test.dart
    │       └── features/
    │           ├── github_auth/
    │           │   └── components/
    │           │       └── signin_component_test.dart
    │           ├── repo_search/
    │           │   └── components/
    │           │       └── repo_result_view_test.dart
    │           ├── settings_switch_language/
    │           │   └── components/
    │           │       └── language_setting_buttons_test.dart
    │           └── settings_switch_theme/
    │               └── components/
    │                   └── theme_setting_toggle_test.dart
    ├── .fvm/
    │   └── fvm_config.json
    └── .github/
        ├── pull_request_template.md
        ├── ISSUE_TEMPLATE/
        │   ├── feature_request.md
        │   └── fix_template.md
        └── workflows/
            └── flutter_ci.yml
```
