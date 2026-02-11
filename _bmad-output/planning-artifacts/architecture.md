---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8]
lastStep: 8
status: 'complete'
completedAt: '2026-02-11T18:42:21+0900'
inputDocuments:
  - _bmad-output/planning-artifacts/prd.md
  - _bmad-output/planning-artifacts/prd-validation-report.md
  - _bmad-output/planning-artifacts/product-brief-MyAkashic-2026-02-10-185929.md
  - _bmad-output/planning-artifacts/ux-design-specification.md
  - docs/knowledge-app-spec.md
  - docs/knowledge-app-ui-flow.md
  - docs/knowledge-app-implementation-plan.md
  - docs/knowledge-app-sudo-modeling.md
  - docs/docker-dev.md
  - docs/supabase-setup.md
workflowType: 'architecture'
project_name: 'MyAkashic'
user_name: 'Hotake'
date: '2026-02-11T17:48:35+0900'
---

# Architecture Decision Document

_This document builds collaboratively through step-by-step discovery. Sections are appended as we work through each architectural decision together._

## Project Context Analysis

### Requirements Overview

**Functional Requirements:**
本プロジェクトは 48 個のFRを持ち、以下の8カテゴリで構成される。
- Access & Preferences（認証、設定）
- Capture & Ingestion（通常入力、共有入力、右クリック入力）
- Knowledge Thread Management（単一ノート追記、順序保持、編集、リンク）
- Structuring Workflow（外部LLM前提の整形プロンプト生成、貼り付け解析、失敗回復）
- Search & Retrieval（タイトル/本文/タグ検索、関連遷移）
- Weekly Review（週次振り返り）
- Support & Recovery（失敗理由表示、再処理、復旧）
- Multi-Platform Delivery（Mobile/Web/Desktop横断）

建築的には、入力経路の多様性を共通ドメイン処理へ収束させること、単一ノート追記の整合性維持、整形失敗時のロスレス回復が中核となる。
ドメイン設計原則は DDD-lite を採用し、MVP段階から SUDOモデリングを正式プロセスとして実施する。
SUDO は `System / UseCase / Domain / Object` の4視点を必須とし、要件変更時は4視点の整合更新を完了条件とする。
また ユビキタス言語 を定義し、要件・UX・API・DB・実装・テストの語彙を単一基準で統制する。

**Non-Functional Requirements:**
主要なNFRドライバは以下。
- 検索 p95 1秒以内
- 主要画面表示 p95 2秒以内
- 検索→目的ノート到達 p95 10秒以内
- 保存成功率 99%以上
- 構造化パース成功率 95%以上
- 可用性 99.5% / 月
- 認証未通過操作の遮断、RLSでのユーザー分離
- WebでWCAG AA相当
- Supabase連携成功率、外部LLM整形フロー成功率の継続監視

NFRは「速さ」だけでなく「入力を失わない信頼性」と「実務中の再利用速度」を同時達成する設計を要求する。
品質実現プロセスとして、TDD をドメイン層・ユースケース層の標準開発手法に含める。

**Scale & Complexity:**
マルチプラットフォーム展開と複数入力導線により、実装面は中規模以上。ただしリアルタイム同期や厳格規制がないため、全体難易度は中程度に収まる。

- Primary domain: マルチプラットフォーム知識活用（full-stack）
- Complexity level: medium
- Estimated architectural components: 11

### Technical Constraints & Dependencies

- バックエンドは Supabase（Auth + Postgres + RLS）を前提
- 外部LLM連携はAPI直結ではなく、プロンプト生成→外部実行→手動貼り付け
- WebはSPA、優先ブラウザはChrome/Safari
- MobileはOS共有導線を重視
- DesktopはMac初期対応、右クリック記録導線を要求
- オフラインは最小対応（下書き/一時保持）
- Push/リアルタイムはMVP対象外
- WebはSEO要件あり、全体でWCAG AA相当の実装品質が必要
- 設計原則は DDD-lite + Clean Architecture
- DDDモデリング手法として SUDOモデリング（System/UseCase/Domain/Object）を標準採用
- ユビキタス言語辞書 を単一ソースとして管理し、要件・設計・実装・テストで同一語彙を使用
- 品質ゲートとして TDD（unit）+ 契約/統合テスト を導入する

#### DDD/SUDO/ユビキタス言語の厳格運用ルール

