---
stepsCompleted: [1, 2, 3, 4]
inputDocuments:
  - _bmad-output/planning-artifacts/prd.md
  - _bmad-output/planning-artifacts/architecture.md
  - _bmad-output/planning-artifacts/ux-design-specification.md
  - _bmad-output/planning-artifacts/prd-validation-report.md
---

# MyAkashic - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for MyAkashic, decomposing the requirements from the PRD, UX Design if it exists, and Architecture requirements into implementable stories.

## Requirements Inventory

### Functional Requirements

FR1: Primary User can sign in to the product.
FR2: Primary User can sign out of the product.
FR3: Primary User can access only their own knowledge data.
FR4: Primary User can select and update a default structuring provider.
FR5: Primary User can set and update output language preferences.
FR6: Primary User can create a quick capture from in-app input.
FR7: Primary User can save a capture as unstructured content.
FR8: Primary User can create a capture from mobile share sheet input.
FR9: Primary User can create a capture from desktop right-click context input.
FR10: Primary User can add personal commentary when creating a capture.
FR11: Primary User can cancel a capture flow without saving.
FR12: Primary User can create a top-level knowledge thread as a single note with a title.
FR13: Primary User can rename a knowledge thread title.
FR14: Primary User can delete a knowledge thread.
FR15: Primary User can select a knowledge thread as capture destination.
FR16: Primary User can append new captured content to the end of a selected knowledge thread.
FR17: System can preserve append order within each knowledge thread.
FR18: Primary User can view each knowledge thread as one continuous note.
FR19: Primary User can edit previously appended segments in a knowledge thread.
FR20: Primary User can remove previously appended segments from a knowledge thread.
FR21: Primary User can add tags to a knowledge thread.
FR22: Primary User can remove tags from a knowledge thread.
FR23: Primary User can create links between knowledge threads.
FR24: Primary User can edit links between knowledge threads.
FR25: Primary User can remove links between knowledge threads.
FR26: Primary User can generate a structuring prompt from a selected knowledge thread.
FR27: Primary User can copy a generated structuring prompt.
FR28: Primary User can open the selected external structuring provider from the product.
FR29: Primary User can paste structured output into the product for processing.
FR30: System can extract structured fields from pasted content.
FR31: Primary User can review and edit extracted fields before applying them.
FR32: System can create a fallback title when structured input lacks a title.
FR33: System can preserve original thread content when structuring fails.
FR34: Primary User can retry structuring after a failed parsing attempt.
FR35: Primary User can search knowledge threads by title.
FR36: Primary User can search within full thread content.
FR37: Primary User can filter knowledge threads by tags.
FR38: Primary User can open linked knowledge threads from a thread detail view.
FR39: Primary User can view related knowledge threads from a thread detail view.
FR40: Primary User can view a weekly review of recent learning content.
FR41: System can resurface related historical knowledge threads in weekly review.
FR42: Primary User can open resurfaced threads directly from weekly review.
FR43: Support User can view structuring failure reasons.
FR44: Support User can reprocess failed structuring attempts.
FR45: Support User can recover failed entries while preserving original content.
FR46: Primary User can use core workflows on mobile client.
FR47: Primary User can use core workflows on web client.
FR48: Primary User can use core workflows on desktop client.

### NonFunctional Requirements

NFR1: System can return search results within 1 second for the 95th percentile, measured by server-side APM timing logs over rolling 7-day windows under normal operating conditions.
NFR2: System can render primary screens within 2 seconds for the 95th percentile, measured by client-side telemetry on supported browsers and devices under normal network conditions.
NFR3: System can support user knowledge retrieval workflows that complete within 10 seconds for at least 95% of business-use sessions, measured from search submission to target thread open in product analytics.
NFR4: System can block 100% of unauthenticated requests for protected user-data operations, verified by release-gate integration tests.
NFR5: System can maintain 0 unauthorized cross-user read/write results in monthly authorization and RLS verification tests.
NFR6: System can protect data in transit using TLS.
NFR7: System can rely on platform-standard data protection controls for persisted data.
NFR8: Web client can satisfy WCAG AA-level accessibility requirements for core workflows.
NFR9: System can maintain functional integration with the configured authentication and data persistence service, with at least 99% successful auth and write transactions in daily health checks.
NFR10: System can support external LLM structuring workflows with at least 95% successful end-to-end completion (prompt generation to manual result ingestion) in weekly smoke tests.
NFR11: System can maintain 99.5% monthly availability for core workflows.
NFR12: System can maintain a capture/save success rate of at least 99%.
NFR13: System can maintain structured parsing success rate of at least 95%.
NFR14: System architecture can support 10x growth from initial usage volumes in quarterly load tests while meeting NFR1-NFR3 targets.

