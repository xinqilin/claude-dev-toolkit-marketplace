---
name: review-pr
description: Use when reviewing PR changes, comparing branches, or analyzing GitHub pull requests. Supports both gh CLI (PR number) and git diff (branch comparison) modes.
argument-hint: "[compare-branch-or-pr-number] [base-branch]"
allowed-tools: Read, Grep, Glob, Bash
context: fork
---

# PR Review

Review pull request changes with senior Java developer standards.

Supports **two modes**:
1. **GitHub PR Mode**: PR number (e.g., `123` or `#123`) → uses `gh pr view` + `gh pr diff`
2. **Branch Comparison Mode**: branch name or empty → uses `git diff`

## Parameter Usage

```bash
/review-pr 123           # GitHub PR #123
/review-pr               # Current branch vs master
/review-pr feature-auth  # feature-auth vs master
/review-pr feature-auth develop  # feature-auth vs develop
```

**Auto-detection**: Pure number → GitHub PR mode. Anything else → branch comparison mode.

## Workflow

### Step 1: Gather Information

**GitHub PR mode**: Use `gh pr view <PR_NUMBER> --json number,title,body,state,author,baseRefName,headRefName,additions,deletions,changedFiles,commits` and `gh pr diff <PR_NUMBER>`.

**Branch comparison mode**: Use `git diff <base>..<compare> --name-status`, `git diff --stat`, `git log --oneline --no-merges`, and `git diff` for full diff.

### Step 2: Categorize Changed Files

From `git diff --name-status`: Added (A), Modified (M), Deleted (D), Renamed (R).

Focus on `.java` files. Mention other types (`.yml`, `.properties`) briefly.

### Step 3: Code Quality Review

Apply the same standards as `/code-review` skill:
- Naming and Readability
- Method Design
- Avoiding Over-design
- Exception Handling
- Spring Boot Best Practices
- Performance Considerations

**Focus on the changed lines, not the entire file.**

### Step 4: PR-Specific Checks (Key Differentiator from Code Review)

#### Test Coverage
- New features: corresponding test files?
- Bug fixes: regression test added?
- `OrderService.java` changed → `OrderServiceTest.java` should be updated

#### Breaking Changes
- Removed public methods or changed method signatures
- Renamed fields in DTOs/entities
- Changed API endpoints or request/response formats

#### Unrelated Changes
- Files that don't belong in this PR
- Accidental formatting changes in unrelated files

#### Debug/TODO Code
Check for leftover `System.out.println`, `TODO`, `FIXME`:
```bash
git diff <base>..<compare> | grep -E "System.out.println|TODO|FIXME|XXX"
```

#### Documentation
- Public API changes → docs updated?
- New dependencies → explained?

## Output Format

**IMPORTANT: All output must be in Traditional Chinese (繁體中文)**

```markdown
# PR Review 報告

## 變更概覽
- **PR 資訊** (gh mode): 編號、標題、作者、狀態、base/head branch
- **變更統計**: 檔案數量、+新增行、-刪除行、主要變更類型

## Commit 歷史分析
- Commit 數量和品質評估

## 程式碼品質評估
- 複雜度、可維護性、Over-design 程度

## 變更檔案詳細審查

### Priority 1 - 必須修正
| 問題 | 位置 | 影響 | 修正方式 |

### Priority 2 - 建議改進
| 問題 | 位置 | 影響 | 修正方式 |

## PR 特定檢查
- 測試覆蓋 / 文件更新 / Breaking Changes / Debug Code

## 總結評估
**整體評價**: 優秀 / 良好 / 需改進 / 不建議合併
**建議合併時機**: [條件]
```

## When to Apply

- PR 變更審查（GitHub PR 或 branch 比較）
- 合併前的品質把關
- 跨檔案變更的影響分析

## Gotchas

<!-- 持續更新：遇到新的 Claude 常犯錯誤時加入 -->

- **大型 PR diff 可能被截斷**：`gh pr diff` 對 500+ 行的 PR 可能不完整，超過時應逐檔案 `gh api` 讀取
- **rename detection 閾值 50%**：重構性 rename 可能被 git diff 當成 delete+add，要用 `--find-renames` 確認
- **test 檔案也要審查品質**：不只看「有沒有 test」，要看 test 是否有意義（真實場景、正確 assertion）
- **CI 全過不代表程式碼品質好**：CI 只檢查編譯和測試，不檢查設計和架構問題
- **不要只看 diff**：對於關鍵修改，務必讀完整的 method/class 上下文才能判斷影響
