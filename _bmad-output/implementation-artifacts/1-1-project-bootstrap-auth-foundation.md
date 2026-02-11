# Story 1.1: プロジェクト初期化と認証基盤セットアップ

Status: ready-for-dev

## Story

As a 開発者,
I want Expo tabsテンプレートとSupabase Auth接続を初期化したい,
So that 認証機能を安全に実装開始できる。

## Acceptance Criteria

1. **AC1: Expo tabs テンプレート初期化**
   - `npx create-expo-app@latest myakashic-app --template tabs` 相当の構成が完成していること
   - Expo Router によるファイルベースルーティングが動作すること
   - TypeScript が有効で `strict: true` であること

2. **AC2: Supabase クライアント接続**
   - `@supabase/supabase-js` がインストールされていること
   - Supabase クライアントが `src/infrastructure/supabase/client.ts` に作成されていること
   - 環境変数 `EXPO_PUBLIC_SUPABASE_URL` と `EXPO_PUBLIC_SUPABASE_ANON_KEY` で設定可能であること
   - `.env.example` に必要な環境変数がドキュメント化されていること

3. **AC3: 認証セッション初期化**
   - アプリ起動時に Supabase Auth セッション確認処理が実行されること
   - セッション状態に応じて認証済み/未認証の画面分岐が動作すること
   - セッション永続化に `expo-secure-store` または `@react-native-async-storage/async-storage` を使用すること

4. **AC4: 環境変数バリデーション**
   - 必須環境変数（`EXPO_PUBLIC_SUPABASE_URL`, `EXPO_PUBLIC_SUPABASE_ANON_KEY`）の不足時に明示エラーが表示されること
   - 起動時にクラッシュせず、設定不足を開発者に通知すること

5. **AC5: Clean Architecture ディレクトリ構造**
   - `src/` 配下に `domain/`, `application/`, `infrastructure/`, `presentation/`, `shared/` のレイヤが作成されていること
   - 各レイヤの責務が明確に分離されていること

6. **AC6: アプリ正常起動**
   - `npx expo start` でアプリが正常に起動すること
   - Web / iOS / Android の3プラットフォームでエラーなく画面表示されること

## Tasks / Subtasks

