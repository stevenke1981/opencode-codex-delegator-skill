# OpenCode Codex Delegator Skill v2

讓 ChatGPT Codex 透過本機 `opencode` CLI 呼叫 OpenCode 代理，並支援專案記憶搜尋與經驗寫回，避免相同錯誤或問題重複排查。

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
使用 opencode-codex-delegator skill。
先搜尋專案記憶，確認是否有相同錯誤、已驗證解法或禁止重試的失敗方案。
再列出 OpenCode 可用代理，將 todos.md 第一個未完成項目交給適合的代理實作。
限制只能修改相關檔案，不可刪除、push 或發布。
完成後由你檢查 git diff、重跑測試，並將新的根因、解法及測試證據寫回專案記憶。
```

## 最簡單的直接呼叫

```powershell
opencode run --dir "D:\project" --agent "實際代理名稱" "閱讀 AGENTS.md 並完成 todos.md 第一個未完成項目"
```

## 記憶機制

每個受管理專案可建立：

```text
.codex-memory/
├── memory.jsonl
└── lessons.md
```

- `memory.jsonl`：提供代理與腳本搜尋的結構化記憶。
- `lessons.md`：提供人類閱讀的問題、根因、解法與證據。
- 每筆記憶使用 fingerprint 去重。
- 相同 fingerprint 會更新既有記錄，不新增重複資料。
- 支援 `confirmed`、`probable`、`rejected`、`obsolete` 四種狀態。
- `rejected` 解法禁止在相同環境中無條件重試。

### Windows 搜尋記憶

```powershell
.\scripts\memory-search.ps1 `
  -ProjectDir "D:\project" `
  -Query "完整錯誤訊息或問題關鍵字"
```

### Windows 寫入記憶

```powershell
.\scripts\memory-write.ps1 `
  -ProjectDir "D:\project" `
  -Title "問題標題" `
  -Problem "問題摘要" `
  -RootCause "真正根因" `
  -Solution "已驗證解法" `
  -Evidence "測試命令與結果" `
  -Status confirmed `
  -Tags "windows,rust,build"
```

### Linux/macOS 搜尋記憶

```bash
./scripts/memory-search.sh \
  --project-dir /path/project \
  --query "完整錯誤訊息或問題關鍵字"
```

### Linux/macOS 寫入記憶

```bash
./scripts/memory-write.sh \
  --project-dir /path/project \
  --title "問題標題" \
  --problem "問題摘要" \
  --root-cause "真正根因" \
  --solution "已驗證解法" \
  --evidence "測試命令與結果" \
  --status confirmed \
  --tags "linux,rust,build"
```

## 記憶安全

不可記錄 API key、token、密碼、SSH key、私人資料或未驗證卻宣稱成功的解法。完整規則請閱讀 `SKILL.md`。

## 設計原則

- Codex：主控、權限、規格、記憶與驗收
- OpenCode：次級執行代理
- 任務前先查記憶，任務後寫回可重用經驗
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
- 專案記憶搜尋、去重、狀態管理與經驗寫回
