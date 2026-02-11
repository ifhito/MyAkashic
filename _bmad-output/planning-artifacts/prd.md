---
stepsCompleted:
  - step-01-init
  - step-02-discovery
  - step-03-success
  - step-04-journeys
  - step-05-domain
  - step-06-innovation
  - step-07-project-type
  - step-08-scoping
  - step-09-functional
  - step-10-nonfunctional
  - step-11-polish
  - step-12-complete
  - step-e-01-discovery
  - step-e-02-review
  - step-e-03-edit
inputDocuments:
  - _bmad-output/planning-artifacts/product-brief-MyAkashic-2026-02-10-185929.md
  - _bmad-output/brainstorming/brainstorming-session-2026-02-10-182909.md
  - docs/knowledge-app-spec.md
  - docs/knowledge-app-implementation-plan.md
  - docs/knowledge-app-ui-flow.md
  - docs/knowledge-app-sudo-modeling.md
  - docs/supabase-setup.md
  - docs/docker-dev.md
workflowType: 'prd'
workflow: 'edit'
date: '2026-02-10'
lastEdited: '2026-02-11'
editHistory:
  - date: '2026-02-11'
    changes: 'Resolved remaining warnings: NFR1-NFR3 measurement methods, responsive design criteria, desktop update strategy.'
documentCounts:
  briefCount: 1
  researchCount: 0
  brainstormingCount: 1
  projectDocsCount: 6
  projectContextCount: 0
projectType: brownfield
classification:
  projectType: multi-platform (web_app + mobile_app + desktop_app)
  domain: general
  complexity: low
  projectContext: brownfield
---

# Product Requirements Document - MyAkashic

**Author:** Hotake
**Date:** 2026-02-10

## Executive Summary

MyAkashic は、学習中や業務中に得た知識を即時に記録し、必要な瞬間に引き出して活用できるようにする知識活用プロダクトである。  
中心価値は「記録→構造化→検索→再利用」の一連導線を、モバイル・Web・デスクトップで一貫して成立させること。  
MVPでは、最上位スレッド（単一ノート）を軸にした追記型運用、外部LLM整形、検索、週次振り返りを提供し、実務での即時想起を実現する。  
Post-MVPでは実運用データをもとに機能優先度を決定し、将来的にアプリ内AI自動整理と共有/公開機能へ拡張する。

## Success Criteria

### User Success

- ユーザーは必要な知識を、業務中の会話・判断の文脈で即時に取り出して活用できること
- 主要な成功体験は「質問されたときに専門的な視点で即答できること」
- 記録・整理・検索の導線が日常的に回り、学び直しが継続できること

### Business Success

- 3か月目標:
  - 週次継続率 100%（一次ユーザー運用）
  - 日常業務での実利用を継続できている状態
- 12か月目標:
  - 月間利用日数 25日以上
  - 知識の体系化運用が習慣として定着している状態

### Technical Success

- 保存成功率 99%以上（知識入力の保存が失敗しないこと）
- 整形結果パース成功率 95%以上（貼り付け構造化の信頼性）
- 主要機能（記録・検索・参照）の実用上の安定動作を維持すること

### Measurable Outcomes

- 週あたり知識記録数: 10件以上（全プラットフォーム合算）
- 検索〜参照完了時間: 10秒以内
- 週あたり再利用回数: 3回以上
- 週次継続率: 100%（短期目標）
- 月間利用日数: 25日以上（12か月目標）

## Product Scope

### MVP - Minimum Viable Product

- 通常入力（Quick Capture）
- OS共有シート（Share Sheet）経由入力
- AI整形プロンプト作成（外部LLM連携前提）
- 整理済み文章の取り込み・構造化保存・管理
- 最上位スレッド（単一ノート）管理（作成/編集/削除）
- 検索機能（タイトル/本文/タグ）
- 週次振り返り（MVP簡易版）

### Growth Features (Post-MVP)

- 現時点では未確定
- 実運用データ（継続率、再利用頻度、失敗率）を観測後に優先順位を決定する

### Vision (Future)

- アプリ内でAI APIを実行し、自動で知識を整理・構造化する体験
- マルチプラットフォーム（Mobile → Web → Desktop）で一貫した知識活用体験を実現

## User Journeys

### Journey 1: Primary User - Success Path（学習中の即時記録から実務活用まで）

Hotake は学習時間中、モバイルで記事を読んでいる。  
「これは後で絶対使う」と思った瞬間、選択した文章を共有シートから MyAkashic に渡し、短い自分の意見を添えて保存する。  
保存先は「ドメイン駆動設計の本」スレッド。記録は数十秒で終わる。  
その後、外部LLM向け整形プロンプトを生成し、結果を貼り付けて構造化保存する。  
数日後、業務中に同テーマの質問を受ける。Hotake は検索して10秒以内に関連知識を開き、要点を説明できる。  
**感情変化:** 「忘れそうで不安」→「必要時に取り出せる安心」

