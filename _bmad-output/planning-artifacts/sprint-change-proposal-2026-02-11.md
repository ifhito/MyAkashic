# Sprint Change Proposal

**Date:** 2026-02-11
**Project:** MyAkashic
**Workflow:** Correct Course
**Mode:** Incremental

## Section 1: Issue Summary

### Problem Statement
実装準備レビューの結果、以下3点がスプリント実行リスクとして顕在化した。

1. 全Storyに `FR Reference` がなく、要件トレーサビリティが低い
2. Epic 6（特に Story 6.1/6.2）の粒度が大きく、単一devセッション原則に対して過大
3. `projectType: brownfield` と `create-expo-app` 初期化方針の整合説明が不足

### Discovery Context
- 発見タイミング: Implementation Readiness Assessment 実施時
- 発見根拠: `_bmad-output/planning-artifacts/implementation-readiness-report-2026-02-11.md`

### Evidence
- Story単位FR参照不足（全32 story）
- Epic 6 の複数プラットフォーム同時達成ストーリー
- PRD frontmatter の brownfield 指定と、Story 1.1 / Architecture の starter 明記の解釈差

## Section 2: Impact Analysis

### Epic Impact
- Epic 1〜6: 全Storyに `FR Reference`（必要に応じ `NFR Reference`）追加が必要
- Epic 6: ストーリー再編が必要
  - 旧6.1を Web と Mobile へ分割
  - 旧6.2を Desktop基本導線 と Desktop右クリック統合へ分割

### Story Impact
- 影響範囲: 現行全Story（1.1〜6.5）と、提案後のEpic 6再編（6.1〜6.7）
- 重点変更: Epic 6 の再番号付け・責務分離
- 将来影響: 実装チケット分割、見積り、テストケース粒度

### Artifact Conflicts
- PRD: brownfield定義の具体化が必要
- Architecture: brownfieldとstarter採用のライフサイクル整合追記が必要
- Epics: FR参照の明示、Epic 6分割を反映する必要
- UX: 粒度変更による責務マッピングの補足（必須ではないが推奨）

### Technical Impact
- コード: 直ちに破壊的影響なし（計画修正フェーズ）
- インフラ: 変更なし
- CI/CD: Story分割後のテスト・契約テスト紐付け更新が必要
- スプリント運用: `sprint-status.yaml` への反映を実施済み（`_bmad-output/implementation-artifacts/sprint-status.yaml`）

## Section 3: Recommended Approach

### Selected Path
**Option 1: Direct Adjustment**

### Why This Path
- Effort: Medium
- Risk: Low
- Timeline impact: 小〜中（計画修正1サイクル）

この課題は、既存構造を活かした文書・粒度調整で解消できる。ロールバックやMVP再定義を行う必要はなく、最短で実装着手可能性を回復できる。

### Options Considered
- Option 2 (Rollback): Not viable（巻き戻し利益が小さくコスト高）
- Option 3 (PRD MVP Review): Partially viable（今回は不要、前提明文化で解消可能）

## Section 4: Detailed Change Proposals

### A. Stories / Epics Changes

#### Change A1: Story-level FR traceability
**Artifact:** `_bmad-output/planning-artifacts/epics.md`

**OLD (example: Story 2.1)**
```md
### Story 2.1: アプリ内クイックキャプチャ作成
As a Primary User,
I want アプリ内から1操作でキャプチャ入力を開始したい,
So that 記録したい瞬間を逃さない。
```

**NEW (example: Story 2.1)**
```md
### Story 2.1: アプリ内クイックキャプチャ作成
As a Primary User,
I want アプリ内から1操作でキャプチャ入力を開始したい,
So that 記録したい瞬間を逃さない。

**FR Reference:** FR6
```

**Rationale:** PRD→Epic→Story の追跡容易化

#### Change A2: Epic 6 split (6.1)
**Artifact:** `_bmad-output/planning-artifacts/epics.md`

**OLD**
```md
### Story 6.1: モバイル・Web共通コア導線提供
As a Primary User,
I want モバイルとWebで共通の主要導線（記録/検索/参照）を使いたい,
So that 利用環境が変わっても同じ操作感で使える。
```

**NEW**
```md
### Story 6.1: Webコア導線提供
As a Primary User,
I want Webで主要導線（記録/検索/参照）を使いたい,
So that ブラウザ業務中でも知識を継続活用できる。
**FR Reference:** FR47

### Story 6.2: Mobileコア導線提供
As a Primary User,
I want Mobileで主要導線（記録/検索/参照）を使いたい,
So that 学習中でも即時に知識を記録・再利用できる。
**FR Reference:** FR46
```

**Rationale:** 単一devセッション粒度への最適化

#### Change A3: Epic 6 split (6.2)
**Artifact:** `_bmad-output/planning-artifacts/epics.md`