- [ ] Task 1: Expo tabs テンプレートでプロジェクト再初期化 (AC: #1)
  - [ ] 1.1 既存 `myakashic-app/` を退避（blank テンプレートのため tabs に再初期化が必要）
  - [ ] 1.2 `npx create-expo-app@latest myakashic-app --template tabs` を実行
  - [ ] 1.3 既存の `app.json` 設定（name, slug, newArchEnabled）を引き継ぎ
  - [ ] 1.4 TypeScript strict モード確認・設定
- [ ] Task 2: Clean Architecture ディレクトリ構造作成 (AC: #5)
  - [ ] 2.1 `src/domain/`, `src/application/`, `src/infrastructure/`, `src/presentation/`, `src/shared/` を作成
  - [ ] 2.2 各レイヤに `.gitkeep` または初期ファイルを配置
- [ ] Task 3: Supabase クライアントセットアップ (AC: #2)
  - [ ] 3.1 `@supabase/supabase-js` をインストール
  - [ ] 3.2 `expo-secure-store` をインストール（セッション永続化用）
  - [ ] 3.3 `src/infrastructure/supabase/client.ts` を作成
  - [ ] 3.4 `.env.example` を作成（環境変数テンプレート）
- [ ] Task 4: 環境変数バリデーション (AC: #4)
  - [ ] 4.1 `src/shared/utils/env-validation.ts` を作成
  - [ ] 4.2 起動時にバリデーションを実行するように `_layout.tsx` に組み込み
- [ ] Task 5: 認証セッション初期化 (AC: #3)
  - [ ] 5.1 `src/infrastructure/supabase/auth-session.ts` を作成
  - [ ] 5.2 認証状態管理用の Provider コンポーネントを作成
  - [ ] 5.3 認証済み/未認証のルーティング分岐を実装
- [ ] Task 6: 起動確認 (AC: #6)
  - [ ] 6.1 Web プラットフォームで起動確認
  - [ ] 6.2 エラーなし確認

## Dev Notes

### 重要: 既存プロジェクト状態

現在の `myakashic-app/` は `blank` テンプレート（Expo SDK 54.0.33）で初期化済み。アーキテクチャ要件は `tabs` テンプレート（Expo Router + ファイルベースルーティング）を要求しているため、**再初期化が必要**。

既存ファイル:
- `App.tsx` - デフォルト blank テンプレート（Expo Router 非使用）
- `index.ts` - `registerRootComponent` 方式（Expo Router では不要）
- `app.json` - 基本設定あり（引き継ぎ対象: name, slug, newArchEnabled, icon設定）
- `package.json` - Expo ~54.0.33, React 19.1.0, React Native 0.81.5

### 技術スタック（厳守）

| 技術 | バージョン | 用途 |
|------|-----------|------|
| Expo SDK | ~54.0.33 | アプリフレームワーク |
| React | 19.1.0 | UIライブラリ |
| React Native | 0.81.5 | モバイルランタイム |
| Expo Router | tabs テンプレート同梱版 | ファイルベースルーティング |
| @supabase/supabase-js | 最新安定版（^2.x） | Supabase クライアント |
| expo-secure-store | Expo SDK 54 互換版 | セッション永続化 |
| TypeScript | ~5.9.2 | 型安全 |

### アーキテクチャ規約（厳守）

#### ディレクトリ構造

```
myakashic-app/
├── app/                          # Expo Router ルーティング（tabs テンプレート由来）
│   ├── _layout.tsx               # ルートレイアウト
│   ├── (tabs)/                   # タブナビゲーション
│   │   ├── _layout.tsx           # タブレイアウト
│   │   ├── index.tsx             # Inbox タブ
│   │   └── ...
│   └── +not-found.tsx
├── src/
│   ├── domain/                   # ドメイン層: エンティティ、値オブジェクト、リポジトリIF
│   ├── application/              # アプリケーション層: ユースケース、DTO、ポート
│   ├── infrastructure/           # インフラ層: Supabase アダプタ、API、永続化
│   │   └── supabase/
│   │       ├── client.ts         # Supabase クライアント初期化
│   │       └── auth-session.ts   # セッション管理
│   ├── presentation/             # プレゼンテーション層: コンポーネント、フック
│   │   ├── components/
│   │   ├── hooks/
│   │   └── state/
│   └── shared/                   # 共有ユーティリティ
│       ├── constants/
│       ├── types/
│       └── utils/
│           └── env-validation.ts
├── .env.example
├── app.json
├── package.json
└── tsconfig.json
```

#### レイヤ依存ルール

- `presentation` → `application` → `domain`（依存方向は内側のみ）
- `infrastructure` は `domain` のインターフェースを実装
- `domain` は外部ライブラリに依存しない
- Supabase SDK は `infrastructure/supabase/` にのみ配置

#### 命名規約

- **コンポーネントファイル**: `PascalCase.tsx`（例: `AuthProvider.tsx`）
- **ユーティリティファイル**: `kebab-case.ts`（例: `env-validation.ts`）
- **テストファイル**: `<target>.test.ts`（例: `client.test.ts`）
- **変数/関数**: `camelCase`（例: `supabaseClient`）
- **型/インターフェース**: `PascalCase`（例: `AuthSession`）

### Supabase クライアント実装ガイド

#### client.ts の実装パターン

```typescript
// src/infrastructure/supabase/client.ts
import { createClient } from '@supabase/supabase-js';
import { LargeSecureStore } from './secure-store-adapter';

const supabaseUrl = process.env.EXPO_PUBLIC_SUPABASE_URL;
const supabaseAnonKey = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY;

// 環境変数バリデーションは別モジュールで実施済み前提

export const supabase = createClient(supabaseUrl!, supabaseAnonKey!, {
  auth: {
    storage: new LargeSecureStore(),
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false, // React Native では false
  },
});
```

#### セッション永続化

- **推奨**: `expo-secure-store` を使用（暗号化ストレージ）
- **注意**: `expo-secure-store` は1アイテム2048バイト上限があるため、チャンク分割アダプタが必要
- **代替**: `@react-native-async-storage/async-storage`（暗号化なし、Web対応あり）
- **選択基準**: セキュリティ優先なら `expo-secure-store`、Web互換優先なら `AsyncStorage`

#### 認証状態管理パターン

```typescript
// 認証プロバイダの基本構造
// - onAuthStateChange でセッション変更を監視
// - セッション有無で画面ルーティングを分岐
// - ローディング中はスプラッシュ/ローディング画面を表示
```

### 環境変数

```bash
# .env.example
EXPO_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
EXPO_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here
```

**重要**: Expo では `EXPO_PUBLIC_` プレフィックスの環境変数のみクライアントサイドで利用可能。

### Deep Link 設定（Magic Link 用、次ストーリーで使用）

このストーリーでは Deep Link の完全実装は不要だが、`app.json` に `scheme` を設定しておくこと:

```json
{
  "expo": {
    "scheme": "myakashic"
  }
}
```

### セキュリティ要件

- `service_role` キーをクライアントに含めないこと
- `EXPO_PUBLIC_SUPABASE_ANON_KEY` のみ使用可能
- RLS がデータアクセス制御の主要手段（DB側で設定、このストーリーのスコープ外）
- TLS は Supabase がデフォルトで提供

### 禁止事項（アンチパターン）

- `domain/` に `@supabase/supabase-js` を直接インポートしない
- `presentation/` から `infrastructure/` を直接参照しない
- 環境変数をハードコードしない
- `any` 型を使わない（`unknown` + 型ガードを使用）
- React Navigation を使わない（Expo Router を使用すること）

### プロジェクト構造ノート

- アーキテクチャドキュメントでは `src/app/` にルーティングを配置する構造を定義しているが、Expo Router の tabs テンプレートでは `app/` がプロジェクトルート直下に配置される。テンプレートのデフォルト構造に従うこと
- `src/` 配下にはビジネスロジック関連のコードのみを配置
- `app/` 配下の画面コンポーネントは薄くし、ロジックは `src/presentation/` から参照

### Docker 開発環境

既存の `docker-compose.yml` が設定済み:
- Node 20.19.4 ベース
- ポート: 8081, 19000-19002, 19006
- `npm install && npm run start -- --host 0.0.0.0` で自動起動

Docker を使わずローカル Node で開発も可能。

### 参照ドキュメント

- [Source: _bmad-output/planning-artifacts/architecture.md] - 全体アーキテクチャ定義
- [Source: _bmad-output/planning-artifacts/epics.md#Story 1.1] - ストーリー要件
- [Source: _bmad-output/planning-artifacts/prd.md#Technical Constraints] - 技術制約
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Design System Foundation] - デザインシステム基盤
- [Source: docs/knowledge-app-implementation-plan.md] - 実装設計
- [Source: docs/supabase-setup.md] - Supabase セットアップ手順
- [Source: docs/supabase-schema.sql] - DBスキーマ（RLS含む）
- [Source: docs/docker-dev.md] - Docker 開発環境
- [Source: AGENT.md] - AI開発者向けアーキテクチャルール

## Dev Agent Record

### Agent Model Used

(dev-story 実行時に記録)

### Debug Log References

### Completion Notes List

### Change Log

### File List