### Additional Requirements

- Starter template is fixed: `npx create-expo-app@latest myakashic-app --template tabs` and this setup must be handled as the first implementation story.
- Architecture baseline is mobile-first full-stack with Expo + Supabase + BFF (Supabase Edge Functions), and all client-server communication follows BFF boundaries.
- API style is resource-based REST (`/api/v1/captures`, `/api/v1/threads`, `/api/v1/threads/:id/segments`, `/api/v1/structured-previews`, `/api/v1/reviews/weekly`) with uniform response wrapper `{ data, error, meta }`.
- Domain design rules are mandatory: DDD-lite + SUDO modeling + ubiquitous language governance, with required update triggers when FR/flow/aggregate invariants change.
- Vendor lock-in mitigation is required: keep Supabase-specific dependencies in infrastructure adapters, keep domain/application portable, and protect APIs with OpenAPI + contract tests.
- State architecture is fixed: TanStack Query for server state and Zustand for UI/transient state with strict no-duplication policy.
- Security baseline includes Supabase Auth (Magic Link), RLS-enforced tenant isolation, TLS in transit, and server-only handling of privileged keys.
- Observability baseline includes Sentry, Supabase logs, KPI events, and release gates tied to save success rate, parse success rate, and search-to-open performance targets.
- UX non-negotiables include quick capture from in-app, mobile share sheet ingest, desktop right-click ingest, lossless recovery on structuring failure, and category selection before save.
- Tagging policy is fixed: initial tags are generated during AI structuring, and manual tag operations are limited to edit-time fine-tuning.
- Responsive/accessibility constraints are mandatory: breakpoints `360-767 / 768-1023 / 1024+`, WCAG AA-level compliance, minimum 44x44 touch targets, and keyboard/screen-reader support.
- Project structure and test strategy are predefined: layered boundaries (`presentation/application/domain/infrastructure`), unit tests co-located, contract tests in `tests/contracts`, and schema/terminology checks in CI.
- Desktop and deployment requirements include Mac-first desktop support, EAS build/submit for mobile, Vercel for web delivery, and staged migration/function deployment controls.

### FR Coverage Map

FR1: Epic 1 - ユーザー認証（サインイン）
FR2: Epic 1 - ユーザー認証（サインアウト）
FR3: Epic 1 - ユーザーごとのデータ分離アクセス
FR4: Epic 1 - 既定整形プロバイダ設定
FR5: Epic 1 - 出力言語設定
FR6: Epic 2 - アプリ内クイックキャプチャ作成
FR7: Epic 2 - 未整理キャプチャ保存
FR8: Epic 2 - モバイル共有シート入力
FR9: Epic 2 / Epic 6 - デスクトップ右クリック入力
FR10: Epic 2 - キャプチャ時コメント付与
FR11: Epic 2 - キャプチャフロー取消
FR12: Epic 3 - 最上位スレッド作成
FR13: Epic 3 - スレッド名変更
FR14: Epic 3 - スレッド削除
FR15: Epic 2 - 保存先スレッド選択
FR16: Epic 3 - スレッド末尾追記
FR17: Epic 3 - 追記順序保持
FR18: Epic 3 - 単一ノート連続表示
FR19: Epic 3 - 追記セグメント編集
FR20: Epic 3 - 追記セグメント削除
FR21: Epic 4 - AI整形時タグ初期付与
FR22: Epic 3 - 編集時タグ微修正（削除含む）
FR23: Epic 3 - スレッド間リンク作成
FR24: Epic 3 - スレッド間リンク編集
FR25: Epic 3 - スレッド間リンク削除
FR26: Epic 4 - 整形プロンプト生成
FR27: Epic 4 - 整形プロンプトコピー
FR28: Epic 4 - 外部整形プロバイダ遷移
FR29: Epic 4 - 整形結果貼り付け処理
FR30: Epic 4 - 構造化フィールド抽出
FR31: Epic 4 - 抽出結果レビュー/編集
FR32: Epic 4 - タイトル欠落時フォールバック生成
FR33: Epic 4 - 整形失敗時の原文保持
FR34: Epic 4 - 整形再試行
FR35: Epic 5 - タイトル検索
FR36: Epic 5 - 本文全文検索
FR37: Epic 5 - タグフィルタ
FR38: Epic 5 - 詳細から関連スレッド遷移
FR39: Epic 5 - 関連スレッド表示
FR40: Epic 5 - 週次振り返り表示
FR41: Epic 5 - 関連知識リサーフェス
FR42: Epic 5 - 振り返りから直接遷移
FR43: Epic 4 - 整形失敗理由表示
FR44: Epic 4 - 整形失敗再処理
FR45: Epic 4 - 失敗エントリ復旧
FR46: Epic 6 - モバイル提供
FR47: Epic 6 - Web提供
FR48: Epic 6 - デスクトップ提供

