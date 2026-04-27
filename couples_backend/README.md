# Couples Backend

Minimal shared backend for the Flutter couples app.

如果当前机器是整仓 `D:\couple`，后端位于 `couples_backend/` 子目录，请不要直接在整仓根目录执行后端仓库推送，相关说明见 [MONOREPO_GIT_PUSH.md](./MONOREPO_GIT_PUSH.md)。

## Endpoints

- `POST /bootstrap-user`
- `POST /bind-couple-by-pair-code`
- `POST /chat/list`
- `POST /chat/send`
- `POST /thoughts/ideas/list`
- `POST /thoughts/ideas/upsert`
- `POST /thoughts/ideas/delete`
- `POST /thoughts/excerpts/list`
- `POST /thoughts/excerpts/upsert`
- `POST /thoughts/excerpts/delete`
- `POST /thoughts/comments/list`
- `POST /thoughts/comments/upsert`
- `POST /thoughts/comments/delete`

## Quick start

```bash
copy .env.example .env
npm.cmd install
npm.cmd run init-db
npm.cmd run dev
```

## PostgreSQL

当 `.env` 里配置了 `DATABASE_URL` 后，服务会自动切到 PostgreSQL 模式，并在启动时初始化表结构。

如果你已经有本地 SQLite 数据，可以执行：

```bash
npm.cmd run migrate-sqlite-to-pg
```

## Railway

- 建议将 Railway 服务的 Root Directory 指向 `couples_backend`
- 启动命令使用 `npm run start`
- 至少配置这些环境变量：
  - `PORT`
  - `DATABASE_URL`
  - `PUBLIC_BASE_URL`
