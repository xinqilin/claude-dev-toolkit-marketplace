---
description: Review pull request changes between branches with senior developer standards
argument-hint: [compare-branch] [base-branch]
allowed-tools: Read, Grep, Glob, Bash
model: sonnet
---

# PR Review

Review pull request changes between branches with senior Java developer standards, focusing on Clean Code and avoiding over-design.

## Purpose

Review the **changes** between two branches (typically feature branch -> master), not just static code. Focus on:
- What changed and why
- Impact of the changes
- PR-specific concerns (commit quality, breaking changes, test coverage)
- Code quality of the changes (using Clean Code principles)

## Parameter Usage

This command accepts two optional parameters:
- **compare-branch** (default: current branch): The feature/source branch being reviewed
- **base-branch** (default: master): The target branch to compare against

**Examples**:
```bash
# Review current branch against master
/review-pr

# Review feature-branch against master
/review-pr feature-branch

# Review feature-branch against develop
/review-pr feature-branch develop
```

## Step 1: Get Branch Information and Diff

### 1.1 Verify Git Repository
First, verify we're in a git repository:
```bash
git rev-parse --git-dir 2>/dev/null
```
If this fails, inform the user this command must be run in a git repository.

### 1.2 Determine Branches
```bash
# Get current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Determine compare and base branches
COMPARE=${1:-$CURRENT_BRANCH}  # First argument or current branch
BASE=${2:-master}               # Second argument or master
```

### 1.3 Verify Branches Exist
```bash
# Verify compare branch exists
if ! git rev-parse --verify "$COMPARE" >/dev/null 2>&1; then
    echo "Error: Branch '$COMPARE' does not exist"
    echo "Available branches:"
    git branch -a
    exit 1
fi

# Verify base branch exists
if ! git rev-parse --verify "$BASE" >/dev/null 2>&1; then
    echo "Error: Branch '$BASE' does not exist"
    echo "Available branches:"
    git branch -a
    exit 1
fi
```

### 1.4 Get Change Information
```bash
# Get changed files with status
git diff "$BASE..$COMPARE" --name-status

# Get diff statistics
git diff "$BASE..$COMPARE" --stat

# Get commit history
git log "$BASE..$COMPARE" --oneline --no-merges

# Get full diff (for analysis)
git diff "$BASE..$COMPARE"
```

### 1.5 Check for Empty Diff
If `git diff "$BASE..$COMPARE"` returns nothing, inform the user there are no differences between the branches.

## Step 2: Analyze Changes

### 2.1 Categorize Changed Files
From `git diff --name-status`, categorize files:
- **A** = Added files
- **M** = Modified files
- **D** = Deleted files
- **R** = Renamed files

Focus primarily on `.java` files. Mention other file types (`.xml`, `.yml`, `.properties`) briefly.

### 2.2 Parse Diff for Code Changes
For each modified `.java` file:
- Identify which methods/classes were changed
- Extract the changed code blocks (lines with +/-)
- Focus review on the **changed parts**, not the entire file

### 2.3 Commit History Analysis
Review commit messages and commit structure:
- Are commit messages clear and descriptive?
- Are commits reasonably sized (not too large)?
- Are there meaningless merge commits?
- Do commits represent logical units of work?

## Step 3: Code Quality Review

**IMPORTANT**: Reuse the review principles from `code-review.md`. Do NOT repeat the full checklist here.

For each changed code block, check:
1. Naming and Readability
2. Method Design
3. Avoiding Over-design
4. Exception Handling
5. Spring Boot Best Practices
6. Performance Considerations

Refer to `/code-review` command's detailed guidelines for these areas.

## Step 4: PR-Specific Checks

These checks are unique to PR review (not in regular code review):

### 4.1 Test Coverage
- Are there new/updated test files for the changes?
- For new features: Is there adequate test coverage?
- For bug fixes: Is there a regression test?

**Look for**:
- Test files matching the changed source files
- Example: `OrderService.java` → should have `OrderServiceTest.java`

### 4.2 Breaking Changes
Check if changes might break existing functionality:
- Removed public methods
- Changed method signatures
- Removed or renamed fields in DTOs/entities
- Changed API endpoints or request/response formats

### 4.3 Unrelated Changes
- Are there files that don't belong in this PR?
- Are there accidental formatting changes in unrelated files?
- Are there commented-out code blocks?

### 4.4 Debug/TODO Code
```bash
# Search for debug code
git diff "$BASE..$COMPARE" | grep -E "System.out.println|TODO|FIXME|XXX"
```

- Are there leftover `System.out.println` statements?
- Are there unresolved TODO/FIXME comments?