## Epic List

### Epic 1: アカウント基盤と個人設定
ユーザーが安全にサインインし、自分専用の知識管理環境（整形プロバイダ/言語設定）を使える状態を提供する。  
**FRs covered:** FR1, FR2, FR3, FR4, FR5

### Epic 2: 即時キャプチャと保存先選択
ユーザーがアプリ内入力・スマホ共有・デスクトップ右クリックから知識をすぐ記録し、保存先スレッドを選んで迷わず保存できる状態を提供する。  
**FRs covered:** FR6, FR7, FR8, FR9, FR10, FR11, FR15

### Epic 3: 単一ノートスレッド管理
ユーザーが最上位スレッド（単一ノート）を作成し、追記順序を保ったまま閲覧・編集・編集時タグ微修正・リンク付けできる状態を提供する。  
**FRs covered:** FR12, FR13, FR14, FR16, FR17, FR18, FR19, FR20, FR22, FR23, FR24, FR25

### Epic 4: 構造化ワークフローと失敗回復
ユーザーが整形プロンプト生成から貼り付け構造化までを実行し、失敗時も内容を失わず復旧できる状態を提供する。  
**FRs covered:** FR21, FR26, FR27, FR28, FR29, FR30, FR31, FR32, FR33, FR34, FR43, FR44, FR45

### Epic 5: 検索・関連探索・週次振り返り
ユーザーが必要な知識を検索で素早く取り出し、関連知識と週次振り返りで再利用・定着を進められる状態を提供する。  
**FRs covered:** FR35, FR36, FR37, FR38, FR39, FR40, FR41, FR42

### Epic 6: マルチプラットフォーム提供と品質運用
モバイル・Web・デスクトップで一貫した体験を提供し、NFR（性能・信頼性・セキュリティ・アクセシビリティ）を継続運用できる状態を提供する。  
**FRs covered:** FR46, FR47, FR48, FR9
**NFR focus:** NFR1, NFR2, NFR3, NFR4, NFR5, NFR6, NFR7, NFR8, NFR9, NFR10, NFR11, NFR12, NFR13, NFR14

<!-- Repeat for each epic in epics_list (N = 1, 2, 3...) -->

## Epic 1: アカウント基盤と個人設定

ユーザーが安全にサインインし、自分専用の知識管理環境（整形プロバイダ/言語設定）を使える状態を提供する。

### Story 1.1: プロジェクト初期化と認証基盤セットアップ

As a 開発者,  
I want Expo tabsテンプレートとSupabase Auth接続を初期化したい,  
So that 認証機能を安全に実装開始できる。  

**FR Reference:** FR1, FR2, FR3

**Acceptance Criteria:**

**Given** 新規リポジトリでアプリが未初期化である  
**When** `npx create-expo-app@latest myakashic-app --template tabs` で初期化し、Supabase接続設定を追加する  
**Then** アプリが起動し、認証セッション初期化処理が実行される  
**And** 必須環境変数の不足時に明示エラーが表示される

### Story 1.2: Magic Link サインイン

As a Primary User,  
I want メールのMagic Linkでサインインしたい,  
So that 安全に自分の知識空間へアクセスできる。  

**FR Reference:** FR1

**Acceptance Criteria:**

**Given** 未ログインのユーザーがログイン画面にいる  
**When** メールアドレスを入力してMagic Link送信を実行する  
**Then** ログインリンク送信完了状態が表示される  
**And** リンク経由で復帰時に認証済みセッションになる

