# MyAkashic Agent Guide

## Architecture rules
1. Follow `Clean Architecture + DDD` for all new code.
2. Follow `TDD` by default: write or update a failing test first, implement minimally to pass, then refactor safely.
3. Keep dependency direction one-way: `presentation -> application -> domain`. Infrastructure may depend on domain/application abstractions, but domain must not depend on infrastructure.
4. Put UI concerns only in `presentation` (screens, navigation, hooks, UI state). Do not place Supabase or parsing logic in UI components.
5. Put use-case orchestration in `application` (prompt generation, structured-text parsing, review generation, DTO mapping).
6. Put business rules and invariants in `domain` (entities, value objects, repository interfaces, domain services).
7. Put external integrations in `infrastructure` (Supabase client/repositories, storage adapters). Always implement repository interfaces here.
8. Preserve MVP flow boundaries: `Quick Capture -> Inbox -> External LLM -> Paste structured result -> Structured note`.
9. Keep feature-first organization inside each layer when the codebase grows, but do not break layer boundaries.
10. Prefer additive changes over cross-layer shortcuts. If a shortcut is needed, document why in PR/commit notes.
11. Use Docker-based Node workflows for project commands (`docker compose ...`), not host-node assumptions.

## Known mistakes
1. Mistake: Calling Supabase directly from screen components.  
   Next-time fix: Move access behind application use cases + infrastructure repositories.
2. Mistake: Accepting malformed structured text silently (especially missing `Body:`).  
   Next-time fix: Hard-fail parsing with explicit error, keep `raw_text`, and provide retry/edit path.
3. Mistake: Forgetting ownership constraints (`user_id`) in data writes/reads.  
   Next-time fix: Enforce `user_id = auth.uid()` at policy/query level and test with non-owner data.
4. Mistake: Accidentally treating MVP visibility as public.  
   Next-time fix: Keep default `visibility = private` and require explicit product decision before public exposure.
5. Mistake: Running broad list queries without intended filters.  
   Next-time fix: Use indexed filters (`user_id`, `capture_status`, `created_at`, `learned_period`) and limit result size.
6. Mistake: Adding in-app direct LLM API calls during prototyping.  
   Next-time fix: Keep MVP design: generate prompt in-app, open external provider, user pastes result back.
7. Mistake: Mixing generated planning artifacts with runtime app logic.  
   Next-time fix: Keep `_bmad*` outputs as reference docs only; production logic belongs under `myakashic-app`.

## Constraints
### Security constraints
1. Enable and keep RLS on all core tables (`knowledge_notes`, `tags`, `note_tags`, `note_links`).
2. All policies must enforce ownership with `user_id = auth.uid()` for select/insert/update/delete.
3. Never commit secrets (`SUPABASE_URL`, keys, tokens). Use environment variables only.
4. Use `SUPABASE_ANON_KEY` in client code only; never expose service-role credentials in app runtime.
5. Treat external LLM outputs as untrusted input; validate and sanitize parsed fields before persistence.

### Performance constraints
1. Query by indexed columns first; avoid full scans for inbox/review paths.
2. Weekly review must stay bounded (last 7 days + capped related-note count).
3. Avoid N+1 fetch patterns for tags/links; batch or join where possible.
4. Keep capture/save interactions fast and resilient; preserve user input on any failure.

### Cost constraints
1. Do not call paid LLM APIs from the app in MVP; external provider usage is user-driven.
2. Minimize unnecessary database round-trips (reuse fetched data, batch writes when safe).
3. Avoid introducing infrastructure that adds recurring cost before MVP validation.
