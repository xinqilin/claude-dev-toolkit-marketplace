# Bill Lin Dev Toolkit

**Enterprise Java/Spring Boot Development Plugin for Claude Code**

一個為資深 Java 開發者設計的專業開發工具集。結合了架構思考、程式碼審查專業知識，和實戰的最佳實踐。

## 快速概覽

### 3 個專特化的 Agents
- **bill-java-developer**: 資深 Java 架構師 (15+ 年經驗)
- **bill-code-reviewer**: 高級程式碼審查員 (Clean Code 專家)
- **bill-billing-unit-test-reviewer**: 單元測試審查專家 (TDD 最佳實踐)

### 實用 Commands
- `/analyze-code` - 全面程式碼分析
- `/optimize-query` - SQL/JPA 優化
- `/review-architecture` - 架構設計審查
- `/refactor-suggestion` - 重構建議
- `/mysql-performance` - MySQL 性能優化

## GitHub Repository

https://github.com/xinqilin/claude-dev-toolkit-marketplace

## 安裝

在 Claude Code 中執行：

```bash
/plugin marketplace add /Users/bill/project-claude-code-plugins
```

驗證安裝：

```bash
/plugin list
/help
```

## 使用示例

### 分析程式碼

```text
/analyze-code
[貼上你的 Java 程式碼]
```

### 優化查詢

```text
/optimize-query
[貼上你的 SQL 或 JPA 程式碼]
```

### 架構審查

```text
/review-architecture
[描述你的系統設計]
```

### 啟動 Agents

在對話中提到：

```text
我想向一位資深 Java 開發者諮詢...
```

或

```text
我需要一位程式碼審查員檢查...
```

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
└── README.md
```

## 最佳實踐

### 提供完整上下文

```text
好: 我的查詢花 3 秒，表有 500 萬筆，EXPLAIN 結果是...
不好: 為什麼這很慢？
```

### 清楚地說明約束條件

```text
好: 表有 500 萬筆記錄，QPS 預期 1000/秒，優先查詢速度
不好: 你能幫我優化嗎？
```