### Story 1.3: セッション維持とサインアウト

As a Primary User,  
I want サインイン状態を保持しつつ必要時にサインアウトしたい,  
So that 利便性と安全性を両立できる。  

**FR Reference:** FR2

**Acceptance Criteria:**

**Given** ユーザーが認証済みである  
**When** アプリを再起動する  
**Then** 有効セッションが復元される  
**And** サインアウト実行時にセッションが破棄されログイン画面へ戻る

### Story 1.4: ユーザー別データアクセス制御

As a Primary User,  
I want 自分のデータだけにアクセスしたい,  
So that 他ユーザーの知識が混在しない。  

**FR Reference:** FR3

**Acceptance Criteria:**

**Given** 複数ユーザーのデータが保存されている  
**When** 認証済みユーザーがスレッド一覧取得を行う  
**Then** 自分のデータのみ取得される  
**And** 未認証または他ユーザーID指定のアクセスは拒否される

### Story 1.5: 整形プロバイダと言語設定

As a Primary User,  
I want 既定の整形プロバイダと出力言語を設定したい,  
So that 構造化作業を自分の運用に合わせられる。  

**FR Reference:** FR4, FR5

**Acceptance Criteria:**

**Given** ユーザーが設定画面を開いている  
**When** プロバイダと出力言語を選択して保存する  
**Then** 設定が永続化され次回起動時も復元される  
**And** 整形プロンプト生成時に保存済み設定が反映される

## Epic 2: 即時キャプチャと保存先選択

ユーザーがアプリ内入力・スマホ共有・デスクトップ右クリックから知識をすぐ記録し、保存先スレッドを選んで迷わず保存できる状態を提供する。

### Story 2.1: アプリ内クイックキャプチャ作成

As a Primary User,  
I want アプリ内から1操作でキャプチャ入力を開始したい,  
So that 記録したい瞬間を逃さない。  

**FR Reference:** FR6

**Acceptance Criteria:**

**Given** ユーザーがアプリ内のホーム画面にいる  
**When** 追記起点（QuickCaptureLauncher）を実行する  
**Then** キャプチャ入力画面が即時表示される  
**And** 入力途中に離脱しても下書きが保持される

### Story 2.2: キャプチャ保存と保存先スレッド選択

As a Primary User,  
I want 保存前に保存先スレッドを選択して未整理内容を保存したい,  
So that 後から迷わず知識を追記運用できる。  

**FR Reference:** FR7, FR15

**Acceptance Criteria:**

**Given** ユーザーがキャプチャ入力を完了している  
**When** 保存操作を行う  
**Then** CategoryPickerが表示され未選択では保存不可となる  
**And** スレッド選択後に未整理キャプチャが保存される
**And** スレッドが1件もない場合は、その場で最上位スレッドを作成して保存を継続できる

### Story 2.3: モバイル共有シート受信と保存

As a Primary User,  
I want スマホ共有シートから選択テキストと意見を取り込んで保存したい,  
So that 他アプリ閲覧中でも即記録できる。  

**FR Reference:** FR8

**Acceptance Criteria:**

**Given** ユーザーが外部アプリで共有操作を実行する  
**When** MyAkashic 共有受信画面（ShareIngestPreview）に遷移する  
**Then** 受信テキストとコメント入力欄が表示される  
**And** 保存完了後に短い完了通知が表示される

### Story 2.4: デスクトップ右クリック起点キャプチャ

As a Primary User,  
I want デスクトップで右クリックから記録を開始したい,  
So that 業務中でも最短で知識を取り込める。  

**FR Reference:** FR9

**Acceptance Criteria:**

**Given** デスクトップ環境でユーザーがテキストを選択している  
**When** 右クリックメニューから記録起点を実行する  
**Then** キャプチャ入力フローが起動し選択テキストが初期値として反映される  
**And** 保存先スレッド選択を経て保存できる

### Story 2.5: コメント付与・キャンセル・安全離脱

As a Primary User,  
I want コメント付与とキャンセルを明確に使い分けたい,  
So that 不要保存を防ぎつつ必要な記録だけ残せる。  

**FR Reference:** FR10, FR11

**Acceptance Criteria:**

**Given** ユーザーがキャプチャフロー内にいる  
**When** コメントを入力して保存する  
**Then** コメントが保存データに含まれる  
**And** キャンセル時は保存されず、未保存離脱時は確認導線が表示される