### Journey 2: Primary User - Edge Case（整形失敗時の回復）

Hotake は未整理メモを整形しようとして、LLM出力を貼り付ける。  
しかしフォーマット崩れによりパースに失敗する。  
アプリは失敗理由（例: Body欠落）を明示し、Rawテキストを保持したまま再編集導線を提示する。  
Hotake はフォーマットガイドを参照し、再貼り付けまたは手動修正で保存を完了する。  
この回復フローにより、入力内容が失われないまま知識化を継続できる。  
**感情変化:** 「壊れたかもしれない不安」→「戻せる・直せる安心」

### Journey 3: Support/Troubleshooting User（自己サポート）

運用初期のサポート担当は Hotake 自身。  
「検索で出ない」「保存できなかった気がする」といった違和感が出たとき、エラー文言・失敗箇所・再試行結果を確認する。  
原因を切り分け、再保存・再整形・スレッド修正で復旧する。  
この自己サポート運用により、毎日の利用継続を止めずに改善サイクルを回せる。  
**感情変化:** 「原因不明の不安」→「対処可能という安心」

### Journey 4: Secondary User（将来想定）- 高学習量エンジニア

将来的な利用者である高学習量エンジニアは、学習メモが散在し再利用できない課題を抱える。  
MyAkashic でスレッド単位に知識を蓄積し、業務前後で短時間に検索・再学習を行う。  
まずは個人活用で価値を確認し、必要なら将来の共有機能を待つ。  
**感情変化:** 「情報が散らばる不安」→「知識が資産化される安心」

### Journey Requirements Summary

上記ジャーニーから必要になる能力:
- 2系統入力: 通常入力 + 共有シート入力
- スレッド管理: 作成/編集/削除と記録先スレッド選択
- 構造化導線: プロンプト生成、整形結果貼り付け、構造化保存
- 検索性能: 実務中に10秒以内で必要知識へ到達
- 回復可能性: パース失敗時の原因表示・再試行・手動修正
- 継続利用支援: 週次振り返りで再利用機会を再提示
- 自己サポート運用: トラブル時に復旧可能なフィードバックと再操作導線

## Domain-Specific Requirements

### Compliance & Regulatory

- 現時点で特定の業界規制（医療・金融・官公庁等）への準拠要件は設定しない
- general ドメインとして、標準的なソフトウェア開発上の法令順守を前提とする

### Technical Constraints

- 認証済みユーザーのみデータアクセス可能とする（Supabase Auth + RLS）
- MVPでは個人利用前提のため、セキュリティ/プライバシー要件は最小構成で運用する
- 外部LLM連携はアプリ内API直結ではなく、手動貼り付け方式を維持する（コストと運用単純性を優先）

### Integration Requirements

- 必須連携は以下に限定:
  - Supabase（認証・データ保存）
  - 外部LLM（プロンプト生成→手動貼り付け）
- 追加連携（カレンダー/タスク等）はMVP対象外

### Risk Mitigations

- リスク1: 記録漏れ
  - 対策: 通常入力 + 共有シート入力の二系統導線を維持
- リスク2: 誤整理（スレッド/タグ誤り）
  - 対策: スレッド編集導線と再編集フローを明確化
- リスク3: 検索で見つからない
  - 対策: タイトル/本文/タグ検索をMVP必須とし、検索応答・検索性を継続検証

## Project-Type Requirements

### Brownfield Context Clarification

本プロジェクトは「既存運用ドメイン（知識管理運用ルール・既存ドキュメント資産・Supabase運用前提）」への統合を行う brownfield と定義する。  
実装基盤は `create-expo-app` で新規ブートストラップするが、これは UI/クライアント実装の初期化手段であり、プロダクト要件・運用資産・データ基盤方針は既存資産を継承する。  
したがって本件は「実装基盤は新規初期化、プロダクト文脈は既存継承」の brownfield-on-new-runtime として扱う。

### Project-Type Overview

MyAkashic は Web / Mobile / Desktop 展開を前提としたマルチプラットフォーム知識活用プロダクト。  
初期方針は Web を SPA とし、ブラウザ対応は Chrome / Safari を優先する。  
Desktop は Mac を初期対象とする。  
共通価値は「即時記録→構造化→即時想起」であり、プラットフォーム差は入力導線と配布方式で吸収する。

### Technical Architecture Considerations

- プラットフォーム戦略:
  - Web: SPA
  - Mobile/Desktop: クロスプラットフォーム志向（詳細実装は後続設計で確定）
- サポート範囲（初期）:
  - Browser: Chrome, Safari
  - Desktop OS: Mac
