# 知識整理アプリ 仕様書（MVP / DDD + Clean Architecture）

## 1. 目的
- 会社・本・体験などから得た学びを「知識ノート」として構造化し、
  関連づけ・振り返りを気軽に行えるようにする。
- 将来の公開を見据えつつ、MVPでは個人利用の体験価値を最優先する。

## 2. 主要ユースケース（MVP）
- 雑に知識を入力する（Quick Capture）
- 未整理インボックスから整える
- タグを付ける
- 関連リンクを付ける
- 週次振り返りで「直近の学び」と「過去の関連知識」を再提示する

## 3. 非目標（MVPでは扱わない）
- 公開用のUI
- 高度な分析ダッシュボード
- コラボレーション/共有権限
- オフライン完全対応（将来拡張）
- アプリ内AIの自動整形（外部LLMで手動実行）
- 画像/ファイル添付（将来拡張）

## 4. ユビキタス言語（用語定義）
- 知識ノート: 学び/知見の最小単位
- クイックキャプチャ: 雑に入力された未整理の知識
- インボックス: 未整理の知識が集まる場所
- 整形: クイックキャプチャを構造化する行為
- 整形プロンプト: 外部LLMに投げるための整形指示文
- 整形プロバイダ: 整形に使う外部LLMのサービス（ChatGPT/Claude/Gemini/カスタム）
- 関連リンク: 知識ノート同士の関係
- タグ: 分類・検索の補助
- 学習時期: 学びを得た大まかな時期
- 振り返り: 過去知識の再提示
- 公開状態: private / public
- 出典: 本/会社/体験などの来源

## 5. 境界づけられたコンテキスト
### 5.1 Knowledge Capture
- クイックキャプチャ
- インボックスでの整形
- 知識ノートの作成/編集/タグ付け/関連リンク

### 5.2 Review
- 週次振り返りの生成・再提示

### 将来拡張
- Publishing（公開ビュー）
- Analytics（成長推移・集中領域の分析）

## 6. ドメインモデル（MVP）
### 6.1 集約
- KnowledgeNote（集約ルート）

### 6.2 エンティティ
- KnowledgeNote
- NoteLink

### 6.3 値オブジェクト
- NoteId
- Title
- Body
- RawCaptureText
- TagName
- LearnedPeriod（例: 2019 / 2020-Q2）
- PeriodGranularity（year / quarter / month / day）
- CaptureStatus（inbox / structured）
- Visibility（private / public）
- SourceType（book / company / experience / other）
- SourceRef（任意）

### 6.4 ドメインサービス
- RelatedNotesFinder
  - タグ一致、リンク、簡易類似度に基づいて関連ノートを提示
- StructuringPromptBuilder
  - クイックキャプチャから整形プロンプトを生成

### 6.5 ドメインルール（MVP）
- 知識ノートは必ず `title` を持つ
  - `capture_status = inbox` の場合、`raw_text` 先頭から自動生成可
- `visibility` は必須（MVPでは常に private）
- `capture_status` が `inbox` の場合、`body` は空を許容
- `learned_period` が不明な場合は空許可、
  ただし `period_granularity` と整合する形式で保存

## 7. 週次振り返り（Review）
- 対象: 過去7日以内の `knowledge_notes` を基点にする
- 再提示: 関連ノートを数件リサーフェス
- MVPでは保存不要（都度生成）

## 7.1 整形フロー（外部LLM連携）
- アプリ内で整形プロンプトを生成し、コピーと外部リンクを提供
- ユーザーが選択したLLMで整形を実行し、結果をアプリに貼り付けて構造化
- アプリ内でAPIは叩かない（コスト回避）

## 7.1.1 整形プロバイダ（外部LLM）設定
- 既定は ChatGPT
- Claude/Gemini などに切り替え可能
- 任意のURLを設定できるカスタム枠を用意
- リンクは「選択中のプロバイダ」へ遷移する
- プリセットURLを用意する（ChatGPT / Claude / Gemini）

### 7.1.2 プリセットURL（案）
- ChatGPT: https://chatgpt.com/
- Claude: https://claude.ai/
- Gemini: https://gemini.google.com/

## 7.2 整形プロンプト（出力フォーマット）
LLMの出力は以下のフォーマットに統一する（MVP）。
パース可能な構造にしておくことで自動入力が可能になる。

```
Title: <短いタイトル>
Tags: <カンマ区切り>
LearnedPeriod: <2019 / 2020-Q2 / 2021-06 など>
PeriodGranularity: <year|quarter|month|day>
SourceType: <book|company|experience|other>
SourceRef: <任意>
Body:
<Markdown本文>
```

### 7.2.1 整形プロンプト（テンプレ）
ユーザーが雑多にメモした内容をそのまま投げられるように、
「整理・要約・構造化」を明示するプロンプトを生成する。

```
出力は{{LANGUAGE}}で行ってください。
以下のメモを、要点がわかるように整理・要約し、指定フォーマットで出力してください。
不足情報は推測せず、分からない項目は空欄で構いません。
余計な前置きや解説は出力せず、指定フォーマットのみを返してください。
出力はプレーンテキストで、全体をコードフェンスで囲まないでください。
本文はMarkdownで構いません（本文内のコードブロックは必要なら使用可）。
複数の話題が混在している場合は、主題を1つ選んで要約してください。

## メモ
{{RAW_TEXT}}

## 出力フォーマット（厳守）
Title: <短いタイトル>
Tags: <カンマ区切り>
LearnedPeriod: <2019 / 2020-Q2 / 2021-06 など>
PeriodGranularity: <year|quarter|month|day>
SourceType: <book|company|experience|other>
SourceRef: <任意>
Body:
<Markdown本文>
```

