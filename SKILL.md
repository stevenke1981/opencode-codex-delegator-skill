---
name: opencode-codex-delegator
description: 讓 ChatGPT Codex 透過 OpenCode CLI 委派代理工作，並在每次任務前搜尋專案記憶、完成後記錄可重用經驗，避免相同錯誤與問題重複排查。
---

# OpenCode Codex Delegator

## 核心角色

Codex 是主控代理，OpenCode 是透過 CLI 呼叫的執行代理。Codex 負責規格、權限、記憶、驗收與最終回報。

## 強制工作流程

每次委派前後都必須執行以下流程：

```text
問題輸入
  ↓
搜尋專案記憶
  ↓
套用已知解法與禁止重試項目
  ↓
OpenCode Planner / Builder / Tester / Reviewer
  ↓
Codex 驗收
  ↓
寫入或更新記憶
```

## Gate 0：搜尋記憶

在分析、搜尋程式碼或執行 OpenCode 前，先搜尋：

1. `.codex-memory/memory.jsonl`
2. `.codex-memory/lessons.md`
3. `lessons.md`
4. `final.md`
5. `test.md`
6. Git commit、issue 或既有錯誤紀錄

Windows：

```powershell
.\scripts\memory-search.ps1 -ProjectDir "D:\project" -Query "錯誤訊息或問題關鍵字"
```

Linux/macOS：

```bash
./scripts/memory-search.sh --project-dir /path/project --query "錯誤訊息或問題關鍵字"
```

搜尋結果必須加入 OpenCode 提示詞：

```text
既有記憶：
- 已知根因：...
- 已驗證解法：...
- 不可重試：...
- 適用版本：...
```

若已有高可信度且環境相符的解法，優先驗證並套用，不得重新從零排查。

## 記憶可信度

每筆記憶必須標記：

- `confirmed`：由測試或實際執行驗證
- `probable`：有強證據但尚未完整驗證
- `rejected`：已證實無效，禁止重試
- `obsolete`：版本或環境已不適用

只有 `confirmed` 可直接作為預設解法。`probable` 必須重新驗證。

## 相似問題判定

判定是否為相同或相似問題時，比對：

- 完整錯誤訊息與錯誤碼
- 主要關鍵字
- 作業系統與架構
- 語言、框架、套件版本
- 觸發命令
- 受影響檔案或模組
- 症狀與重現步驟

不得只因文字相似就套用記憶；環境或版本不符時，要標記為參考而非直接答案。

## OpenCode 委派提示詞

```text
角色：你是此任務的執行代理。

目標：<明確結果>
工作目錄：<絕對路徑>
允許修改：<檔案範圍>

既有記憶：
<由 memory-search 取得的相關紀錄>

規則：
- 優先驗證 confirmed 解法
- 不得重試 rejected 解法
- 若記憶已過期，說明版本差異
- 不得修改範圍外檔案
- 不得刪除、push、發布或部署
- 必須回報命令、結果與證據
```

## 完成後寫入記憶

符合以下任一情況時必須記錄：

- 找到真正根因
- 解法經測試通過
- 某解法已證實無效
- 發現版本、環境或平台差異
- 同類問題可能再次發生
- 使用者修正了代理的錯誤判斷

Windows：

```powershell
.\scripts\memory-write.ps1 `
  -ProjectDir "D:\project" `
  -Title "CMake 找不到 CUDA" `
  -Problem "完整問題摘要" `
  -RootCause "根因" `
  -Solution "已驗證解法" `
  -Evidence "測試命令與結果" `
  -Status confirmed `
  -Tags "cmake,cuda,windows"
```

Linux/macOS：

```bash
./scripts/memory-write.sh \
  --project-dir /path/project \
  --title "CMake 找不到 CUDA" \
  --problem "完整問題摘要" \
  --root-cause "根因" \
  --solution "已驗證解法" \
  --evidence "測試命令與結果" \
  --status confirmed \
  --tags "cmake,cuda,windows"
```

## 去重與更新規則

寫入前必須先搜尋相似記憶：

- 相同 fingerprint：更新既有紀錄，不新增重複項目。
- 相同問題但新版本有不同解法：新增版本限定紀錄，舊紀錄標記 `obsolete`。
- 解法失敗：將原紀錄更新為 `rejected` 或降低可信度。
- 同一根因有多種症狀：保留一筆根因記憶並增加 aliases。

## 禁止寫入

不得把以下內容寫入記憶：

- API key、token、密碼、SSH key
- 個人資料或未經允許的私人內容
- 未驗證卻聲稱成功的解法
- 大量原始日誌；只保留必要摘要與證據
- 受版權或授權限制的完整內容

## 記憶位置

專案內預設使用：

```text
.codex-memory/
├── memory.jsonl
├── lessons.md
└── README.md
```

`memory.jsonl` 提供機器搜尋；`lessons.md` 提供人類閱讀。

## 最終驗收

Codex 只有在以下條件成立時才能標記完成：

- 已先搜尋記憶
- 已避免重試 rejected 解法
- OpenCode 變更在允許範圍內
- 關鍵測試由 Codex 重跑
- 新經驗已寫入或更新記憶
- 記憶不含機密資訊
