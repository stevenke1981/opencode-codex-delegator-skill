# OpenCode 委派規則

Codex 可使用 `opencode-delegator` Skill，透過 OpenCode CLI 將子任務委派給 OpenCode 代理。

## 強制規則

1. Codex 始終是主控與最終驗收者。
2. 委派前必須設定明確的 `--dir`。
3. 必須先執行 `opencode agent list`，不得猜測代理名稱。
4. 不得授權 OpenCode 執行刪除、force push、發布或部署，除非使用者明確批准。
5. OpenCode 回報測試通過後，Codex 必須自行檢查 diff 並重跑必要測試。
6. 不同專案不可混用 session。
7. OpenCode 未安裝、未驗證或執行失敗時，不得假造完成結果。
