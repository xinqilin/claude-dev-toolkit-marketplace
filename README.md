# Bill Lin Dev Toolkit

## 快速概覽

### 3 個專特化的 Agents
- **bill-java-developer**: 資深 Java 架構師 (15+ 年經驗)
- **bill-code-reviewer**: 高級程式碼審查員 
- **bill-billing-unit-test-reviewer**: 單元測試審查專家

### 實用 Commands
- `/analyze-code` - 全面程式碼分析
- `/optimize-query` - SQL/JPA 優化
- `/review-architecture` - 架構設計審查
- `/refactor-suggestion` - 重構建議
- `/mysql-performance` - MySQL 性能優化

## 安裝

### 方法 1: 從 GitHub 安裝（推薦）

#### Private Repository 安裝方式

本 plugin 位於 private GitHub repository。你需要使用以下其中一種方式進行安裝：

#### 選項 A: 使用 GitHub Personal Access Token

1. 建立 GitHub Personal Access Token:
   - 前往 [GitHub Settings](https://github.com/settings/tokens) → Developer settings → Personal access tokens → Tokens (classic)
   - 點擊 "Generate new token (classic)"
   - 勾選 `repo` 權限（完整的 repository 存取權限）
   - 產生 token 並複製

2. 使用 token 安裝 plugin:

```bash
claude code plugin add xinqilin/claude-dev-toolkit-marketplace --token YOUR_GITHUB_TOKEN
```

#### 選項 B: 使用 SSH（如你已設定 GitHub SSH Key）

如果你的電腦已經設定好 GitHub SSH key，可以直接安裝：

```bash
claude code plugin add xinqilin/claude-dev-toolkit-marketplace
```

Claude Code 會自動使用你的 SSH 認證。

### 方法 2: 本地開發安裝

如果你想從本地目錄安裝（適用於開發或測試）：

```bash
claude code plugin add /path/to/project-claude-code-plugins
```

### 驗證安裝

安裝完成後，執行以下指令確認：

```bash
claude code plugin list
```

你應該看到 `bill-lin-dev-toolkit` 出現在列表中。

檢查可用的 commands：

```bash
claude code help
```

你應該看到 5 個新的 commands。

## 快速開始

### 使用 Commands

**分析程式碼**:

```text
/analyze-code
[貼上你的 Java 程式碼]
```

**優化查詢**:

```text
/optimize-query
[貼上你的 SQL 或 JPA 程式碼]
```

**架構審查**:

```text
/review-architecture
[描述你的系統設計]
```

**重構建議**:

```text
/refactor-suggestion
[貼上需要重構的程式碼]
```

**MySQL 性能優化**:

```text
/mysql-performance
[貼上你的 SQL 查詢或 EXPLAIN 結果]
```

### 啟動 Agents

Agents 會根據你的問題和對話內容自動啟動。你不需要明確調用它們，只需要：

**啟動 Java Developer Agent**：

```text
我需要設計一個處理高併發訂單的系統
```

或

```text
這段 Spring Boot 程式碼有性能問題，請幫我分析
```

**啟動 Code Reviewer Agent**：

```text
請審查這段程式碼的品質
```

或

```text
這段程式碼有什麼可以改進的地方？
```

**啟動 Unit Test Reviewer Agent**：

```text
請審查我的單元測試設計
```

或

```text
這個測試案例是否有過度設計的問題？
```

Agent 會自動識別你的需求並提供專業建議。你也可以在對話中直接提到 "Java Developer"、"Code Reviewer" 或 "Unit Test Reviewer" 來明確指定。

## 常用工作流

### 性能優化

1. `/mysql-performance` - 分析查詢
2. 與 Java Developer Agent 討論 - 理解實作
3. 與 Code Reviewer Agent 討論 - 檢查程式碼品質

### 架構設計

1. `/review-architecture` - 評估設計
2. 與 Java Developer Agent 討論 - 詳細實作建議
3. 與 Code Reviewer Agent 討論 - 品質檢查

### 程式碼重構

1. `/analyze-code` - 全面分析
2. `/refactor-suggestion` - 獲取建議
3. 與 Code Reviewer Agent 討論 - 最終審查

### 測試設計

1. 撰寫初步測試程式碼
2. 與 Unit Test Reviewer Agent 討論 - 測試設計審查
3. 根據建議改進測試案例

## 核心 Agents

### Java Developer Expert

- 15+ 年生產環境經驗
- Spring Boot、JPA、MySQL 優化專家
- 系統設計、PCI DSS 合規
- 提供完整的生產級程式碼方案

### Code Reviewer Expert

- Clean Code 原則專家
- Refactoring 和 Design Pattern 精通
- 性能分析和演算法優化
- 務實平衡的程式碼品質評估

### Unit Test Reviewer Expert

- TDD 測試驅動開發專家
- 測試設計原則和最佳實踐
- 測試責任分離與覆蓋率分析
- 避免過度設計與虛構場景

## 目錄結構

```plaintext
project-claude-code-plugins/
├── .claude-plugin/
│   └── plugin.json
├── agents/
│   ├── bill-java-developer.md
│   ├── bill-code-reviewer.md
│   └── bill-billing-unit-test-reviewer.md
├── commands/
│   ├── analyze-code.md
│   ├── optimize-query.md
│   ├── review-architecture.md
│   ├── refactor-suggestion.md
│   └── mysql-performance.md
├── LICENSE
└── README.md
```

## 最佳實踐

### 提供完整上下文

清楚說明你的問題、環境和約束條件：

```text
好: 我的查詢花 3 秒，表有 500 萬筆，EXPLAIN 結果是...
不好: 為什麼這很慢？
```

### 清楚地說明約束條件

幫助 Agent 理解你的具體需求：

```text
好: 表有 500 萬筆記錄，QPS 預期 1000/秒，優先查詢速度
不好: 你能幫我優化嗎？
```

### 連續對話

可以在前一個分析基礎上繼續提問，建立更深入的討論。

### 比較方案

要求 Agent 比較不同的實作方式，了解各種方案的權衡。

### 具體細節

要求具體程式碼而不是理論，直接獲得可執行的解決方案。

## GitHub Repository

[https://github.com/xinqilin/claude-dev-toolkit-marketplace](https://github.com/xinqilin/claude-dev-toolkit-marketplace)

## 授權

MIT License - 詳見 [LICENSE](LICENSE) 檔案
