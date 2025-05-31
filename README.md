# README
## 概要
これはGithubのリポジトリを検索することができるアプリです。主に、以下の内容を載せています。
- リポジトリ名
- オーナー
- 言語
- スター数
- ウォッチャー数
- フォーク数

情報の取得にはGithubAPIを使用しています。

## Architecture
```
Directory structure:
└── rerurate514-github_browser/
    ├── README.md
    ├── analysis_options.yaml
    ├── pubspec.lock
    ├── pubspec.yaml
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
    │   │   └── routes/
    │   │       └── page_router.dart
    │   ├── features/
    │   │   ├── github_auth/
    │   │   │   ├── components/
    │   │   │   │   └── auth_wrapper.dart
    │   │   │   ├── entities/
    │   │   │   │   └── auth_result.dart
    │   │   │   └── repositories/
    │   │   │       ├── github_auth_repository.dart
    │   │   │       └── secure_repository.dart
    │   │   ├── repo_details/
    │   │   │   └── components/
    │   │   │       └── repository_info_card.dart
    │   │   ├── repo_search/
    │   │   │   ├── components/
    │   │   │   │   ├── repo_list_item.dart
    │   │   │   │   └── repo_result_view.dart
    │   │   │   ├── entities/
    │   │   │   │   ├── repository.dart
    │   │   │   │   ├── repository.freezed.dart
    │   │   │   │   └── repository.g.dart
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
    │       ├── repo_detail_page.dart
    │       ├── search_page.dart
    │       └── settings_page.dart
    ├── test/
    │   ├── unit/
    │   │   └── features/
    │   │       ├── github_auth/
    │   │       │   ├── entities/
    │   │       │   │   └── auth_result_test.dart
    │   │       │   └── repositories/
    │   │       │       ├── github_auth_repository_test.dart
    │   │       │       └── secure_repository_test.dart
    │   │       ├── repo_search/
    │   │       │   ├── entities/
    │   │       │   │   └── repository_test.dart
    │   │       │   └── repositories/
    │   │       │       ├── github_repository_test.dart
    │   │       │       └── github_repository_test.mocks.dart
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
    │       └── features/
    │           ├── github_auth/
    │           │   └── components/
    │           │       └── auth_wrapper_test.dart
    │           ├── settings_switch_language/
    │           │   └── components/
    │           │       └── language_setting_buttons_test.dart
    │           └── settings_switch_theme/
    │               └── components/
    │                   └── theme_setting_toggle_test.dart
    └── .github/
        ├── pull_request_template.md
        ├── ISSUE_TEMPLATE/
        │   └── feature_request.md
        └── workflows/
            └── flutter_ci.yml
```

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

## セットアップ
### 環境変数の設定
最初にプロジェクトルートに`.env`ファイルを作成する。

`.env.exmple`を参考にして`.env`ファイルにGithub personal access token key、またはGithubのOAuth AppsのClientIdとClientSecretを記入する。
おそらく、メールにて`.env`の中身が送信されているかと思います。

### パッケージの取得と実行ファイルの生成
次に、以下のコマンド群を実行する。
```
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter pub get
```

### 資格情報の生成
おそらく、メールにて`key.jks`と`key.properties`の中身が送信されているかと思います。
- `key.jks`は`android/app/`内に格納
- `key.properties`は`android/`直下に格納

## 使用しているバージョン情報
### Core
- flutter : 3.32.0
    - 使用しているバージョンはプロジェクトルートの`.fvmrc`に記載しています。
- SDK : 3.7.2

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

### Dev Dependencies
- flutter_lints : 5.0.0
- envied_generator : 1.1.1
