# 快速開始

### 步驟 1: 安裝 Plugin

在 Claude Code 中執行：

```bash
/plugin marketplace add ~/project-claude-code-plugins
```

### 步驟 2: 驗證安裝

```bash
/help
```

你應該看到 6 個新 commands。

### 步驟 3: 開始使用

**例子 1 - 分析程式碼**:

```text
/analyze-code
[貼上你的 Java 程式碼]
```

**例子 2 - 優化查詢**:

```text
/optimize-query
[貼上你的 SQL 或 JPA 程式碼]
```

**例子 3 - 啟動 Agent**:

Agents 會根據你的問題和對話內容自動啟動。你不需要明確調用它們，只需要：

- **啟動 Java Developer Agent**：

  ```text
  我需要設計一個處理高併發訂單的系統
  ```

  或

  ```text
  這段 Spring Boot 程式碼有性能問題，請幫我分析
  ```

- **啟動 Code Reviewer Agent**：

  ```text
  請審查這段程式碼的品質
  ```

  或

  ```text
  這段程式碼有什麼可以改進的地方？
  ```

- **啟動 Unit Test Reviewer Agent**：

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

## 提示

1. **提供完整上下文** - 不要只說「很慢」，提供具體資料
2. **連續對話** - 可以在前一個分析基礎上繼續提問
3. **比較方案** - 要求 Agent 比較不同的實作方式
4. **具體細節** - 要求具體程式碼而不是理論

---

準備好了嗎？試試 `/analyze-code` 來分析任何 Java 程式碼！

