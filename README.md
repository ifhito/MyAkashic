# MyAkashic

知識を「雑に入力 → 後で整形」できる、個人向けの知識整理アプリ（MVP）です。  
Quick Captureでメモを集め、外部LLM（ChatGPT/Claude/Geminiなど）で整形し、インボックスで整理します。

## 目的
- 会社・本・体験などから得た学びを構造化
- 関連知識の探索と週次振り返りを気軽に
- 将来の公開を見据えた拡張性

## MVPの特徴
- **Quick Capture**: 1つの大きなテキスト欄で雑に入力
- **Inbox**: 未整理ノートを集約
- **外部LLM整形**: プロンプトを生成し、外部サービスで整形 → 結果を貼り付け
- **週次振り返り**: 直近7日 + 関連ノートを再提示

## アーキテクチャ
- **Clean Architecture + DDD**
- データ基盤: **Supabase (Postgres + Auth + RLS)**

## ドキュメント
- 仕様書: `docs/knowledge-app-spec.md`
- UIフロー: `docs/knowledge-app-ui-flow.md`
- 実装設計: `docs/knowledge-app-implementation-plan.md`
- SUDOモデリング: `docs/knowledge-app-sudo-modeling.md`
- Supabaseスキーマ: `docs/supabase-schema.sql`
- Supabaseセットアップ: `docs/supabase-setup.md`

## セットアップ（Supabase）
1. `docs/supabase-setup.md` に従ってスキーマを反映
2. `SUPABASE_URL` / `SUPABASE_ANON_KEY` を取得

## 開発ステータス
- 設計・仕様確定済み
- 実装開始前

## 今後の拡張
- 公開ビュー
- 知識グラフ表示
- 画像/ファイル添付
- エクスポート（Markdown/JSON）

---

必要なら、Expoプロジェクトの初期化や実装をすぐに進めます。
