# OpenCode CLI 委派速查

依據 OpenCode CLI 繁體中文官方文件整理。

## 代理

```bash
opencode agent list
opencode agent create
```

## 非互動式執行

```bash
opencode run [message...]
```

常用旗標：

| 旗標 | 用途 |
|---|---|
| `--agent` | 指定代理 |
| `--model`, `-m` | 指定 `provider/model` |
| `--dir` | 指定工作目錄 |
| `--file`, `-f` | 附加檔案 |
| `--format json` | 輸出原始 JSON 事件 |
| `--continue`, `-c` | 延續上一工作階段 |
| `--session`, `-s` | 指定工作階段 ID |
| `--fork` | 從工作階段分岔 |
| `--attach` | 連接既有 OpenCode server |
| `--variant` | 指定模型推理變體 |
| `--thinking` | 顯示思考區塊 |
| `--title` | 設定工作階段標題 |

## 伺服器

```bash
opencode serve --port 4096 --hostname 127.0.0.1
opencode run --attach http://127.0.0.1:4096 "任務"
```

## 工作階段

```bash
opencode session list
opencode session list --format json
opencode export <sessionID>
opencode import <file>
```

## 模型與驗證

```bash
opencode auth list
opencode auth login
opencode models
opencode models --refresh
opencode models <provider>
```

## 偵錯

```bash
opencode --print-logs --log-level DEBUG run "任務"
```

## 重要環境變數

- `OPENCODE_CONFIG`
- `OPENCODE_CONFIG_DIR`
- `OPENCODE_CONFIG_CONTENT`
- `OPENCODE_PERMISSION`
- `OPENCODE_GIT_BASH_PATH`
- `OPENCODE_SERVER_PASSWORD`
- `OPENCODE_SERVER_USERNAME`
- `OPENCODE_DISABLE_AUTOCOMPACT`
- `OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS`

實驗功能可能變更，不應當作穩定依賴。
