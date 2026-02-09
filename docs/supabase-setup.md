# Supabase セットアップ手順（MVP）

## 0. 前提
- Supabase プロジェクトが作成済み
- `docs/supabase-schema.sql` が手元にある

## 1. スキーマの反映
1. Supabase ダッシュボード → `SQL Editor`
2. `New query` を作成
3. `docs/supabase-schema.sql` の中身を貼り付け
4. `RUN` を実行

## 2. RLS 有効化の確認
以下のクエリで `row_security = true` を確認する。

```sql
select table_name, row_security
from information_schema.tables
where table_schema = 'public'
  and table_name in ('knowledge_notes','tags','note_tags','note_links');
```

## 3. ポリシーの確認
```sql
select schemaname, tablename, policyname
from pg_policies
where schemaname = 'public';
```

## 4. Auth 設定（推奨: Magic Link）
1. ダッシュボード → `Authentication` → `Providers`
2. `Email` を有効化
3. `Enable Email Magic Link` を ON

## 5. 接続情報の確認
- Project Settings → API
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

これらを Expo の `.env` に設定する。

```
SUPABASE_URL=...
SUPABASE_ANON_KEY=...
```

## 6. 動作確認（任意）
認証済みユーザーで `knowledge_notes` に insert ができることを確認。

```sql
insert into public.knowledge_notes (user_id, title, raw_text, capture_status)
values ('<auth.uid()>', 'テスト', 'テスト', 'inbox');
```

※ 上記は Supabase SQL Editor では `auth.uid()` が使えないため、
SQL Editor では手動で UUID を指定する。
