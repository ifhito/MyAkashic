# Docker 開発環境（Nodeをローカルに使わない）

## 目的
- ローカルの Node を使わず、Docker 内の Node で開発する
- Expo の開発サーバーもコンテナ内で動かす

## 前提
- Docker / Docker Compose が利用可能
- プロジェクトは `myakashic-app` 配下

## 起動（最短）

```bash
docker compose up
```

初回は `npm install` が走り、そのまま `expo start` が起動します。

## 停止

```bash
docker compose down
```

## 任意コマンド（Nodeを使う作業）

```bash
# 例: 依存追加
docker compose run --rm expo npm install @supabase/supabase-js

# 例: テストやlint
docker compose run --rm expo npm run lint
```

## トラブルシュート
- ポート競合がある場合は `docker-compose.yml` の `ports` を変更
- パッケージ追加後に反映されない場合は `expo_node_modules` ボリュームを削除

```bash
docker volume rm myakashic_expo_node_modules
```

## メモ
- 開発サーバーは `--host 0.0.0.0` で起動
- 端末やエミュレータからアクセスする場合は、ホストのIPに接続