- 単一ソース:
  - `docs/knowledge-app-sudo-modeling.md` をSUDO公式モデルとする
  - `docs/knowledge-app-spec.md` の用語定義をユビキタス言語の基準とする
- 用語辞書の必須項目:
  - `canonical_term`（正規語）
  - `definition`（定義）
  - `bounded_context`
  - `invariants`（不変条件）
  - `allowed_aliases`
  - `forbidden_aliases`
  - `owner`
- 変更管理（必須）:
  - 用語追加/変更は「定義更新 → 影響範囲更新（PRD/UX/API/DB/Test） → 承認」を1セットで実施
  - 別名の暗黙導入を禁止（`forbidden_aliases` に明示）
  - 削除語は即削除せず `deprecated` 扱いで移行期間を設ける
- SUDO更新トリガー:
  - FR追加・主要フロー変更・集約境界変更・不変条件変更時は必ずSUDO全視点を再確認
- PR受け入れ条件:
  - 「モデル変更なし」または「SUDO/用語辞書更新済み」を明記
  - 新規API/DB項目名が正規語と一致すること
  - テスト名とシナリオ文言がユビキタス言語に一致すること
- テスト規約:
  - ドメイン不変条件はTDDで先に失敗テストを定義
  - 主要ユースケースは Given/When/Then で正規語を使用
  - 用語不一致・別名混入を検知する静的チェック（lint/CI）を導入

### Cross-Cutting Concerns Identified

- 認証・認可・RLSによるデータ分離
- ロスレス保存（失敗時入力保持、再試行可能性）
- 追記順序保証と単一ノート一貫性
- 整形パースの堅牢性（フォーマット逸脱時の回復）
- パフォーマンス監視（検索/表示/再利用時間のSLO）
- 可観測性（成功率、失敗理由、回復率の計測）
- アクセシビリティ（WCAG AA）とクロスデバイス一貫UX
- プラットフォーム固有導線（共有/右クリック）の共通ドメイン統合
- DDDの不変条件保護（集約境界を跨ぐ更新制御）
- TDDベースの回帰防止（ドメイン仕様をテストで固定）
- ユビキタス言語ガバナンス（新語追加・意味変更・廃止語管理）
- SUDOモデルと実装差分の継続検証（設計ドリフト防止）

## Starter Template Evaluation

### Primary Technology Domain

Mobile-first full-stack（Expo React Native + Supabase） based on project requirements analysis.

### Starter Options Considered

1. Expo `create-expo-app`（default / tabs / blank-typescript）
- React Native公式方針（framework推奨）と整合。
- `default` と `tabs` は Expo Router + TypeScript を標準で含む。
- Android / iOS / Web を単一コードベースで展開可能。

2. Next.js `create-next-app`
- Web/SEO観点では強力。
- ただし本案件のMVP価値（スマホ共有起点）を最短で満たす主軸としては優先度が下がる。

3. Desktop starters（Tauri / Electron Forge）
- Desktop右クリック導線には有効。
- ただしMVP主軸のモバイル共有導線を直接満たせないため、初期スターターの主候補からは外す。

### Selected Starter: create-expo-app (tabs template)

**Rationale for Selection:**
- コア要件（スマホ共有から即記録）に最短で合致する。
- TypeScript + file-based routing を初期状態で確保できる。
- DDD-lite / Clean Architecture / TDD を後続で載せる基盤として軽量で拡張しやすい。
- Web検証も同基盤で進められ、MVPの一貫性と速度を両立できる。

**Initialization Command:**

```bash
npx create-expo-app@latest myakashic-app --template tabs
```

**Architectural Decisions Provided by Starter:**

**Language & Runtime:**
TypeScript 有効の Expo + React Native 構成。

**Styling Solution:**
React Native標準スタイルを前提に開始し、後続でカスタムデザインシステムを実装する。

**Build Tooling:**
Expo CLI (`npx expo start`) を中心とした開発/検証フロー。

**Testing Framework:**
スターター時点では最小構成。TDD実践のための unit / integration / contract テスト基盤は後続アーキ判断で追加する。

**Code Organization:**
Expo Routerの file-based routing を起点に、ドメイン層を別ディレクトリで明確分離する方針。

**Development Experience:**
初期セットアップが軽く、Capture / Search / Thread のコアフロー実装に集中しやすい。

