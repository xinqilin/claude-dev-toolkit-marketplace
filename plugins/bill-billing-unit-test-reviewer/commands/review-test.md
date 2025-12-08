---
description: Review team members' unit test code for quality and best practices
argument-hint: [test-file-or-directory]
allowed-tools: Read, Grep, Glob
model: sonnet
---

# Review Unit Test

Review team members' unit test code to ensure test quality meets senior developer standards.

## Core Principle

**Most Important**: All test scenarios must be based on real system behavior. Never fabricate hypothetical scenarios.

## Review Focus Areas

### 1. Reality Check

- Does the tested exception actually get thrown in the code?
- Does the tested branch actually exist in the code?
- Are there any hypothetical "what-if" test scenarios?

**Bad Example**:
```java
// Assuming facade throws IllegalArgumentException, but it actually doesn't
@Test
void shouldThrowIllegalArgumentException() {
    assertThrows(IllegalArgumentException.class, () -> facade.process(null));
}
```

**Good Example**:
```java
// First check the source code, confirm this exception is actually thrown
@Test
@DisplayName("當Token無效時_應該拋出TokenInvalidException")
void shouldThrowTokenInvalidExceptionWhenTokenIsInvalid() {
    // AcFacade.java:45 actually throws this exception
    assertThrows(TokenInvalidException.class, () -> facade.process(invalidToken));
}
```

### 2. Over-Design Check

Common over-design problems:

- **Over-abstracted Helper Methods**
  ```java
  // Bad: Over-encapsulation
  private Order createTestOrder() {
      return createTestOrder(DEFAULT_USER, DEFAULT_ITEMS, DEFAULT_AMOUNT);
  }

  // Good: Clear and direct
  Order order = new Order(userId, items, amount);
  ```

- **Unnecessary Base Classes**
  ```java
  // Bad: Complex inheritance for tests
  class OrderServiceTest extends AbstractServiceTest<Order, OrderRepository>

  // Good: Simple and direct
  class OrderServiceTest { ... }
  ```

- **Excessive Mock Setup**
  ```java
  // Bad: Mock everything upfront
  @BeforeEach
  void setup() {
      when(repo.findById(any())).thenReturn(Optional.of(entity));
      when(repo.save(any())).thenReturn(entity);
      when(repo.delete(any())).thenReturn(void);
      // ... 10 more lines
  }

  // Good: Mock only what's needed per test
  @Test
  void shouldFindOrder() {
      when(repo.findById(1L)).thenReturn(Optional.of(order));
      // test
  }
  ```

### 3. Test Responsibility Separation

| Layer | Should Test | Should NOT Test |
|-------|-------------|-----------------|
| Model | Bean Validation (@NotBlank, @Size, etc.) | - |
| Controller | HTTP behavior, status codes, JSON serialization | Duplicate Validation rules |
| Service | Business logic, state changes | Database operation details |

### 4. Test Naming and Structure

**Use @DisplayName in Traditional Chinese**:
```java
@Test
@DisplayName("當訂單金額超過限制時_應該拋出例外")
void shouldThrowExceptionWhenAmountExceedsLimit() { ... }
```

**Use @Nested for organization**:
```java
class UserServiceTest {
    @Nested
    @DisplayName("使用者註冊測試")
    class RegisterUser {
        @Test
        @DisplayName("當提供有效資料時_應該成功建立使用者")
        void shouldCreateUserWithValidData() { ... }
    }
}
```

### 5. Verification Strategy

**Prefer State Verification**:
```java
// Good: State verification
assertThat(order.getStatus()).isEqualTo(OrderStatus.PENDING);

// Avoid: Interaction verification (unless necessary)
verify(repository).save(any()); // Fragile!
```

**Use interaction verification only when state cannot be asserted**:
```java
// External service call cannot be verified by state
verify(emailService).sendOrderCompletionEmail(orderId);
```

## Review Checklist

### Reality
- [ ] All tested exceptions are actually thrown in the code
- [ ] All test scenarios reflect real system behavior
- [ ] No hypothetical "what-if" tests

### Simplicity
- [ ] No over-abstracted helper methods
- [ ] No unnecessary test base classes
- [ ] Mock setup is minimal, only what's needed
- [ ] No duplicate equivalence class tests

### Responsibility Separation
- [ ] Model tests focus on Validation
- [ ] Controller tests focus on HTTP behavior
- [ ] No cross-layer duplicate testing

### Code Quality
- [ ] Follows AAA Pattern (Arrange-Act-Assert)
- [ ] DisplayName uses Traditional Chinese
- [ ] Uses @Nested for organization
- [ ] State verification preferred over interaction verification

## Output Format

**IMPORTANT: All output must be in Traditional Chinese (繁體中文)**

### 測試分析
- **覆蓋率評估**：涵蓋了什麼、遺漏了什麼
- **真實性檢查**：是否有虛構的測試場景
- **職責檢查**：測試是否在正確的層級

### 發現的問題
每個問題包含：
- **問題**：描述問題
- **證據**：程式碼行號參考
- **影響**：為什麼這是問題
- **修正**：具體改進建議

### 建議
- 需要新增的測試（附理由）
- 需要刪除的測試（附理由）
- 需要重構的測試（附前後對比）

## Remember

1. **NEVER Over-Design**
2. **Read the code first, then write tests**
3. **Every test must have evidence - don't fabricate scenarios**
4. **Simple is better than complex**
