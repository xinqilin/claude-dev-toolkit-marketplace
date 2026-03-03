# Bill Lin Dev Toolkit

繁體中文 | [English](./README.md)

企業級 Java/Spring Boot 開發工具包，提供 4 個獨立的專業 plugins。

## 快速概覽

### 4 個獨立 Plugins

#### 1. bill-billing-unit-test-reviewer

專注於單元測試審查與最佳實踐

- **Agent**: bill-billing-unit-test-reviewer
- **Skill**: `/review-test` - 單元測試程式碼審查
- **專長**: TDD、測試設計、覆蓋率分析、避免過度設計

#### 2. bill-code-reviewer

程式碼品質審查與 PR Review

- **Agent**: bill-code-reviewer
- **Skills**:
  - `/code-review` - 程式碼品質審查（Clean Code + 避免過度設計）
  - `/review-pr` - PR 變更審查（branch 差異或 GitHub PR）
- **專長**: Clean Code、避免過度設計、架構評估、PR Review

#### 3. bill-java-developer

Spring Boot 開發與資料庫優化專家

- **Agent**: bill-java-developer
- **Skills**:
  - `/design-solution` - 技術方案設計與建議
  - `/optimize-query` - SQL/JPA 優化
  - `/mysql-performance` - MySQL 性能優化
- **專長**: Spring Boot、JPA、資料庫效能、企業架構

#### 4. bill-java-skills

Java 開發最佳實踐知識庫

- **Skills** (自動觸發，無需手動調用):
  - `clean-architecture` - Clean Architecture 設計原則
  - `effective-java` - Effective Java 最佳實踐
  - `mysql-optimization` - MySQL 效能優化與 JPA 調校

> **Skills vs Agents 的區別**:
>
> - **Skills** (`/xxx`): Slash command 或自動觸發的知識庫
> - **Agents**: 根據對話自動啟動，提供互動式協助

## 安裝

### 新電腦安裝

```bash
git clone https://github.com/xinqilin/claude-dev-toolkit-marketplace
cd claude-dev-toolkit-marketplace
./install.sh --all
```

### 安裝指定 Plugin

```bash
# 查看可用的 plugins
./install.sh --list

# 只安裝你需要的
./install.sh --plugin bill-code-reviewer
./install.sh --plugin bill-java-developer
./install.sh --plugin bill-java-skills
./install.sh --plugin bill-billing-unit-test-reviewer
```

### 卸載

```bash
./uninstall.sh
```

### 更新

安裝使用 symlink，直接 `git pull` 即可更新，不需重新安裝。

```bash
git pull
```

## 快速開始

### 使用 Slash Commands

#### 程式碼審查

```text
/code-review src/main/java/com/example/OrderService.java
```

#### PR 審查

```text
# 審查 GitHub PR（需要 gh CLI）
/review-pr 123
/review-pr #456

# 審查當前 branch 對 master 的差異
/review-pr

# 審查 feature-branch 對 develop 的差異
/review-pr feature-branch develop
```

**注意**：審查 GitHub PR 需要安裝 `gh` CLI：

```bash
brew install gh
gh auth login
```

#### Spring Boot 開發

```text
/design-solution
[描述你的需求或問題]

/optimize-query
[貼上你的 SQL 或 JPA 程式碼]

/mysql-performance
[貼上你的 SQL 查詢或 EXPLAIN 結果]
```

#### 單元測試審查

```text
/review-test src/test/java/com/example/OrderServiceTest.java
```

### 使用 Agents

Agents 根據對話內容自動啟動：

- **Java Developer Agent**: "我需要設計一個高併發訂單系統"
- **Code Reviewer Agent**: "請審查這段程式碼的品質"
- **Unit Test Reviewer Agent**: "請審查我的單元測試設計"

### 自動觸發 Skills（bill-java-skills）

無需調用，Claude 自動應用這些原則：

- **clean-architecture**: 討論架構設計、分層結構、依賴規則時
- **effective-java**: 審查 Java 程式碼品質、討論設計模式時
- **mysql-optimization**: 討論資料庫效能、N+1 問題、JPA 優化時

## 目錄結構

```plaintext
project-claude-code-plugins/
├── plugins/
│   ├── bill-billing-unit-test-reviewer/
│   │   ├── agents/
│   │   │   └── bill-billing-unit-test-reviewer.md
│   │   └── skills/
│   │       └── review-test/
│   │           └── SKILL.md
│   ├── bill-code-reviewer/
│   │   ├── agents/
│   │   │   └── bill-code-reviewer.md
│   │   └── skills/
│   │       ├── code-review/
│   │       │   └── SKILL.md
│   │       └── review-pr/
│   │           └── SKILL.md
│   ├── bill-java-developer/
│   │   ├── agents/
│   │   │   └── bill-java-developer.md
│   │   └── skills/
│   │       ├── design-solution/SKILL.md
│   │       ├── optimize-query/SKILL.md
│   │       └── mysql-performance/SKILL.md
│   └── bill-java-skills/
│       └── skills/
│           ├── clean-architecture/
│           │   ├── SKILL.md
│           │   └── references/
│           ├── effective-java/
│           │   ├── SKILL.md
│           │   └── references/
│           └── mysql-optimization/
│               ├── SKILL.md
│               └── references/
├── install.sh
├── uninstall.sh
├── CLAUDE.md
└── README.md
```

## GitHub Repository

[https://github.com/xinqilin/claude-dev-toolkit-marketplace](https://github.com/xinqilin/claude-dev-toolkit-marketplace)

## 授權

MIT License - 詳見 [LICENSE](LICENSE) 檔案