**Version Verification Notes:**
- create-expo-app templates（`tabs`含む）: docs.expo.dev/more/create-expo/
- Expo Router install & tabs: docs.expo.dev/router/installation/ , docs.expo.dev/router/advanced/tabs/
- React Native framework recommendation: reactnative.dev
- Supabase Expo guides: supabase.com/docs/guides/with-expo , supabase.com/docs/guides/getting-started/quickstarts/expo-react-native

**Note:** Project initialization using this command should be the first implementation story.

### Brownfield Lifecycle Clarification

本件は brownfield プロジェクトとして扱う。  
ここでの brownfield は「既存の業務文脈・要件資産・運用方針（PRD/UX/SUDO/用語辞書/Supabase運用前提）を継承する」ことを意味する。  
`create-expo-app` 採用は実装ランタイム初期化のためであり、プロダクト計画を greenfield に再定義するものではない。  
したがってアーキテクチャ判断は「既存文脈継承 + 新規実装基盤初期化」の前提で行う。

## Core Architectural Decisions

### Decision Priority Analysis

**Critical Decisions (Block Implementation):**
- Mobile-first を前提に Expo + Supabase を中心構成とする
- Data は Supabase Postgres + SQL migrations（Supabase CLI）で管理する
- 認証は Supabase Auth の Magic Link のみに絞る（MVP）
- API は BFF レイヤーを導入し、クライアントは業務APIを直接DBへ書き込まない
- 状態管理は TanStack Query（サーバー状態）+ Zustand（UI/一時状態）で分離する
- 配布は EAS Build/Submit（モバイル）+ Vercel（Web）を採用する
- 監視は Sentry + Supabase logs + KPIイベントを最小構成で導入する

**Important Decisions (Shape Architecture):**
- DDD-lite + SUDOモデリング + ユビキタス言語統制を、API命名/DB命名/テスト命名へ強制適用
- BFF は REST を採用し、入力検証をBFF境界で必須化
- 失敗時入力保持（lossless）を全入力導線で共通要件にする
- 観測KPI（保存成功率、パース成功率、検索到達時間）をリリース基準に直結させる

**Deferred Decisions (Post-MVP):**
- OAuth（Google/Apple等）の追加
- オフライン同期（ローカルSQLite本格運用）
- リアルタイム同期/Push通知
- 公開/共有機能とその権限モデル
- BFF のマイクロサービス分割

### Data Architecture

- **Database**: Supabase Postgres（単一SoR）
- **Modeling**: Knowledge Thread（単一ノート追記）中心の集約設計
- **Validation**:
  - ドメイン不変条件はドメイン層で検証
  - API入出力はスキーマ検証（Zod）で境界防御
- **Migration**: Supabase CLI によるSQLマイグレーション運用
- **Caching**:
  - クライアントは TanStack Query cache を標準利用
  - サーバー側の分散キャッシュはMVPでは導入しない
- **Draft handling**:
  - 最小ローカル下書き保存を導入し、送信失敗でも入力ロストを防ぐ

### Authentication & Security

- **Authentication**: Supabase Auth Magic Link（MVP唯一手段）
- **Authorization**: RLSを前提にユーザー境界をDBで強制
- **Session handling**: Expoクライアントで安全な永続化戦略を適用
- **API security**:
  - BFF経由の業務APIに認証必須
  - service role key はサーバー側のみ保持
- **Data protection**:
  - 通信TLS前提
  - クライアント公開可能キーのみ端末配布

### API & Communication Patterns

- **Pattern**: REST + BFF（Supabase Edge Functions を業務API層として採用）
- **Routing policy**:
  - `/captures`, `/threads`, `/threads/:id/segments`, `/structured-previews`, `/reviews/*` を業務境界として分割
- **Error handling**:
  - エラーコードを統一（validation/auth/not_found/conflict/internal）
  - 失敗時に再試行可能情報を返す
- **Rate limiting**:
  - MVPは軽量制御（BFF単位の基本制限）
- **Communication**:
  - Client → BFF → Supabase
  - クライアントからの直接的な特権操作は禁止
- **Portability policy**:
  - Edge Functions は薄いアダプタ層に限定
  - ドメインロジックは `domain/application` 層へ隔離
  - Repository Interface 経由でDB依存を抽象化
  - API契約を OpenAPI + 契約テストで固定し、実行基盤を差し替え可能にする

### Frontend Architecture

- **State separation**:
  - TanStack Query: サーバー状態（threads/search/review）
  - Zustand: ローカルUI状態（入力途中、フィルタ、モーダル、一時選択）
