# 整仓推送到 GitHub `couples-backend`（必看）

本机仓库 **`d:\couple` 是整仓**（含 `couples_flutter/`、`couples_backend/` 等），而 GitHub 上的

**`https://github.com/moragarita959-cpu/couples-backend`**

是 **只在仓库根放后端** 的仓库（`package.json`、`src/` 在根目录）。因此：

- **不要** 在 `d:\couple` 里对 `remote` 名叫 `backend` 的地址执行 `git push backend main`（会与远程历史/目录结构对不上，出现 `non-fast-forward` 等问题）。
- **要** 只把子目录 `couples_backend/` 的**内容**以「在远程仓库根」的形式推上去，用 **git subtree**。

## 以后每次改完后端、要更新 Railway 时

在 **`d:\couple`（整仓根）** 打开终端：

### 方式 A：一条命令（优先试）

```powershell
cd d:\couple
git subtree push --prefix=couples_backend backend main
```

若报错 **non-fast-forward** 或推不上去，用方式 B。

### 方式 B：split 再推（与首次成功时相同）

```powershell
cd d:\couple
git subtree split --prefix=couples_backend -b split-backend
git push backend split-backend:main --force
```

`--force` 会用当前子目录树**覆盖** GitHub 上 `main` 的后端内容；`couples-backend` 是专用后端小仓库时这样是预期行为。

## 本机 `main` 与分支说明

- 日常开发仍在整仓的 **`main`** 上提交即可。
- `split-backend` 是 split 用的本地分支，**不要** 和整仓 `main` 做无意义的合并；需要时再重新 `split` 即可。

## Railway

推送成功后，若已连接 GitHub，一般会**自动部署**；也可在 Railway 控制台对服务点 **Redeploy**。

确认 **Root Directory** 为仓库根（与 `package.json` 同层），**Start** 为 `npm start`（或 `node src/server.js`）。

## 首次配置远程（仅说明，一般已配好）

```powershell
git remote add backend https://github.com/moragarita959-cpu/couples-backend.git
```

查看：`git remote -v`。
