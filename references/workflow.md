# Codex → OpenCode 協作架構

```text
使用者
  ↓
ChatGPT Codex（主控、規格、權限、驗收）
  ↓ terminal
OpenCode CLI
  ↓ --agent / --model / --dir
OpenCode 代理（分析、實作、測試或審查）
  ↓
本機專案檔案與測試
  ↓
Codex 檢查 git diff + 重跑測試
  ↓
使用者
```

## 責任邊界

Codex 負責：

- 需求釐清與規格化
- 工作目錄及修改邊界
- 權限控制
- 選擇是否委派
- 檢查實際 diff
- 獨立執行驗收
- 最終報告

OpenCode 負責：

- 在指定範圍內執行任務
- 使用指定代理、模型、MCP、LSP 或工具
- 修改檔案
- 執行局部測試
- 產生結構化回報

## 推薦兩階段流程

1. Planner 只分析，不改檔。
2. Codex 審核計畫並產生精確實作提示。
3. Builder 實作。
4. Codex 執行 diff 與測試。
5. Reviewer 只審查 diff。
6. Codex 修正或再委派。