- **Routing**: Expo Router（tabsテンプレ起点）
- **Component architecture**:
  - Presentation/Application/Domain の責務分離
  - 共有入力導線・通常入力導線・右クリック導線を同一ユースケースへ集約
- **Performance**:
  - Queryキー設計を明示し、不要再取得を抑制
  - 大きいノート表示は段階レンダリング方針を採用

### Infrastructure & Deployment

- **Mobile**: EAS Build/Submit を標準パイプライン化
- **Web**: Vercel へデプロイ（SPAホスティング）
- **Backend**: Supabase managed services
- **CI/CD**:
  - main/release ブランチで build + test + lint + typecheck
  - リリース前にKPI系のスモーク計測を実行
- **Environment config**:
  - `dev/stg/prod` の分離
  - 秘密情報はCIシークレット/環境変数で管理
- **Compute split policy**:
  - MVPはEdge Functionsを採用
  - 長時間処理/高負荷非同期は外部実行基盤へ分離可能な設計を維持

### Observability & Quality Gates

- **Error monitoring**: Sentry（React Native/Web）
- **Operational logs**: Supabase logs
- **Product KPIs**:
  - capture/save success rate
  - structuring parse success rate
  - search-to-open duration
- **Quality gates**:
  - 保存成功率99%以上
  - パース成功率95%以上
  - 検索→到達時間 p95 10秒以内
- **Testing policy**:
  - TDDをドメイン/ユースケース層で適用
  - 契約テストでBFFとクライアントの整合を固定

### Vendor Lock-in Mitigation Rules

- **Lock-in boundary:**
  - Supabase固有依存は `infrastructure/adapter` 層に限定
  - `domain/application` はSupabase SDKを直接参照しない
- **Change control:**
  - Supabase固有機能を導入するPRは、代替手段と移行時影響範囲の記載を必須化
- **Exit readiness:**
  - 四半期ごとに BFF差し替え可能性を点検（契約テスト通過を基準）
  - 主要ユースケース（capture/search/thread）の移行難易度を継続評価

### Decision Impact Analysis

**Implementation Sequence:**
1. Expo初期化 + Supabase接続 + RLS方針確定
2. BFF（Edge Functions）骨格 + 入出力検証 + エラー標準化
3. Capture/Thread/Search の主要ユースケース実装
4. TanStack Query/Zustand で状態分離
5. Sentry/KPIイベント導入
6. EAS/Vercel デプロイパイプライン確立

**Cross-Component Dependencies:**
- BFF方針は認証・RLS・監視・テスト設計に直結
- DDD/SUDO/ユビキタス言語はAPI命名・DB命名・テスト名の一貫性を拘束
- 観測KPIはUX成功指標とリリース判定を接続する

## Project Structure & Boundaries

### Complete Project Directory Structure

