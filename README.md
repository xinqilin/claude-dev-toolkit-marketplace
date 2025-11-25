# Bill Lin Dev Toolkit

企業級 Java/Spring Boot 開發工具包，提供 3 個獨立的專業 plugins，可按需安裝。

## 快速概覽

### 3 個獨立 Plugins

#### 1. bill-billing-unit-test-reviewer
專注於單元測試審查與最佳實踐
- **Agent**: bill-billing-unit-test-reviewer
- **專長**: TDD、測試設計、覆蓋率分析、避免過度設計

#### 2. bill-code-reviewer
程式碼品質審查與重構建議
- **Agent**: bill-code-reviewer
- **Commands**:
  - `/analyze-code` - 全面程式碼分析
  - `/refactor-suggestion` - 重構建議
  - `/review-architecture` - 架構設計審查
- **專長**: Clean Code、Design Patterns、重構技巧

#### 3. bill-java-developer
Spring Boot 開發與資料庫優化專家
- **Agent**: bill-java-developer
- **Commands**:
  - `/optimize-query` - SQL/JPA 優化
  - `/mysql-performance` - MySQL 性能優化
- **專長**: Spring Boot、JPA、資料庫效能、企業架構

## 安裝

你可以選擇安裝全部 3 個 plugins，或只安裝你需要的。

### 步驟 1: 加入 Marketplace

**從 GitHub 安裝（推薦）**：
```
/plugin marketplace add xinqilin/claude-dev-toolkit-marketplace
```

**從本地安裝**：
```
/plugin marketplace add /path/to/project-claude-code-plugins
```

### 步驟 2: 安裝 Plugins

選擇你需要的 plugins 進行安裝：

**安裝全部 3 個 plugins**：
```
/plugin install bill-billing-unit-test-reviewer
/plugin install bill-code-reviewer
/plugin install bill-java-developer
```

**或只安裝你需要的**：
```
# 只安裝測試審查
/plugin install bill-billing-unit-test-reviewer

# 只安裝程式碼審查
/plugin install bill-code-reviewer

# 只安裝 Spring Boot 開發工具
/plugin install bill-java-developer
```

### 驗證安裝

安裝完成後，你可以透過以下指令確認：
```
# 查看已安裝的 plugins
/plugin list

# 查看可用的 commands
/help
```

## 快速開始

### 使用 Commands

#### Java Code Reviewer Plugin

**分析程式碼**:
```text
/analyze-code
[貼上你的 Java 程式碼]
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

#### Java Spring Developer Plugin

**優化查詢**:
```text
/optimize-query
[貼上你的 SQL 或 JPA 程式碼]
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

## Plugins 詳細說明

### 1. bill-billing-unit-test-reviewer

**獨立安裝**: 如果你只需要測試審查功能

專注於單元測試品質與最佳實踐：
- TDD 測試驅動開發專家
- 測試設計原則和最佳實踐
- 測試責任分離與覆蓋率分析
- 避免過度設計與虛構場景
- 基於真實系統行為的測試策略

**適用場景**: 測試程式碼審查、TDD 實踐、測試重構

### 2. bill-code-reviewer

**獨立安裝**: 如果你主要需要程式碼品質審查

程式碼品質、架構設計與重構專家：
- Clean Code 原則專家
- Refactoring 和 Design Pattern 精通
- 性能分析和演算法優化
- 務實平衡的程式碼品質評估
- 架構設計與系統可維護性

**適用場景**: Code Review、重構建議、架構評估

### 3. bill-java-developer

**獨立安裝**: 如果你主要需要開發與效能優化

Spring Boot 開發與資料庫優化專家：
- 15+ 年生產環境經驗
- Spring Boot、JPA、Hibernate 精通
- MySQL 查詢優化與索引策略
- 系統設計、分散式系統
- 提供完整的生產級程式碼方案

**適用場景**: Spring Boot 開發、資料庫效能優化、系統設計

## 目錄結構

```plaintext
project-claude-code-plugins/
├── .claude-plugin/
│   └── marketplace.json              # Marketplace 定義
└── plugins/
    ├── bill-billing-unit-test-reviewer/      # Plugin 1: 單元測試審查
    │   ├── .claude-plugin/
    │   │   └── plugin.json
    │   └── agents/
    │       └── bill-billing-unit-test-reviewer.md
    │
    ├── bill-code-reviewer/           # Plugin 2: 程式碼審查
    │   ├── .claude-plugin/
    │   │   └── plugin.json
    │   ├── agents/
    │   │   └── bill-code-reviewer.md
    │   └── commands/
    │       ├── analyze-code.md
    │       ├── refactor-suggestion.md
    │       └── review-architecture.md
    │
    └── bill-java-developer/        # Plugin 3: Spring Boot 開發
        ├── .claude-plugin/
        │   └── plugin.json
        ├── agents/
        │   └── bill-java-developer.md
        └── commands/
            ├── mysql-performance.md
            └── optimize-query.md
```

## 為什麼選擇這個 Marketplace？

### 模組化設計
3 個獨立 plugins，按需安裝：
- **只需要測試審查？** 安裝 bill-billing-unit-test-reviewer
- **只需要程式碼審查？** 安裝 bill-code-reviewer
- **只需要開發優化？** 安裝 bill-java-developer
- **需要全套工具？** 一次安裝全部

### 專業深度
每個 plugin 都由資深專家設計：
- 15+ 年企業級開發經驗
- 真實生產環境最佳實踐
- 務實、可執行的建議

### 持續更新
- 定期更新最新的開發實踐
- 根據社群回饋改進
- 支援最新的 Java/Spring Boot 版本

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
