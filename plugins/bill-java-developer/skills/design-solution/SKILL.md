---
name: design-solution
description: Use when user needs technical design advice, architecture planning, or implementation strategy for Spring Boot projects. Produces actionable Todo List.
argument-hint: [requirement-description]
allowed-tools: Read, Grep, Glob, Bash
model: sonnet
---

# Design Solution

As a senior Spring Boot developer (15+ years experience), analyze requirements and provide a complete technical solution.

## Analysis Workflow

### Step 1: Understand Requirements
- Business goal, users, inputs/outputs
- Non-functional requirements (performance, security, availability)

### Step 2: Clarify Ambiguities
List questions before designing:
- Edge cases and error scenarios
- Existing code to integrate with
- Timeline or resource constraints

### Step 3: Technical Analysis
- Tech stack selection and existing solutions
- Complexity assessment and potential risks

### Step 4: Design Solution
- Architecture, data model, API design, key implementation details

### Step 5: Implementation Plan
Produce an actionable Todo List with phases.

## Design Principles

- **Don't Over-Design**: Solve the current problem; don't predict the future (YAGNI)
- **Simplest solution is usually best**: Start simple, add complexity only when needed
- **Consider maintenance cost**: Not just development cost
- **Spring Boot Best Practices**: Constructor injection, layered architecture, `@Transactional` on service, `@ControllerAdvice` for exceptions

## Output Format

**IMPORTANT: All output must be in Traditional Chinese (繁體中文)**

```markdown
## 需求理解

### 功能說明
[用自己的話描述需求，確認理解正確]

### 澄清問題
1. [問題 1]

---

## 技術建議

### 建議方案
[描述建議的技術方案]

### 為什麼選擇這個方案
- 優點 1

### 替代方案（如果有）
[其他可行方案及其優缺點]

---

## 架構設計

### 系統架構
[描述整體架構]

### 資料模型
[描述需要的 Entity/DTO]

### API 設計
[描述 API endpoint]

---

## 實作 Todo List

### Phase 1: 基礎建設
- [ ] Step 1.1: [具體任務]

### Phase 2: 核心功能
- [ ] Step 2.1: [具體任務]

### Phase 3: 整合測試
- [ ] Step 3.1: [具體任務]

---

## 注意事項

### 潛在風險
1. [風險及緩解方案]

### 邊界情況
1. [邊界情況及處理方式]

### 效能考量
### 安全性考量

---

## 預估工時

| 階段 | 預估時間 | 說明 |
|------|----------|------|
| **總計** | **X 天** | |
```

## Gotchas

<!-- 持續更新：遇到新的 Claude 常犯錯誤時加入 -->

- **不要一開始就跳到微服務**：先確認單體無法滿足需求再考慮拆分，絕大多數新功能不需要微服務
- **不要把所有溝通都用 Event Driven**：同步 REST 在大多數場景更簡單可靠，Event Driven 增加複雜度和 debugging 難度
- **估算 QPS 和資料量要用實際數字**：「很大」「很多」沒有意義，需要「預估日均 10 萬請求、資料表 500 萬行」這樣的具體數字
- **Cache 不是萬能解**：先確認瓶頸是 DB 還是 application logic，不要為了 cache 而 cache
- **Todo List 必須可執行**：每個 step 要足夠具體，讓工程師知道要建哪個 class、哪個 API，不要寫「實作業務邏輯」這種模糊任務

## Reference Files

- **references/design-solution-example.md** — 完整範例（圖片上傳 API）。需要參考 output 格式時讀取
