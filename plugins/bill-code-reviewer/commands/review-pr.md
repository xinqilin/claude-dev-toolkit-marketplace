---
description: Review pull request changes between branches or GitHub PRs with senior developer standards
argument-hint: "[compare-branch-or-pr-number] [base-branch]"
allowed-tools: Read, Grep, Glob, Bash
model: sonnet
---

# PR Review

Review pull request changes with senior Java developer standards, focusing on Clean Code and avoiding over-design.

Supports **two modes**:
1. **GitHub PR Mode**: Review a GitHub PR by PR number (requires `gh` CLI)
2. **Branch Comparison Mode**: Review changes between two local branches (uses `git diff`)

## Purpose

Review the **changes** in a pull request, not just static code. Focus on:
- What changed and why
- Impact of the changes
- PR-specific concerns (commit quality, breaking changes, test coverage, CI status)
- Code quality of the changes (using Clean Code principles)

## Parameter Usage

This command accepts two optional parameters with **automatic detection**:

### Parameter 1: compare-branch-or-pr-number
- **PR Number** (e.g., `123` or `#123`): Review GitHub PR using `gh` CLI
- **Branch Name** (e.g., `feature-auth`): Review local branch using `git diff`
- **Empty**: Use current branch (default)

### Parameter 2: base-branch (optional, git diff mode only)
- Default: `master`
- Only used when comparing branches

**Examples**:
```bash
# Review GitHub PR #123 (gh mode)
/review-pr 123
/review-pr #123

# Review current branch against master (git diff mode)
/review-pr

# Review feature-branch against master (git diff mode)
/review-pr feature-branch

# Review feature-branch against develop (git diff mode)
/review-pr feature-branch develop
```

## Step 0: Parameter Type Detection

**Automatically detect whether to use GitHub PR mode or branch comparison mode**.

```bash
# Get first parameter
INPUT=${1:-""}

# Detect parameter type
if [[ -z "$INPUT" ]]; then
    # Empty parameter: use current branch vs master (git diff mode)
    MODE="git_diff"
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    COMPARE=$CURRENT_BRANCH
    BASE=${2:-master}

elif [[ "$INPUT" =~ ^#?[0-9]+$ ]]; then
    # Pure number (with optional # prefix): PR number (gh mode)
    MODE="gh_pr"
    PR_NUMBER="${INPUT#\#}"  # Remove # prefix if present

else
    # Other: branch name (git diff mode)
    MODE="git_diff"
    COMPARE=$INPUT
    BASE=${2:-master}
fi
```

## Step 1: Mode-Specific Processing

### Mode A: GitHub PR Mode (`MODE="gh_pr"`)

This mode uses GitHub CLI (`gh`) to review a PR by PR number.

#### 1.1 Verify gh CLI Availability

```bash
if [[ "$MODE" == "gh_pr" ]]; then
    # Check if gh is installed
    if ! command -v gh &> /dev/null; then
        echo "錯誤：GitHub CLI (gh) 未安裝"
        echo ""
        echo "請執行以下指令安裝："
        echo "  brew install gh"
        echo ""
        echo "或參考：https://cli.github.com/"
        exit 1
    fi

    # Check if gh is authenticated
    if ! gh auth status &> /dev/null; then
        echo "錯誤：GitHub CLI 尚未認證"
        echo ""
        echo "請執行以下指令進行認證："
        echo "  gh auth login"
        echo ""
        exit 1
    fi
fi
```

#### 1.2 Get PR Information