- リアルタイム同期/Push通知:
  - 初期は不要（MVP外）
- オフライン:
  - 最小対応（下書きや一時保持レベル）
- 共通バックエンド:
  - Supabase（Auth + RLS + DB）を全クライアントの単一データ基盤とする

### Platform Requirements

- Web
  - SPA構成で主要機能を提供
  - SEO要件あり（インデックス可能な情報設計を考慮）
  - アクセシビリティ目標: WCAG AA相当
- Mobile
  - 既定の即時記録導線（通常入力 + Share Sheet）を維持
  - 通知はMVP対象外
- Desktop
  - Mac向け初期対応
  - 「右クリックから記録」導線を提供（モバイル共有導線に相当する即時入力体験）
  - 起動時および24時間ごとの更新チェックを行い、ユーザー承認後に更新を適用する

### Responsive Design Requirements

- ブレークポイントは `360-767px`（mobile）、`768-1023px`（tablet）、`1024px以上`（desktop）を基準とする
- Inbox / Capture / Detail / Review の主要画面は幅 `360px` で横スクロールなしで利用できること
- 主要操作（保存・検索・スレッド選択）は全ブレークポイントで2操作以内に到達できること
- モバイルの主要タップ領域は最小 `44x44px` を満たすこと
- 長文ノート表示は desktop で1行 `72ch` 程度を上限に可読性を維持すること

### Device Permissions & Integration

- Mobile
  - Share Sheet 受け取りに必要な権限を最小構成で利用
- Desktop
  - コンテキストメニュー連携（右クリック記録）を最優先
  - OS統合（グローバルショートカット等）は将来検討

### Desktop Update Strategy

- 配布は署名済みインストーラを使用し、更新パッケージも同様に署名検証する
- 重大なセキュリティ/安定性修正は24時間以内に更新通知を表示し、7日以内の適用率90%以上を目標とする
- 更新失敗時は既存バージョンを維持し、エラーログを保存した上で再試行導線を提供する
- ロールバックが必要な場合は直前の安定版インストーラで復旧できること

### Compliance & Distribution Considerations

- モバイル配布はストア要件（App Store / Google Play）を考慮する
- Desktop配布は署名済みインストーラとし、更新方式は「定期チェック + ユーザー承認適用」を採用する

### Performance Targets

- 検索応答: 1秒以内（既存成功基準と整合）
- 主要画面初回表示: 2秒以内を目安
- 許容しない遅延:
  - 業務中の検索で体感待ちが長く、10秒以内の知識到達目標を阻害する状態

### Implementation Considerations

- 右クリック記録導線は Desktop差別化の核として優先実装対象
- 通知/リアルタイムを外した分、入力成功率・検索速度・整理信頼性に開発リソースを集中
- プラットフォーム共通要件（検索、スレッド、構造化保存）を先に揃え、UI差異は薄く保つ

## Project Scoping & Phased Development

### MVP Strategy & Philosophy

**MVP Approach:** 問題解決MVP（最速でコア課題を解く）  
**Resource Requirements:** 3人以上を想定（PM/開発/補助ロールを含む）

### MVP Feature Set (Phase 1)

**Core User Journeys Supported:**
- 一次ユーザーの成功導線（学習中の即時記録 → 構造化 → 業務中の即時想起）
- 整形失敗時の回復導線（エラー表示・再編集・再保存）
- 自己サポート導線（トラブル時の復旧）

**Must-Have Capabilities:**
- 通常入力（Quick Capture）
- Share Sheet入力（モバイル）
- AI整形プロンプト作成（外部LLM手動連携）
- 構造化取り込みと知識管理
- 最上位スレッド（単一ノート）管理（作成/編集/削除）
- 検索（タイトル/本文/タグ）
- 週次振り返り（簡易）
- マルチプラットフォーム初期順序: Mobile → Web → Desktop（DesktopはMac初期対応）

### Post-MVP Features

**Phase 2 (Post-MVP):**
- 現時点では未確定
- 運用データ（継続率、再利用頻度、失敗率）を根拠に優先順位を決定する

**Phase 3 (Expansion):**
- アプリ内AI API連携による自動整理
- 共有/公開機能を含む拡張展開
- 両軸を統合した知識活用エコシステム化

### Risk Mitigation Strategy

**Technical Risks:**
- MVP段階では機能拡張よりも入力成功率・パース成功率・検索速度を優先的に監視
- 技術品質の基準を満たさない場合は機能追加ペースを抑制する

**Market Risks:**
- 最大リスクは「使い続けないこと」
- 継続率と再利用行動を最重要検証指標として、週次レビューで改善判断する

**Resource Risks:**
- 3人以上前提での進行計画を取りつつ、優先順位を明確化してスコープ膨張を防ぐ
- Phase 2を未確定に保ち、実測に基づく意思決定でリソース消耗を抑える