```text
myakashic-app/
├── README.md
├── package.json
├── tsconfig.json
├── app.json
├── babel.config.js
├── .env.example
├── .gitignore
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── release.yml
├── docs/
│   ├── knowledge-app-spec.md
│   ├── knowledge-app-sudo-modeling.md
│   ├── architecture.md
│   └── adr/
│       └── 0001-bff-and-portability-policy.md
├── contracts/
│   └── openapi/
│       ├── api.yaml
│       └── schemas/
│           ├── common.yaml
│           ├── capture.yaml
│           ├── thread.yaml
│           └── structuring.yaml
├── supabase/
│   ├── config.toml
│   ├── migrations/
│   │   ├── 202602110001_init.sql
│   │   ├── 202602110002_threads.sql
│   │   └── 202602110003_indexes.sql
│   ├── seed.sql
│   └── functions/
│       ├── _shared/
│       │   ├── auth.ts
│       │   ├── response.ts
│       │   ├── errors.ts
│       │   └── validation.ts
│       ├── captures/
│       │   └── index.ts
│       ├── thread-segments/
│       │   └── index.ts
│       ├── threads/
│       │   └── index.ts
│       ├── structured-previews/
│       │   └── index.ts
│       └── weekly-reviews/
│           └── index.ts
├── src/
│   ├── app/
│   │   ├── _layout.tsx
│   │   ├── (tabs)/
│   │   │   ├── _layout.tsx
│   │   │   ├── inbox.tsx
│   │   │   ├── capture.tsx
│   │   │   ├── review.tsx
│   │   │   └── settings.tsx
│   │   ├── thread/
│   │   │   └── [id].tsx
│   │   ├── share/
│   │   │   └── ingest.tsx
│   │   └── modals/
│   │       ├── category-picker.tsx
│   │       └── structuring-recovery.tsx
│   ├── domain/
│   │   ├── thread/
│   │   │   ├── ThreadAggregate.ts
│   │   │   ├── Segment.ts
│   │   │   ├── ThreadRepository.ts
│   │   │   └── ThreadAggregate.test.ts
│   │   ├── capture/
│   │   │   ├── CaptureDraft.ts
│   │   │   └── CaptureDraft.test.ts
│   │   ├── structuring/
│   │   │   ├── StructuredContent.ts
│   │   │   └── StructuredContent.test.ts
│   │   └── shared/
│   │       ├── DomainError.ts
│   │       └── Invariants.ts
│   ├── application/
│   │   ├── usecases/
│   │   │   ├── CreateCaptureUseCase.ts
│   │   │   ├── AppendToThreadUseCase.ts
│   │   │   ├── SearchThreadUseCase.ts
│   │   │   ├── ParseStructuredContentUseCase.ts
│   │   │   └── GetWeeklyReviewUseCase.ts
│   │   ├── dto/
│   │   │   ├── capture.dto.ts
│   │   │   ├── thread.dto.ts
│   │   │   └── structuring.dto.ts
│   │   └── ports/
│   │       ├── ThreadGateway.ts
│   │       ├── CaptureGateway.ts
│   │       └── StructuringGateway.ts
│   ├── infrastructure/
│   │   ├── api/
│   │   │   ├── client.ts
│   │   │   ├── capture.api.ts
│   │   │   ├── thread.api.ts
│   │   │   └── structuring.api.ts
│   │   ├── supabase/
│   │   │   ├── client.ts
│   │   │   └── auth-session.ts
│   │   ├── repositories/
│   │   │   ├── ThreadRepositorySupabase.ts
│   │   │   └── CaptureRepositorySupabase.ts
│   │   └── telemetry/
│   │       ├── sentry.ts
│   │       └── kpi-events.ts
│   ├── presentation/
│   │   ├── components/
│   │   │   ├── capture/
│   │   │   │   ├── QuickCaptureLauncher.tsx
│   │   │   │   └── ShareIngestPreview.tsx
│   │   │   ├── thread/
│   │   │   │   ├── ThreadListItem.tsx
│   │   │   │   └── ThreadDetailView.tsx
│   │   │   ├── structuring/
│   │   │   │   └── StructuringRecoveryPanel.tsx
│   │   │   └── common/
│   │   │       ├── AppButton.tsx
│   │   │       ├── AppInput.tsx
│   │   │       ├── AppToast.tsx
│   │   │       └── LoadingState.tsx
│   │   ├── hooks/
│   │   │   ├── useCapture.ts
│   │   │   ├── useThreadSearch.ts
│   │   │   └── useStructuring.ts
│   │   └── state/
│   │       ├── capture.store.ts
│   │       ├── ui.store.ts
│   │       └── filters.store.ts
│   ├── shared/
│   │   ├── constants/
│   │   │   ├── endpoints.ts
│   │   │   ├── query-keys.ts
│   │   │   └── app-tokens.ts
│   │   ├── schemas/
│   │   │   ├── capture.schema.ts
│   │   │   ├── thread.schema.ts
│   │   │   └── common.schema.ts
│   │   ├── types/
│   │   │   ├── api.ts
│   │   │   └── domain.ts
│   │   └── utils/
│   │       ├── date.ts
│   │       ├── error-map.ts
│   │       └── logger.ts
├── tests/
│   ├── contracts/
│   │   ├── captures-post.contract.test.ts
│   │   ├── thread-segments-post.contract.test.ts
│   │   └── structured-previews-post.contract.test.ts
│   ├── integration/
│   │   ├── capture-flow.integration.test.ts
│   │   └── search-flow.integration.test.ts
│   └── e2e/
│       ├── mobile-capture.e2e.ts
│       └── web-search.e2e.ts
└── scripts/
    ├── check-ubiquitous-language.mjs
    └── check-schema-drift.mjs
```

### Architectural Boundaries

**API Boundaries:**
- Public client API:
  - `POST /api/v1/captures`
  - `GET /api/v1/threads`
  - `GET /api/v1/threads/:id`
  - `POST /api/v1/threads/:id/segments`
  - `POST /api/v1/structured-previews`
  - `GET /api/v1/reviews/weekly`