```bash
if [[ "$MODE" == "gh_pr" ]]; then
    # Get PR metadata using JSON output
    PR_JSON=$(gh pr view "$PR_NUMBER" --json \
        number,title,body,state,author,\
        baseRefName,headRefName,\
        additions,deletions,changedFiles,\
        statusCheckRollup,latestReviews,\
        createdAt,updatedAt 2>&1)

    # Check if command succeeded
    if [[ $? -ne 0 ]]; then
        echo "錯誤：無法取得 PR #$PR_NUMBER 的資訊"
        echo ""
        echo "$PR_JSON"
        echo ""
        echo "請確認："
        echo "1. PR 編號是否正確"
        echo "2. 你是否有權限存取此 repository"
        echo "3. 是否在正確的 git repository 中"
        exit 1
    fi

    # Parse JSON (requires jq)
    # Check if jq is available
    if ! command -v jq &> /dev/null; then
        echo "警告：jq 未安裝，將使用簡化的 JSON 解析"
        echo "建議安裝 jq 以獲得更好的體驗：brew install jq"
        # Use simplified parsing if jq is not available
        PR_TITLE=$(echo "$PR_JSON" | grep -o '"title":"[^"]*"' | cut -d'"' -f4)
        PR_AUTHOR=$(echo "$PR_JSON" | grep -o '"login":"[^"]*"' | head -1 | cut -d'"' -f4)
        PR_STATE=$(echo "$PR_JSON" | grep -o '"state":"[^"]*"' | cut -d'"' -f4)
    else
        # Use jq for reliable JSON parsing
        PR_TITLE=$(echo "$PR_JSON" | jq -r '.title')
        PR_AUTHOR=$(echo "$PR_JSON" | jq -r '.author.login')
        PR_STATE=$(echo "$PR_JSON" | jq -r '.state')
        BASE_BRANCH=$(echo "$PR_JSON" | jq -r '.baseRefName')
        HEAD_BRANCH=$(echo "$PR_JSON" | jq -r '.headRefName')
        ADDITIONS=$(echo "$PR_JSON" | jq -r '.additions')
        DELETIONS=$(echo "$PR_JSON" | jq -r '.deletions')
        CHANGED_FILES=$(echo "$PR_JSON" | jq -r '.changedFiles')
    fi

    # Get diff
    PR_DIFF=$(gh pr diff "$PR_NUMBER" --patch 2>&1)

    # Get changed files list
    CHANGED_FILES_LIST=$(gh pr diff "$PR_NUMBER" --name-only 2>&1)

    # Get commits
    PR_COMMITS=$(gh pr view "$PR_NUMBER" --json commits \
        --jq '.commits[] | "\(.oid[0:7]) \(.messageHeadline)"' 2>&1)
fi
```

### Mode B: Branch Comparison Mode (`MODE="git_diff"`)

This mode uses standard `git diff` to compare local branches.

#### 1.1 Verify Git Repository
First, verify we're in a git repository:
```bash
if [[ "$MODE" == "git_diff" ]]; then
    git rev-parse --git-dir 2>/dev/null
    if [[ $? -ne 0 ]]; then
        echo "錯誤：此指令必須在 git repository 中執行"
        exit 1
    fi
fi
```

#### 1.2 Determine Branches
```bash
if [[ "$MODE" == "git_diff" ]]; then
    # Get current branch
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

    # Compare and base branches were already set in Step 0
    # COMPARE=${1:-$CURRENT_BRANCH}
    # BASE=${2:-master}
fi
```

#### 1.3 Verify Branches Exist (with fallback to gh)
```bash
if [[ "$MODE" == "git_diff" ]]; then
    # Verify compare branch exists
    if ! git rev-parse --verify "$COMPARE" >/dev/null 2>&1; then
        echo "錯誤：Branch '$COMPARE' 不存在"
        echo ""
        echo "可用的 branches:"
        git branch -a
        echo ""

        # Fallback: Try to find corresponding PR on GitHub
        echo "嘗試在 GitHub 上查找對應的 PR..."
        if command -v gh &> /dev/null && gh auth status &> /dev/null; then
            PR_INFO=$(gh pr list --head "$COMPARE" --json number,title --limit 1 2>/dev/null)
            if [[ -n "$PR_INFO" ]] && command -v jq &> /dev/null; then
                PR_NUM=$(echo "$PR_INFO" | jq -r '.[0].number')
                PR_TITLE=$(echo "$PR_INFO" | jq -r '.[0].title')
                if [[ "$PR_NUM" != "null" ]]; then
                    echo ""
                    echo "✓ 找到對應的 PR #$PR_NUM: $PR_TITLE"
                    echo ""
                    echo "建議使用以下指令審查："
                    echo "  /review-pr $PR_NUM"
                    echo ""
                fi
            fi
        fi
        exit 1
    fi

    # Verify base branch exists
    if ! git rev-parse --verify "$BASE" >/dev/null 2>&1; then
        echo "錯誤：Branch '$BASE' 不存在"
        echo ""
        echo "可用的 branches:"
        git branch -a
        exit 1
    fi
fi
```

