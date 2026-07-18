# OpenCode Codex Delegator Skill v2

讓 ChatGPT Codex 透過本機 `opencode` CLI 呼叫 OpenCode 代理。

## 安裝

將整個 `opencode-codex-delegator-skill` 資料夾加入 Codex 的 Skills 管理介面，或複製到你的 Codex Skills 目錄；實際位置依目前 Codex 版本與設定為準。

也可把 `templates/AGENTS-snippet.md` 合併進專案的 `AGENTS.md`。

## 第一次使用

Windows：

```powershell
.\scripts\preflight.ps1
```

Linux/macOS：

```bash
chmod +x scripts/*.sh
./scripts/preflight.sh
```

## 對 Codex 的自然語言指令

```text
使用 opencode-delegator skill。
先列出 OpenCode 可用代理，再將目前 todos.md 第一個未完成項目交給適合的 OpenCode 代理實作。
限制它只能修改相關檔案，不可刪除、push 或發布。
完成後由你檢查 git diff，重跑測試，再回報結果。
```

## 最簡單的直接呼叫

```powershell
opencode run --dir "D:\project" --agent "實際代理名稱" "閱讀 AGENTS.md 並完成 todos.md 第一個未完成項目"
```

## 設計原則

- Codex：主控、權限、規格、驗收
- OpenCode：次級執行代理
- Git diff 與測試結果才是完成證據
- 所有代理名稱與模型名稱均由 CLI 即時查詢，不硬編碼

## v2 重點

- Codex 接收使用者指出的問題後，直接指派 OpenCode 修復
- 支援新建專案與既有專案
- Planner、Builder、Tester、Reviewer 多代理管線
- Session 專案隔離與 Fork
- 最多三次修復迴圈
- Git diff、測試與獨立審查驗收 Gates
- Windows 與 Linux 驗證 Hooks
