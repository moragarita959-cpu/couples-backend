# Couples Backend

Minimal shared backend for the Flutter couples app.

若本机是**整仓** `d:\couple`（后端在 `couples_backend/` 子目录），向 GitHub `couples-backend` 推送 **不要** 在整仓根直接 `git push backend main`，请读 **[MONOREPO_GIT_PUSH.md](./MONOREPO_GIT_PUSH.md)**。

## Endpoints

- `POST /bootstrap-user`
- `POST /bind-couple-by-pair-code`
- `POST /chat/list`
- `POST /chat/send`

## Quick start

```bash
copy .env.example .env
npm.cmd install
npm.cmd run init-db
npm.cmd run dev
```