#### 1.4 Get Change Information
```bash
if [[ "$MODE" == "git_diff" ]]; then
    # Get changed files with status
    git diff "$BASE..$COMPARE" --name-status

    # Get diff statistics
    git diff "$BASE..$COMPARE" --stat

    # Get commit history
    git log "$BASE..$COMPARE" --oneline --no-merges

    # Get full diff (for analysis)
    git diff "$BASE..$COMPARE"
fi
```

#### 1.5 Check for Empty Diff
```bash
if [[ "$MODE" == "git_diff" ]]; then
    DIFF_OUTPUT=$(git diff "$BASE..$COMPARE")
    if [[ -z "$DIFF_OUTPUT" ]]; then
        echo "沒有發現任何差異"
        echo ""
        echo "$COMPARE 和 $BASE 兩個 branch 的程式碼相同"
        exit 0
    fi
fi
```

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

<!-- For gh mode: Display PR information -->
**PR 資訊** (僅 gh mode):
- **PR 編號**: #[PR number]
- **標題**: [PR title]
- **作者**: @[PR author]
- **狀態**: OPEN / MERGED / CLOSED / DRAFT
- **Base Branch**: [base branch]
- **Head Branch**: [head branch]

<!-- For both modes: Display change statistics -->
**變更統計**:
- **變更檔案數量**: [total files] 個檔案
- **新增**: +[lines added] 行
- **刪除**: -[lines deleted] 行
- **主要變更類型**: Feature / BugFix / Refactor / Other

<!-- For gh mode: Display CI/CD status -->
**CI/CD 檢查** (僅 gh mode):
```bash
# Parse CI status from PR JSON
if [[ "$MODE" == "gh_pr" ]] && command -v jq &> /dev/null; then
    CI_CHECKS=$(echo "$PR_JSON" | jq -r '.statusCheckRollup[]? |
        "\(.name): \(.conclusion // .status)"' 2>/dev/null)

    if [[ -n "$CI_CHECKS" ]]; then
        echo "**CI/CD 檢查**:"
        while IFS= read -r check; do
            if [[ -z "$check" ]]; then continue; fi
            CHECK_NAME=$(echo "$check" | cut -d: -f1)
            CHECK_STATUS=$(echo "$check" | cut -d: -f2 | xargs)

            case "$CHECK_STATUS" in
                SUCCESS) echo "- ✅ $CHECK_NAME (passing)" ;;
                FAILURE) echo "- ❌ $CHECK_NAME (failing)" ;;
                PENDING|IN_PROGRESS|QUEUED) echo "- ⏳ $CHECK_NAME (pending)" ;;
                SKIPPED) echo "- ⊘ $CHECK_NAME (skipped)" ;;
                *) echo "- ⚠️ $CHECK_NAME ($CHECK_STATUS)" ;;
            esac
        done <<< "$CI_CHECKS"
    else
        echo "**CI/CD 檢查**: 無檢查或資訊不可用"
    fi
fi
```

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

### Git Diff Mode Errors

1. **Branch doesn't exist**:
   - Show clear error message
   - List available branches for reference
   - **Fallback**: Attempt to find corresponding PR on GitHub using `gh pr list --head`

2. **No differences between branches**:
   - Message: "沒有發現任何差異。[compare] 和 [base] 兩個 branch 的程式碼相同。"

3. **Not in git repository**:
   - Message: "錯誤：此指令必須在 git repository 中執行。"

4. **Merge conflicts exist**:
   - Warn user about unresolved conflicts
   - Message: "警告：發現未解決的 merge conflicts。建議先解決衝突後再進行 review。"

### GitHub PR Mode Errors

1. **gh CLI not installed**:
   - Message: "錯誤：GitHub CLI (gh) 未安裝"
   - Provide installation instructions: `brew install gh`
   - Link: https://cli.github.com/

2. **gh CLI not authenticated**:
   - Message: "錯誤：GitHub CLI 尚未認證"
   - Provide authentication instructions: `gh auth login`

3. **PR doesn't exist**:
   - Message: "錯誤：無法取得 PR #[number] 的資訊"
   - Check: PR number is correct, user has access, in correct repository

4. **jq not installed** (warning, not error):
   - Message: "警告：jq 未安裝，將使用簡化的 JSON 解析"
   - Recommendation: Install jq for better experience: `brew install jq`
   - Fallback: Use grep-based JSON parsing

5. **Network issues**:
   - Message: Show the actual error from gh command
   - No fallback available (gh requires network)

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