## Epic 3: 単一ノートスレッド管理

ユーザーが最上位スレッド（単一ノート）を作成し、追記順序を保ったまま閲覧・編集・編集時タグ微修正・リンク付けできる状態を提供する。

### Story 3.1: 最上位スレッドの作成・改名・削除

As a Primary User,  
I want 最上位スレッドを作成し名前を更新・不要時に削除したい,  
So that 知識をテーマ単位で管理できる。  

**FR Reference:** FR12, FR13, FR14

**Acceptance Criteria:**

**Given** ユーザーがスレッド管理画面にいる  
**When** 新規作成・改名・削除を実行する  
**Then** 操作結果が即時に一覧へ反映される  
**And** 削除は確認導線を通さないと確定しない

### Story 3.2: 単一ノート末尾追記と順序保証

As a Primary User,  
I want 選択したスレッドの末尾へ内容を追記したい,  
So that 時系列で知識を積み上げられる。  

**FR Reference:** FR16, FR17

**Acceptance Criteria:**

**Given** 既存スレッドが存在する  
**When** 新規キャプチャをそのスレッドに保存する  
**Then** 内容は末尾へ追加される  
**And** 既存セグメントとの順序が保持される

### Story 3.3: 連続ノート表示とセグメント編集

As a Primary User,  
I want スレッドを1枚ノートとして閲覧し、過去セグメントを編集したい,  
So that 内容を育てながら再利用しやすくできる。  

**FR Reference:** FR18, FR19

**Acceptance Criteria:**

**Given** スレッドに複数セグメントが存在する  
**When** 詳細表示を開く  
**Then** 連続ノートとして一体表示される  
**And** 任意セグメントの編集保存が可能である

### Story 3.4: セグメント削除と整合維持

As a Primary User,  
I want 不要なセグメントを削除したい,  
So that ノート品質を維持できる。  

**FR Reference:** FR20

**Acceptance Criteria:**

**Given** スレッド詳細に複数セグメントが表示されている  
**When** 特定セグメント削除を実行する  
**Then** 対象セグメントのみ削除される  
**And** それ以外の順序と内容は保持される

### Story 3.5: 編集時タグ微修正

As a Primary User,  
I want スレッド本文を編集するときにタグを微修正したい,  
So that AI整形で付いたタグを運用に合わせて調整できる。  

**FR Reference:** FR22

**Acceptance Criteria:**

**Given** スレッドに既存タグがある  
**When** ユーザーが本文編集画面でタグを追加・削除する  
**Then** 変更後タグが保存される  
**And** 変更内容は検索フィルタ（タグ検索）に反映される

### Story 3.6: スレッド間リンク管理（作成・編集・削除）

As a Primary User,  
I want スレッド同士の関連リンクを管理したい,  
So that 知識間のつながりを辿れる。  

**FR Reference:** FR23, FR24, FR25

**Acceptance Criteria:**

**Given** 複数のスレッドが存在する  
**When** リンクを作成・編集・削除する  
**Then** 関連リンク情報が正しく更新される  
**And** 詳細画面からリンク先へ遷移できる

## Epic 4: 構造化ワークフローと失敗回復

ユーザーが整形プロンプト生成から貼り付け構造化までを実行し、失敗時も内容を失わず復旧できる状態を提供する。

### Story 4.1: 整形プロンプト生成とコピー

As a Primary User,  
I want 選択スレッドから整形プロンプトを生成してコピーしたい,  
So that 外部LLMへすぐ渡して構造化を開始できる。  

**FR Reference:** FR26, FR27

**Acceptance Criteria:**

**Given** ユーザーがスレッド詳細を開いている  
**When** 整形プロンプト生成を実行する  
**Then** 指定フォーマット付きプロンプトが生成される  
**And** コピー操作でクリップボードへ保存される

### Story 4.2: 外部整形プロバイダ遷移

As a Primary User,  
I want 選択した整形プロバイダをアプリから開きたい,  
So that 生成プロンプトをすぐ貼り付けて処理できる。  

**FR Reference:** FR28

**Acceptance Criteria:**

**Given** ユーザーが整形プロンプト生成画面にいる  
**When** プロバイダを開く操作を行う  
**Then** 設定済みプロバイダURLへ遷移する  
**And** 未設定時は設定導線が提示される

### Story 4.3: 構造化テキスト貼り付けとフィールド抽出