## Functional Requirements

### Access & Preferences

- FR1: Primary User can sign in to the product.
- FR2: Primary User can sign out of the product.
- FR3: Primary User can access only their own knowledge data.
- FR4: Primary User can select and update a default structuring provider.
- FR5: Primary User can set and update output language preferences.

### Capture & Ingestion

- FR6: Primary User can create a quick capture from in-app input.
- FR7: Primary User can save a capture as unstructured content.
- FR8: Primary User can create a capture from mobile share sheet input.
- FR9: Primary User can create a capture from desktop right-click context input.
- FR10: Primary User can add personal commentary when creating a capture.
- FR11: Primary User can cancel a capture flow without saving.

### Knowledge Thread (Single-Note) Management

- FR12: Primary User can create a top-level knowledge thread as a single note with a title.
- FR13: Primary User can rename a knowledge thread title.
- FR14: Primary User can delete a knowledge thread.
- FR15: Primary User can select a knowledge thread as capture destination.
- FR16: Primary User can append new captured content to the end of a selected knowledge thread.
- FR17: System can preserve append order within each knowledge thread.
- FR18: Primary User can view each knowledge thread as one continuous note.
- FR19: Primary User can edit previously appended segments in a knowledge thread.
- FR20: Primary User can remove previously appended segments from a knowledge thread.
- FR21: Primary User can add tags to a knowledge thread.
- FR22: Primary User can remove tags from a knowledge thread.
- FR23: Primary User can create links between knowledge threads.
- FR24: Primary User can edit links between knowledge threads.
- FR25: Primary User can remove links between knowledge threads.

### Structuring Workflow

- FR26: Primary User can generate a structuring prompt from a selected knowledge thread.
- FR27: Primary User can copy a generated structuring prompt.
- FR28: Primary User can open the selected external structuring provider from the product.
- FR29: Primary User can paste structured output into the product for processing.
- FR30: System can extract structured fields from pasted content.
- FR31: Primary User can review and edit extracted fields before applying them.
- FR32: System can create a fallback title when structured input lacks a title.
- FR33: System can preserve original thread content when structuring fails.
- FR34: Primary User can retry structuring after a failed parsing attempt.

### Search & Retrieval

- FR35: Primary User can search knowledge threads by title.
- FR36: Primary User can search within full thread content.
- FR37: Primary User can filter knowledge threads by tags.
- FR38: Primary User can open linked knowledge threads from a thread detail view.
- FR39: Primary User can view related knowledge threads from a thread detail view.

### Weekly Review

- FR40: Primary User can view a weekly review of recent learning content.
- FR41: System can resurface related historical knowledge threads in weekly review.
- FR42: Primary User can open resurfaced threads directly from weekly review.

### Support & Recovery

- FR43: Support User can view structuring failure reasons.
- FR44: Support User can reprocess failed structuring attempts.
- FR45: Support User can recover failed entries while preserving original content.

### Multi-Platform Delivery

- FR46: Primary User can use core workflows on mobile client.
- FR47: Primary User can use core workflows on web client.
- FR48: Primary User can use core workflows on desktop client.

## Non-Functional Requirements

### Performance

- NFR1: System can return search results within 1 second for the 95th percentile, measured by server-side APM timing logs over rolling 7-day windows under normal operating conditions.
- NFR2: System can render primary screens within 2 seconds for the 95th percentile, measured by client-side telemetry on supported browsers and devices under normal network conditions.
- NFR3: System can support user knowledge retrieval workflows that complete within 10 seconds for at least 95% of business-use sessions, measured from search submission to target thread open in product analytics.

### Security

- NFR4: System can block 100% of unauthenticated requests for protected user-data operations, verified by release-gate integration tests.
- NFR5: System can maintain 0 unauthorized cross-user read/write results in monthly authorization and RLS verification tests.
- NFR6: System can protect data in transit using TLS.
- NFR7: System can rely on platform-standard data protection controls for persisted data.

### Accessibility

- NFR8: Web client can satisfy WCAG AA-level accessibility requirements for core workflows.

### Integration

- NFR9: System can maintain functional integration with the configured authentication and data persistence service, with at least 99% successful auth and write transactions in daily health checks.
- NFR10: System can support external LLM structuring workflows with at least 95% successful end-to-end completion (prompt generation to manual result ingestion) in weekly smoke tests.

### Reliability

- NFR11: System can maintain 99.5% monthly availability for core workflows.
- NFR12: System can maintain a capture/save success rate of at least 99%.
- NFR13: System can maintain structured parsing success rate of at least 95%.

### Scalability

- NFR14: System architecture can support 10x growth from initial usage volumes in quarterly load tests while meeting NFR1-NFR3 targets.