**OLD**
```md
### Story 6.2: デスクトップ導線（右クリック含む）提供
As a Primary User,
I want デスクトップでもアプリ同等の記録・検索・参照を使いたい,
So that 業務中の知識活用を継続できる。
```

**NEW**
```md
### Story 6.3: Desktop基本導線提供
As a Primary User,
I want デスクトップで記録・検索・参照を使いたい,
So that 業務中の知識活用を継続できる。
**FR Reference:** FR48

### Story 6.4: Desktop右クリック導線統合
As a Primary User,
I want 右クリック起点で記録フローを開始したい,
So that 作業コンテキストを崩さずに知識を保存できる。
**FR Reference:** FR9, FR48
```

**Rationale:** Desktop体験の基盤導線と固有導線を分離

### B. PRD Changes

#### Change B1: Brownfield context clarification
**Artifact:** `_bmad-output/planning-artifacts/prd.md`

**OLD**
```yaml
projectType: brownfield
classification:
  projectContext: brownfield
```
（本文に具体定義が不足）

**NEW (add section)**
```md
### Brownfield Context Clarification

本プロジェクトは「既存運用ドメイン（知識管理運用ルール・既存ドキュメント資産・Supabase運用前提）」への統合を行う brownfield と定義する。
実装基盤は `create-expo-app` で新規ブートストラップするが、これは UI/クライアント実装の初期化手段であり、
プロダクト要件・運用資産・データ基盤方針は既存資産を継承する。
したがって本件は「実装基盤は新規初期化、プロダクト文脈は既存継承」の brownfield-on-new-runtime として扱う。
```

**Rationale:** brownfield/greenfield解釈揺れの解消

### C. Architecture Changes

#### Change C1: Lifecycle alignment clarification
**Artifact:** `_bmad-output/planning-artifacts/architecture.md`

**OLD**
- Starter採用は記載済みだが、brownfieldとの関係定義が散在

**NEW (add section)**
```md
### Brownfield Lifecycle Clarification

本件は brownfield プロジェクトとして扱う。
ここでの brownfield は「既存の業務文脈・要件資産・運用方針（PRD/UX/SUDO/用語辞書/Supabase運用前提）を継承する」ことを意味する。
`create-expo-app` 採用は実装ランタイム初期化のためであり、プロダクト計画を greenfield に再定義するものではない。
したがってアーキテクチャ判断は「既存文脈継承 + 新規実装基盤初期化」の前提で行う。
```

**Rationale:** PRD/Architecture/Epics のライフサイクル前提統一

## Section 5: Implementation Handoff

### Scope Classification
**Moderate**

### Why Moderate
- 複数成果物（PRD/Epics/Architecture）に跨る修正
- Epic 6 の再編によりバックログ再編が必要
- Story参照規約（FR/NFR）導入による運用手順更新が必要

### Handoff Recipients and Responsibilities
- Product Owner / Scrum Master
  - Epics再編のバックログ反映
  - Story採番とスプリント順序調整
- Product Manager / Architect
  - brownfield前提の整合文言確定
  - PRD/Architecture整合レビュー
- Development Team
  - 承認済みStory粒度で実装タスク分解
  - FR参照に基づくテストトレース設定

### Success Criteria for Handoff
1. `epics.md` に Story-level `FR Reference` / 必要時 `NFR Reference` が反映されている
2. Epic 6 の分割後ストーリー構成が確定している
3. PRD/Architecture で brownfield + starter の整合記述が明文化されている
4. スプリント運用ファイルに変更が反映されている（または反映計画が承認済み）

## Checklist Status Snapshot

- 1.1 [x] Done
- 1.2 [x] Done
- 1.3 [x] Done
- 2.1 [x] Done
- 2.2 [x] Done
- 2.3 [x] Done
- 2.4 [x] Done
- 2.5 [x] Done
- 3.1 [x] Done
- 3.2 [x] Done
- 3.3 [x] Done
- 3.4 [x] Done
- 4.1 [x] Viable
- 4.2 [x] Not viable
- 4.3 [x] Partially viable
- 4.4 [x] Done
- 5.1 [x] Done
- 5.2 [x] Done
- 5.3 [x] Done
- 5.4 [x] Done
- 5.5 [x] Done
- 6.1 [x] Done
- 6.2 [x] Done
- 6.3 [x] Done (user approval: yes)
- 6.4 [x] Done (`_bmad-output/implementation-artifacts/sprint-status.yaml` 作成済み)
- 6.5 [x] Done (handoff先・責務・次ステップ確認済み)

## Workflow Execution Log

- 2026-02-11: Change trigger 確定（FR参照不足 / Epic 6粒度 / brownfield整合）
- 2026-02-11: Incremental モードで5件の変更提案を提示
- 2026-02-11: 変更提案 5/5 をユーザー承認（Approve）
- 2026-02-11: Sprint Change Proposal を `c` で確定
- 2026-02-11: 最終承認 `yes` を取得
- 2026-02-11: Handoff scope を `Moderate` として PO/SM 主導ルートに確定