## 7.3 整形プロンプト生成ロジック（MVP）
入力: raw_text, language, provider_url
出力: 上記テンプレに raw_text を埋めたプロンプト文字列

ルール
- raw_text はそのまま貼り込む（前処理で改行や記号を壊さない）
- language は Settings で選択できる（default: 日本語、選択肢: 日本語/英語）
- provider_url は Settings の整形プロバイダ設定で決定する
- Copy と Open の2操作を必須にする

出力ガイド（LLM向け指針）
- Title: 15〜30文字程度の簡潔なタイトル
- Tags: 1〜5件、短い名詞でカンマ区切り（#は付けない）
- LearnedPeriod/PeriodGranularity: 明示的に時期がある場合のみ記入
- SourceType: 本/会社/体験などが明示される場合のみ記入
- Body: 重要点を箇条書き中心で整理し、必要なら短い解釈を1〜2文添える

時期の判断ルール（LLM向け）
- 例: "2019" -> LearnedPeriod=2019, PeriodGranularity=year
- 例: "2020-Q2" -> LearnedPeriod=2020-Q2, PeriodGranularity=quarter
- 例: "2021-06" -> LearnedPeriod=2021-06, PeriodGranularity=month
- 相対表現（去年/先月など）のみの場合は空欄にする

## 7.4 パース仕様（MVP）
貼り付けられたテキストから以下のキーを抽出する。
必須キー: Title, Body
任意キー: Tags, LearnedPeriod, PeriodGranularity, SourceType, SourceRef

抽出ルール
- 全体が単一のコードフェンスで囲まれている場合は外す
- 先頭から順に `Key: Value` 行を探索する
- `Body:` 行以降を本文として全て取り込む
- 余分なキーは無視する
- 値が空の場合は空として扱う

パース擬似コード（MVP）
```
function parseStructuredText(text):
  text = stripSingleFenceIfWrapped(text)
  lines = splitLines(text)

  let fields = { title: "", tags: "", learnedPeriod: "", periodGranularity: "", sourceType: "", sourceRef: "", body: "" }
  let inBody = false
  let bodyLines = []

  for line in lines:
    if inBody:
      bodyLines.push(line)
      continue

    if startsWithKey(line, "Title"):
      fields.title = valueOf(line)
      continue
    if startsWithKey(line, "Tags"):
      fields.tags = valueOf(line)
      continue
    if startsWithKey(line, "LearnedPeriod"):
      fields.learnedPeriod = valueOf(line)
      continue
    if startsWithKey(line, "PeriodGranularity"):
      fields.periodGranularity = valueOf(line)
      continue
    if startsWithKey(line, "SourceType"):
      fields.sourceType = valueOf(line)
      continue
    if startsWithKey(line, "SourceRef"):
      fields.sourceRef = valueOf(line)
      continue
    if startsWithKey(line, "Body"):
      inBody = true
      continue

  fields.body = joinLines(bodyLines).trim()
  return fields
```

バリデーション
- Title が空の場合は raw_text の先頭40文字を仮タイトルにする
- Tags はカンマ区切りで分割し、空要素は捨てる
- PeriodGranularity は `year|quarter|month|day` 以外は無効
- SourceType は `book|company|experience|other` 以外は無効

エラーハンドリング
- `Body:` が存在しない場合はパース失敗とする
- Title/Body が空の場合は警告表示し、手動編集へ誘導
- 不正フォーマットは「整形プロンプトを再実行」導線を表示

失敗時の挙動
- パースに失敗した場合はエラー表示
- raw_text を保持したまま手動編集画面へ遷移できる

## 8. データ設計（Supabase / Postgres）
### 8.1 テーブル
- knowledge_notes
- note_links
- tags
- note_tags

### 8.2 カラム例
#### knowledge_notes
- id (uuid)
- user_id (uuid)
- title (text)
- body (text, nullable)
- raw_text (text)
- capture_status (text) # inbox / structured
- learned_period (text)
- period_granularity (text)
- visibility (text)
- source_type (text)
- source_ref (text, nullable)
- structured_at (timestamptz, nullable)
- created_at (timestamptz)
- updated_at (timestamptz)

#### note_links
- id (uuid)
- from_note_id (uuid)
- to_note_id (uuid)
- relation_type (text, nullable)

#### tags
- id (uuid)
- name (text, unique)

#### note_tags
- note_id (uuid)
- tag_id (uuid)

## 9. アプリケーション層（ユースケース）
- CreateQuickCapture
- GenerateStructuringPrompt
- ApplyStructuredContent
- UpdateKnowledgeNote
- AddTagToNote
- LinkNotes
- GetRelatedNotes
- GenerateWeeklyReview

## 10. Clean Architecture 配置（案）
- src/domain
  - entities, value-objects, repositories(interface), services
- src/application
  - usecases, DTO, mappers
- src/infrastructure
  - supabase client, repository implementations
- src/presentation
  - screens, components, state

## 11. 主要画面（MVP）
- クイック入力画面（1入力）
- インボックス画面（未整理一覧）
- 詳細画面（タグ・関連リンク）
- 振り返り画面（週次の要約）

## 12. 将来拡張のための準備（MVP内で持っておくもの）
- visibility カラム
- source_type / source_ref
- learned_period / period_granularity
- 添付ファイル（画像）対応に備えた拡張余地