As a Primary User,  
I want LLM整形結果を貼り付けて構造化フィールドを抽出したい,  
So that ノートに再利用しやすい形で保存できる。  

**FR Reference:** FR29, FR30

**Acceptance Criteria:**

**Given** ユーザーが整形結果入力画面にいる  
**When** フォーマット済みテキストを貼り付けて解析する  
**Then** Title/Body/Tags等の構造化フィールドが抽出される  
**And** Body欠落などの不正フォーマット時は失敗理由が表示される

### Story 4.4: AI整形結果からタグ初期付与

As a Primary User,  
I want AI整形結果のタグを初期値として自動反映したい,  
So that 手動でタグを毎回入力せずに運用できる。  

**FR Reference:** FR21

**Acceptance Criteria:**

**Given** 整形結果にTagsフィールドが含まれている  
**When** 構造化保存を実行する  
**Then** タグがスレッドへ初期付与される  
**And** 不正タグ形式は無視または警告表示される

### Story 4.5: 抽出結果レビュー・編集・フォールバックタイトル

As a Primary User,  
I want 抽出結果を保存前に確認して必要なら編集したい,  
So that 誤った構造化情報の保存を防げる。  

**FR Reference:** FR31, FR32

**Acceptance Criteria:**

**Given** 抽出結果が表示されている  
**When** ユーザーがフィールドを編集して保存する  
**Then** 編集後データで保存される  
**And** タイトル未設定時はフォールバックタイトルが自動生成される

### Story 4.6: 構造化失敗時のロスレス回復

As a Support User,  
I want 失敗理由を確認し再処理または修正再試行したい,  
So that 入力内容を失わず復旧できる。  

**FR Reference:** FR33, FR34, FR43, FR44, FR45

**Acceptance Criteria:**

**Given** 構造化処理が失敗した  
**When** 失敗詳細を表示して再処理/再試行を行う  
**Then** 原文は保持されたまま回復フローが実行される  
**And** 再試行成功時に通常保存フローへ復帰できる

## Epic 5: 検索・関連探索・週次振り返り

ユーザーが必要な知識を検索で素早く取り出し、関連知識と週次振り返りで再利用・定着を進められる状態を提供する。

### Story 5.1: タイトル・本文の統合検索

As a Primary User,  
I want タイトルと本文を横断して検索したい,  
So that 必要な知識に素早く到達できる。  

**FR Reference:** FR35, FR36

**Acceptance Criteria:**

**Given** 複数スレッドに知識が蓄積されている  
**When** 検索クエリを入力して実行する  
**Then** タイトル一致と本文一致が結果に表示される  
**And** 一致度優先（同点は新しい順）で並ぶ

### Story 5.2: タグフィルタ検索

As a Primary User,  
I want タグで検索結果を絞り込みたい,  
So that 文脈に合う知識だけを見つけられる。  

**FR Reference:** FR37

**Acceptance Criteria:**

**Given** 検索結果または一覧画面が表示されている  
**When** タグフィルタを選択する  
**Then** 該当タグを持つスレッドのみ表示される  
**And** フィルタ解除で元の結果に戻る

### Story 5.3: 関連リンク遷移と関連スレッド表示

As a Primary User,  
I want 詳細画面から関連スレッドへ移動したい,  
So that 知識のつながりを辿って理解を深められる。  

**FR Reference:** FR38, FR39

**Acceptance Criteria:**

**Given** スレッド詳細に関連リンクが存在する  
**When** 関連項目を選択する  
**Then** リンク先スレッドへ遷移できる  
**And** 詳細画面に関連スレッド一覧が表示される

### Story 5.4: 週次振り返り（直近学習）

As a Primary User,  
I want 週次で直近の学習内容をまとめて見たい,  
So that 学習活動を継続しやすくなる。  

**FR Reference:** FR40

**Acceptance Criteria:**

**Given** 直近7日間の知識記録が存在する  
**When** 振り返り画面を開く  
**Then** 直近学習内容が一覧で表示される  
**And** 各項目から該当スレッド詳細へ遷移できる

### Story 5.5: 週次リサーフェス（関連知識再提示）

As a Primary User,  
I want 振り返り時に関連する過去知識を再提示してほしい,  
So that 忘れていた知識を再利用できる。  

**FR Reference:** FR41, FR42

**Acceptance Criteria:**

