# 実装設計（Expo + Supabase / DDD + Clean Architecture）

## 1. 前提
- フロント: Expo + React Native + TypeScript
- BaaS: Supabase（Postgres / Auth）
- アーキテクチャ: Clean Architecture + DDD
- MVP要件: Quick Capture → Inbox → 外部LLM整形 → 貼り付け構造化

## 2. ディレクトリ構成（案）
```
src/
  domain/
    entities/
    value-objects/
    repositories/          # interface
    services/
  application/
    usecases/
    dto/
    mappers/
    parsers/
  infrastructure/
    supabase/
      client.ts
      repositories/
  presentation/
    navigation/
    screens/
    components/
    hooks/
    state/
  shared/
    constants/
    utils/
    types/
```

## 3. 主要依存（案）
- `expo`
- `react-native`
- `typescript`
- `@supabase/supabase-js`
- `@react-navigation/native` + stack/tab
- `react-native-markdown-display`（プレビュー）
- `@react-native-async-storage/async-storage`（Settings保存）

## 4. 設定・環境
- `.env`（Expo）に `SUPABASE_URL`, `SUPABASE_ANON_KEY`
- Settingsに整形プロバイダURLと出力言語を保存
  - Storage: `AsyncStorage`

## 5. DB設計（Supabase）
### 5.1 テーブル
- `knowledge_notes`
- `note_links`
- `tags`
- `note_tags`

### 5.2 推奨カラム（RLSを前提に user_id を追加）
#### knowledge_notes
- id (uuid, pk)
- user_id (uuid)
- title (text)
- body (text, nullable)
- raw_text (text)
- capture_status (text) # inbox / structured
- learned_period (text, nullable)
- period_granularity (text, nullable)
- visibility (text) # private/public
- source_type (text, nullable)
- source_ref (text, nullable)
- structured_at (timestamptz, nullable)
- created_at (timestamptz)
- updated_at (timestamptz)

#### note_links
- id (uuid, pk)
- user_id (uuid)
- from_note_id (uuid)
- to_note_id (uuid)
- relation_type (text, nullable)

#### tags
- id (uuid, pk)
- user_id (uuid)
- name (text)
- unique(user_id, name)

#### note_tags
- note_id (uuid)
- tag_id (uuid)
- user_id (uuid)

### 5.3 RLS（想定）
- `user_id = auth.uid()` のみ許可
- insert/update/select/delete すべてで制約

## 6. 認証（最小）
- Supabase Auth
- MVPは Email Magic Link を推奨（最小工数）
- 代替: OAuth（後回し）

## 7. 画面設計（実装視点）
- **InboxScreen**: 未整理/全体の一覧 + 検索
- **CaptureScreen**: 大きなTextInput + Markdownプレビュー切替
- **DetailScreen**: 未整理/整形済みでUI分岐
- **ReviewScreen**: 直近7日 + 関連再提示
- **SettingsScreen**: プロバイダ選択 + カスタムURL + 出力言語

## 8. アプリケーション層（Usecases）
- `CreateQuickCapture`
- `GenerateStructuringPrompt`
- `ApplyStructuredContent`
- `UpdateKnowledgeNote`
- `AddTagToNote`
- `LinkNotes`
- `GetRelatedNotes`
- `GenerateWeeklyReview`

## 9. 主要ロジック
### 9.1 プロンプト生成
- テンプレに `{{RAW_TEXT}}` と `{{LANGUAGE}}` を埋め込む
- provider_url は Settings から参照

### 9.2 パース
- 全体が単一のコードフェンスなら外す
- `Body:` 以降を本文として取り込む
- Titleが空なら raw_text 先頭40文字を自動補完
- タグ推奨数は 8（UI警告のみ）

## 10. 画面遷移（簡略）
- Inbox → Capture → 保存 → Inbox
- Inbox → Detail（未整理） → Prompt生成 → Copy → Open Provider → 貼り付け → Structured保存
- Review → Detail

## 11. 開発ステップ（推奨）
1. Expoプロジェクト作成
2. Supabaseプロジェクト作成 + テーブル/RLS
3. Auth（Magic Link）
4. Inbox/Capture/Detail の基本実装
5. プロンプト生成 + パース
6. Review表示

## 12. 未決事項（確認が必要）
- 認証方式（Magic LinkでOKか）
- MarkdownプレビューのUI挙動（モーダル/タブ）
- Reviewでの関連ノート抽出ルール