### 4.5 Documentation
- If public APIs changed: Is documentation updated?
- If configuration changed: Is README/docs updated?
- Are there new dependencies that need explanation?

## Step 5: Generate PR Review Report

### Output Format (Traditional Chinese)

**IMPORTANT: All output must be in Traditional Chinese (繁體中文)**

---

# PR Review 報告

## 變更概覽
- **Base Branch**: [base branch name]
- **Compare Branch**: [compare branch name]
- **變更檔案數量**: [total files]
- **新增**: +[lines added] 行
- **刪除**: -[lines deleted] 行
- **主要變更類型**: Feature / BugFix / Refactor / Other

## Commit 歷史分析

**Commit 數量**: [total commits]

**Commit 品質評估**: 優秀 / 良好 / 需改進

### 優點
- [List good aspects of commit history]

### 建議
- [List suggestions for commit improvements, if any]

## 程式碼品質評估

- **複雜度評分**: Low / Medium / High
- **可維護性**: [1-10] / 10
- **Over-design 程度**: 無 / 輕微 / 嚴重

## 變更檔案詳細審查

### 新增檔案 ([count] 個)

| 檔案 | 評估 | 說明 |
|------|------|------|
| [filename] | [優秀/良好/需改進] | [brief assessment] |

### 修改檔案 ([count] 個)

#### Priority 1 - 必須修正
| 問題 | 位置 | 影響 | 修正方式 |
|------|------|------|----------|
| [issue description] | [file:line] | [impact] | [fix suggestion] |

#### Priority 2 - 建議改進
| 問題 | 位置 | 影響 | 修正方式 |
|------|------|------|----------|
| [issue description] | [file:line] | [impact] | [fix suggestion] |

### 刪除檔案 ([count] 個)

| 檔案 | 說明 |
|------|------|
| [filename] | [reason for deletion assessment] |

## PR 特定檢查

### 測試覆蓋
- [ ] **[狀態]** - [說明]

**範例**:
- [ ] **缺少單元測試** - OrderService 沒有對應的測試檔案
- [x] **測試已覆蓋** - Controller 有完整的測試

### 文件更新
- [x] README 已更新
- [ ] **缺少 API 文件** - 建議新增或更新 API 文件

### Breaking Changes
- [ ] **無 Breaking Changes**

或

- [ ] **發現 Breaking Change** - [具體說明影響範圍]

### Debug/TODO Code
- [x] 沒有遺留的 debug code
- [ ] **發現 [count] 處 TODO comments** - [列出位置]

### 其他發現
- [x] 沒有無關的檔案變更
- [ ] **發現問題** - [說明]

## 整體建議

### 建議合併前修正 (Priority 1)
1. [必須修正的問題]
2. [必須修正的問題]

### 建議後續改進 (Priority 2)
1. [建議改進的項目]
2. [建議改進的項目]

## 總結評估

**整體評價**: 優秀 / 良好 / 需改進 / 不建議合併

**優點**:
- [列出主要優點]

**主要風險**:
- [列出主要風險，如果有]

**建議合併時機**: [建議何時可以合併，或需要什麼條件]

---

## Error Handling

Handle these scenarios gracefully:

1. **Branch doesn't exist**:
   - Show clear error message
   - List available branches for reference

2. **No differences between branches**:
   - Message: "沒有發現任何差異。[compare] 和 [base] 兩個 branch 的程式碼相同。"

3. **Not in git repository**:
   - Message: "錯誤：此指令必須在 git repository 中執行。"

4. **Merge conflicts exist**:
   - Warn user about unresolved conflicts
   - Message: "警告：發現未解決的 merge conflicts。建議先解決衝突後再進行 review。"

## Review Principles

Remember:
1. **Focus on changes**: Review what changed, not the entire codebase
2. **Use Clean Code standards**: Apply the same standards as `/code-review`
3. **PR-specific concerns**: Test coverage, breaking changes, commit quality
4. **Be constructive**: Provide clear, actionable feedback
5. **Prioritize issues**: Distinguish between "must fix" and "nice to have"
6. **Avoid over-design**: Check if changes are unnecessarily complex

## Integration with /code-review

This command (`/review-pr`) focuses on:
- **Identifying what changed** (git diff, commits)
- **PR-specific checks** (tests, breaking changes, docs)
- **Change impact analysis**

The core code quality review still follows the principles in `/code-review`:
- Clean Code principles
- Avoiding over-design
- Spring Boot best practices

**Don't duplicate the full checklist** - refer to `/code-review` for detailed coding standards.