**Given** 振り返り対象スレッドに関連知識が存在する  
**When** 週次振り返りを表示する  
**Then** 関連する過去スレッドがリサーフェス表示される  
**And** ユーザーは再提示スレッドを直接開ける

## Epic 6: マルチプラットフォーム提供と品質運用

モバイル・Web・デスクトップで一貫した体験を提供し、NFR（性能・信頼性・セキュリティ・アクセシビリティ）を継続運用できる状態を提供する。

### Story 6.1: Webコア導線提供

As a Primary User,  
I want Webで主要導線（記録/検索/参照）を使いたい,  
So that ブラウザ業務中でも知識を継続活用できる。  

**FR Reference:** FR47

**Acceptance Criteria:**

**Given** ユーザーがWebクライアントを利用している  
**When** 主要導線を実行する  
**Then** Webで主要導線が完了できる  
**And** 画面崩れなく主要操作が完了できる

### Story 6.2: Mobileコア導線提供

As a Primary User,  
I want Mobileで主要導線（記録/検索/参照）を使いたい,  
So that 学習中でも即時に知識を記録・再利用できる。  

**FR Reference:** FR46

**Acceptance Criteria:**

**Given** ユーザーがモバイルクライアントを利用している  
**When** 記録・検索・参照を実行する  
**Then** モバイルでコア導線が利用可能である  
**And** 共有起点からの保存フローと通常入力フローが同等品質で完了できる

### Story 6.3: Desktop基本導線提供

As a Primary User,  
I want デスクトップで記録・検索・参照を使いたい,  
So that 業務中の知識活用を継続できる。  

**FR Reference:** FR48

**Acceptance Criteria:**

**Given** ユーザーがデスクトップクライアントを利用している  
**When** 記録・検索・参照を実行する  
**Then** コア導線が利用可能である  
**And** 通常操作が業務中の利用文脈で中断なく完了できる

### Story 6.4: Desktop右クリック導線統合

As a Primary User,  
I want 右クリック起点で記録フローを開始したい,  
So that 作業コンテキストを崩さずに知識を保存できる。  

**FR Reference:** FR9, FR48

**Acceptance Criteria:**

**Given** ユーザーがデスクトップ環境でテキストを選択している  
**When** 右クリックメニューから記録起点を実行する  
**Then** キャプチャ入力フローが起動し選択テキストが初期反映される  
**And** 保存先選択を経て通常保存パイプラインに合流できる

### Story 6.5: レスポンシブ・アクセシビリティ基準達成

As a Primary User,  
I want どの画面サイズでも読みやすく操作しやすいUIを使いたい,  
So that ストレスなく継続利用できる。  

**FR Reference:** FR46, FR47, FR48
**NFR Reference:** NFR2, NFR8

**Acceptance Criteria:**

**Given** ブレークポイント（360-767 / 768-1023 / 1024+）で画面を表示する  
**When** 主要画面と主要操作を検証する  
**Then** 横スクロールなしで利用できる  
**And** WCAG AA相当（コントラスト/キーボード操作/44x44タッチターゲット）を満たす

### Story 6.6: 観測基盤と品質ゲート導入

As a 開発チーム,  
I want 保存成功率・パース成功率・検索到達時間を継続計測したい,  
So that NFR達成状態をリリース判断に使える。  

**FR Reference:** FR46, FR47, FR48
**NFR Reference:** NFR1, NFR3, NFR9, NFR10, NFR11, NFR12, NFR13, NFR14

**Acceptance Criteria:**

**Given** 監視基盤（Sentry/Supabase logs/KPIイベント）が構成されている  
**When** コア導線を実行する  
**Then** 主要KPIが記録される  
**And** 品質ゲート（保存99%、パース95%、検索到達p95 10秒）判定が可能である

### Story 6.7: CI/CDと契約テスト運用

As a 開発チーム,  
I want CIで命名規約・契約整合・テストを自動検証したい,  
So that AIエージェント間の実装ぶれを防げる。  

**FR Reference:** FR46, FR47, FR48
**NFR Reference:** NFR4, NFR5, NFR6, NFR7, NFR9

**Acceptance Criteria:**

**Given** CIパイプラインが設定されている  
**When** 変更をプッシュする  
**Then** lint/typecheck/unit/contract/integrationが実行される  
**And** 規約違反や契約不一致があればマージがブロックされる