- All responses: `{ data, error, meta }`
- Client never uses service-role capabilities.

**Component Boundaries:**
- `presentation` はUI責務のみ
- `application` がユースケース調停
- `domain` が不変条件・業務ルールの唯一の正本
- `infrastructure` がSupabase/Edge/Sentry等の外部依存を隔離

**Service Boundaries:**
- Edge Functions は薄いアダプタ層
- Domain logic is not implemented in function handlers
- Shared auth/validation/response utility in `supabase/functions/_shared`

**Data Boundaries:**
- SoR: Supabase Postgres
- Naming: `snake_case` strict
- Date format: ISO 8601 UTC
- Migrations only via `supabase/migrations/*.sql`

### Requirements to Structure Mapping

**FR Category Mapping:**
- Access & Preferences → `src/app/(tabs)/settings.tsx`, `src/infrastructure/supabase/auth-session.ts`
- Capture & Ingestion → `src/app/(tabs)/capture.tsx`, `src/app/share/ingest.tsx`, `supabase/functions/captures`
- Knowledge Thread Management → `src/domain/thread/*`, `supabase/functions/thread-segments`
- Structuring Workflow → `src/application/usecases/ParseStructuredContentUseCase.ts`, `supabase/functions/structured-previews`
- Search & Retrieval → `src/presentation/hooks/useThreadSearch.ts`, `supabase/functions/threads`
- Weekly Review → `src/app/(tabs)/review.tsx`, `supabase/functions/weekly-reviews`
- Support & Recovery → `src/presentation/components/structuring/StructuringRecoveryPanel.tsx`
- Multi-Platform Delivery → Expo Router配下全体 + CI/CD

**Cross-Cutting Concerns:**
- Auth/RLS: `supabase/*`, `src/infrastructure/supabase/*`
- Observability: `src/infrastructure/telemetry/*`
- Ubiquitous language enforcement: `scripts/check-ubiquitous-language.mjs`
- Contract consistency: `contracts/openapi/*`, `tests/contracts/*`

### Integration Points

**Internal Communication:**
- UI → UseCase → Gateway interface → Infrastructure adapter
- Query state and UI state are strictly separated (TanStack Query / Zustand)

**External Integrations:**
- Supabase Auth + Postgres + Edge Functions
- Sentry
- Vercel (web hosting)
- EAS Build/Submit (mobile delivery)

**Data Flow:**
1. Capture input
2. BFF endpoint validation
3. Domain invariants check
4. Repository persistence
5. Response wrapper return
6. KPI event + log emit

### File Organization Patterns

**Configuration Files:**
- Root-level app/build config
- `supabase/config.toml` for backend infra
- `.env.example` defines required runtime vars only

**Source Organization:**
- Layered + feature-oriented hybrid
- Domain-centered core, adapters at edges

**Test Organization:**
- Unit tests co-located (`*.test.ts`)
- Contract tests centralized (`tests/contracts`)
- Integration/E2E separated by purpose

**Asset Organization:**
- Static assets under Expo conventions
- API schemas/contracts under `contracts/openapi`

### Development Workflow Integration

**Development Server Structure:**
- Expo local dev: mobile/web from one codebase
- Supabase local emulation for DB/functions where needed

**Build Process Structure:**
- CI: lint → typecheck → unit → contract → integration
- Release gates include KPI smoke checks

**Deployment Structure:**
- Mobile via EAS channels
- Web via Vercel environments
- Supabase migrations and functions deployed as separate controlled stages

## Implementation Patterns & Consistency Rules

### Pattern Categories Defined

**Critical Conflict Points Identified:**
12 areas where AI agents could make different choices

### Naming Patterns

**Database Naming Conventions:**
- Table: `snake_case` plural（例: `knowledge_threads`, `thread_segments`）
- Column: `snake_case`（例: `user_id`, `created_at`）
- FK: `<ref>_id`（例: `thread_id`）
- Index: `idx_<table>_<column>`（例: `idx_knowledge_threads_user_id`）

**API Naming Conventions:**
- Resource-based REST endpointsを採用
- Base: `/api/v1`
- Format: `/api/v1/<plural-resource>` と `/api/v1/<plural-resource>/:id/<sub-resource>`
- Examples:
  - `POST /api/v1/captures`
  - `GET /api/v1/threads`
  - `GET /api/v1/threads/:id`
  - `POST /api/v1/threads/:id/segments`
  - `POST /api/v1/structured-previews`
  - `GET /api/v1/reviews/weekly`
