# SUDOモデリング（MVPスコープ / ユビキタス言語ベース）

## 1. ユビキタス言語（MVP必須）
- 知識ノート: 学び/知見の最小単位
- クイックキャプチャ: 雑に入力された未整理の知識
- インボックス: 未整理の知識が集まる場所
- 整形: クイックキャプチャを構造化する行為
- 整形プロンプト: 外部LLMに投げるための整形指示文
- 整形プロバイダ: 整形に使う外部LLM（ChatGPT/Claude/Gemini/カスタム）
- 学習時期: 学びを得た大まかな時期
- タグ: 分類・検索の補助
- 関連リンク: 知識ノート同士の関係
- 振り返り: 過去知識の再提示
- 出典: 本/会社/体験などの来源

## 2. S: システム関連図（System Context）
```mermaid
flowchart LR
  user[ユーザー] --> app[知識整理アプリ]
  app --> supabase[Supabase
認証/DB]
  app --> provider[整形プロバイダ
ChatGPT/Claude/Gemini/カスタム]
  user --> provider
  provider --> user
  user --> app
```

## 3. U: ユースケース図（Use Case / MVP必須）
```mermaid
flowchart LR
  user[ユーザー]
  app[知識整理アプリ]

  user --> uc1((クイックキャプチャ))
  user --> uc2((インボックス閲覧))
  user --> uc3((整形プロンプト生成))
  user --> uc4((整形プロバイダを開く))
  user --> uc5((整形結果貼り付け))
  user --> uc6((整形済みノート編集))
  user --> uc7((タグ付け))
  user --> uc8((関連リンク))
  user --> uc9((週次振り返り))

  uc1 --> app
  uc2 --> app
  uc3 --> app
  uc4 --> app
  uc5 --> app
  uc6 --> app
  uc7 --> app
  uc8 --> app
  uc9 --> app
```

## 4. D: ドメインモデル図（Domain Model / MVP必須）
```mermaid
classDiagram
  class KnowledgeNote {
    +id
    +title
    +body
    +rawText
    +captureStatus
    +learnedPeriod
    +periodGranularity
    +sourceType
    +sourceRef
    +structuredAt
  }

  class Tag {
    +id
    +name
  }

  class NoteLink {
    +id
    +fromNoteId
    +toNoteId
    +relationType
  }

  class Title
  class Body
  class RawCaptureText
  class LearnedPeriod
  class PeriodGranularity
  class SourceType
  class SourceRef
  class TagName

  <<ValueObject>> Title
  <<ValueObject>> Body
  <<ValueObject>> RawCaptureText
  <<ValueObject>> LearnedPeriod
  <<ValueObject>> PeriodGranularity
  <<ValueObject>> SourceType
  <<ValueObject>> SourceRef
  <<ValueObject>> TagName

  KnowledgeNote "1" --> "0..*" NoteLink
  KnowledgeNote "0..*" -- "0..*" Tag

  KnowledgeNote ..> Title
  KnowledgeNote ..> Body
  KnowledgeNote ..> RawCaptureText
  KnowledgeNote ..> LearnedPeriod
  KnowledgeNote ..> PeriodGranularity
  KnowledgeNote ..> SourceType
  KnowledgeNote ..> SourceRef
  Tag ..> TagName

  note for KnowledgeNote "知識ノート"
  note for Tag "タグ"
  note for NoteLink "関連リンク"
```

## 5. O: オブジェクト図（Object Diagram / MVP必須）
```mermaid
flowchart LR
  note1["知識ノート#1\nタイトル: 心理的安全性の前提\n状態: structured\n学習時期: 2020-Q2"]
  note2["知識ノート#2\nタイトル: チーム学習の条件\n状態: structured\n出典種別: book"]
  tag1["タグ#1\n組織"]
  tag2["タグ#2\n心理的安全性"]
  link1["関連リンク#1\n関係: reference"]

  note1 --> tag1
  note1 --> tag2
  note2 --> tag1
  note1 --> link1
  link1 --> note2
```