- Route paramsは `:id` 形式（例: `/api/v1/threads/:id`）
- Query keysは `snake_case`

**Code Naming Conventions:**
- Component: `PascalCase`（例: `ThreadDetailCard`）
- Function/variable: `camelCase`（例: `appendToThread`, `threadId`）
- File:
  - React component file: `PascalCase.tsx`
  - Utility file: `kebab-case.ts`
  - Test file: `<target>.test.ts`

### Structure Patterns

**Project Organization:**
- `domain/`：Entity, ValueObject, DomainService, Repository interface
- `application/`：UseCase, DTO, Ports
- `infrastructure/`：Supabase adapter, API client, persistence
- `presentation/`：screens/components/hooks/state

**File Structure Patterns:**
- Unit testsは対象コードと同居（`*.test.ts`）
- 契約テストは `tests/contracts/` に集約
- API schemaは `contracts/openapi/` を単一ソースにする
- 用語辞書とSUDOは `docs/` を正本とする

### Format Patterns

**API Response Formats:**
- Success/Failureとも wrapper を固定: `{ data, error, meta }`
- Success例:
  - `error = null`
  - `meta.request_id`, `meta.timestamp`
- Failure例:
  - `data = null`
  - `error.code`, `error.message`, `error.retryable`, `error.details`

**Data Exchange Formats:**
- Date/Timeはすべて ISO 8601（UTC, `Z`）
- JSON keyは `snake_case`
- Booleanは `true/false`
- Nullは未設定のみ許可（空文字で代替しない）

### Communication Patterns

**Event System Patterns:**
- Event名: `domain.action.v1`（例: `thread.appended.v1`）
- Payload必須項目: `event_id`, `occurred_at`, `actor_id`, `thread_id`
- Event本文のキーは `snake_case`

**State Management Patterns:**
- TanStack Query: サーバー状態のみ
- Zustand: UI/一時状態のみ
- Query cacheの内容をZustandへ複製しない
- Action命名: `<feature><Verb>`（例: `captureSetDraft`, `searchSetQuery`）

### Process Patterns

**Error Handling Patterns:**
- ドメインエラーは即時表示（自動リトライしない）
- 再試行可能エラー（network/timeout/5xx）のみ自動リトライ
- 入力内容は失敗時に必ず保持（lossless）
- 例外ログはSentryに送信し、ユーザー向け文言は簡潔に分離

**Loading State Patterns:**
- Query系: `isLoading`, `isFetching`, `isError` をUIに明示
- Mutation系: ボタン単位でpending制御
- 全画面ローディングは初回ロード時のみ許可
- 再取得中はスケルトンより既存表示維持を優先

### Enforcement Guidelines

**All AI Agents MUST:**
- API/DB/JSON命名規約を厳守する（逸脱PRはreject）
- APIレスポンスwrapper `{data,error,meta}` を厳守する
- Query/Zustand責務分離を厳守する
- ユビキタス言語辞書にない語を新規導入しない
- SUDO更新トリガー発生時は docs更新なしで実装変更しない

**Pattern Enforcement:**
- CI checks:
  - naming lint（forbidden aliases検出）
  - OpenAPI contract check
  - schema drift check
  - test gate（unit + contracts）
- 逸脱管理:
  - `architecture-deviation` ラベルでPR記録
  - 承認なき逸脱はマージ禁止
- 更新プロセス:
  - ルール変更はADRと同時提出
  - 変更後にテンプレ実装例を必ず更新

### Pattern Examples

**Good Examples:**
- `POST /api/v1/threads/:id/segments`
- Response:
  - `{ "data": { "thread_id": "..." }, "error": null, "meta": { "timestamp": "2026-02-11T09:00:00Z" } }`
- Test placement:
  - `src/domain/thread/ThreadAggregate.test.ts`
  - `tests/contracts/thread-segments-post.contract.test.ts`

**Anti-Patterns:**
- `POST /api/v1/thread/append`（動詞中心でREST慣習から逸脱）
- 成功時は生JSON、失敗時だけwrapper（形式不一致）
- Query結果をZustandへ二重保持（責務衝突）
- `createdAt` と `created_at` の混在

## Architecture Validation Results

### Coherence Validation ✅

**Decision Compatibility:**
- Expo + Supabase + Edge Functions + TanStack Query/Zustand + Sentry の組み合わせは整合している。
- DDD-lite / SUDO / ユビキタス言語統制は、BFF構成と矛盾しない。
- REST命名への変更を全セクションに反映済みで、命名規約の衝突はない。

**Pattern Consistency:**
- 命名、レスポンス形式、状態管理責務、エラー処理、テスト配置の規約は相互整合している。
- CI強制（用語lint/契約テスト/スキーマドリフト）が運用ルールと一致している。

**Structure Alignment:**
- 定義したディレクトリ構造は、レイヤ分離（presentation/application/domain/infrastructure）を満たす。
- Supabase Functions は薄いアダプタとして分離され、ドメインロジック混入を防げる。

### Requirements Coverage Validation ✅

**Feature Coverage:**
- Capture, Thread, Structuring, Search, Review, Recovery の主要機能は全て配置先が明示されている。
- Mobile共有導線とDesktop右クリック導線を吸収する構造が定義済み。

**Functional Requirements Coverage:**
- FRカテゴリ（Access/Capture/Thread/Structuring/Search/Review/Recovery/Multi-platform）は全て構造へマッピング済み。
- 主要導線の実装先・API・テスト配置が定義済み。

**Non-Functional Requirements Coverage:**
- 性能要件（検索/表示/10秒到達）はKPI計測と品質ゲートに接続済み。
- セキュリティ要件（認証/RLS/秘密情報境界）は構成上担保可能。
- 可用性・信頼性は監視（Sentry/Supabase logs）と再試行規約で支援される。

### Implementation Readiness Validation ✅

**Decision Completeness:**
- クリティカル判断は記録済み。
- 技術方針と運用方針（ロックイン緩和含む）が実装可能な粒度で定義済み。

**Structure Completeness:**
- 主要ファイル群、テスト配置、契約配置、スクリプト配置が具体化されている。
- コンポーネント境界・データ境界・API境界が明示されている。

**Pattern Completeness:**
- AI競合ポイント（命名/形式/状態/エラー/テスト/用語）を網羅。
- 強制方法（CIゲート、逸脱ラベル運用）が規定済み。

### Gap Analysis Results

**Critical Gaps:** none

**Important Gaps:**
- Edge Functionsの重処理分離基準は、運用開始後にADRで具体閾値を追加するとより堅牢になる。

**Nice-to-Have Gaps:**
- 用語lintの辞書ファイル形式（JSON/YAML）を固定すると導入が容易になる。

### Validation Issues Addressed

- REST慣習との乖離懸念: resource-based endpoint へ全面移行し解消済み。
- ベンダーロック懸念: adapter分離 + 契約固定 + Exit評価ルールで対処済み。
- 実装ぶれ懸念: 形式統一とCI強制で対処済み。

### Architecture Completeness Checklist

**✅ Requirements Analysis**
- [x] Project context thoroughly analyzed
- [x] Scale and complexity assessed
- [x] Technical constraints identified
- [x] Cross-cutting concerns mapped

**✅ Architectural Decisions**
- [x] Critical decisions documented with versions
- [x] Technology stack fully specified
- [x] Integration patterns defined
- [x] Performance considerations addressed

**✅ Implementation Patterns**
- [x] Naming conventions established
- [x] Structure patterns defined
- [x] Communication patterns specified
- [x] Process patterns documented

**✅ Project Structure**
- [x] Complete directory structure defined
- [x] Component boundaries established
- [x] Integration points mapped
- [x] Requirements to structure mapping complete

### Architecture Readiness Assessment

**Overall Status:** READY FOR IMPLEMENTATION  
**Confidence Level:** high

**Key Strengths:**
- 要件と構造の対応関係が明確
- ルール強制の運用（CI）が具体的
- ロックイン対策を明示した上でMVP速度を維持

**Areas for Future Enhancement:**
- Edge Functionsから外部実行基盤へ分離する閾値のADR化
- 用語辞書フォーマットの機械可読化

### Implementation Handoff

**AI Agent Guidelines:**
- Architectural decisions and consistency rules must be followed exactly.
- Ubiquitous language and SUDO updates are mandatory when domain boundaries change.
- Contract tests and naming checks are release gates.

**First Implementation Priority:**
`npx create-expo-app@latest myakashic-app --template tabs`
