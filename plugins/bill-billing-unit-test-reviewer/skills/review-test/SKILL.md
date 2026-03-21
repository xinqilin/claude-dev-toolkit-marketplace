---
name: review-test
description: Use PROACTIVELY when reviewing unit test code quality, discussing test design, or evaluating test coverage for Java/Spring Boot projects.
argument-hint: [test-file-or-directory]
allowed-tools: Read, Grep, Glob
model: sonnet
---

# Review Unit Test

Review unit test code to ensure quality meets senior developer standards.

## Core Principle

**Most Important**: All test scenarios must be based on real system behavior. Never fabricate hypothetical scenarios.

## Review Focus Areas

### 1. Reality Check

- Does the tested exception actually get thrown in the code?
- Does the tested branch actually exist in the code?
- Are there any hypothetical "what-if" test scenarios?

```java
// Bad: Assuming exception is thrown without checking source code
@Test
void shouldThrowIllegalArgumentException() {
    assertThrows(IllegalArgumentException.class, () -> facade.process(null));
}

// Good: Verified AcFacade.java:45 actually throws TokenInvalidException
@Test
@DisplayName("當Token無效時_應該拋出TokenInvalidException")
void shouldThrowTokenInvalidExceptionWhenTokenIsInvalid() {
    assertThrows(TokenInvalidException.class, () -> facade.process(invalidToken));
}
```

### 2. Over-Design Check

- **Over-abstracted Helper Methods**: `createTestOrder(DEFAULT_USER, DEFAULT_ITEMS, DEFAULT_AMOUNT)` — just write `new Order(userId, items, amount)` inline
- **Unnecessary Base Classes**: `extends AbstractServiceTest<Order, OrderRepository>` — just `class OrderServiceTest { ... }`
- **Excessive Mock Setup in @BeforeEach**: Mock only what's needed per test, not everything upfront

### 3. Test Responsibility Separation

| Layer | Should Test | Should NOT Test |
|-------|-------------|-----------------|
| Model | Bean Validation (@NotBlank, @Size, etc.) | — |
| Controller | HTTP behavior, status codes, JSON serialization | Duplicate validation rules |
| Service | Business logic, state changes | Database operation details |

### 4. Naming and Structure

- `@DisplayName` in Traditional Chinese: `"當訂單金額超過限制時_應該拋出例外"`
- Use `@Nested` for logical grouping
- Test method: `should_expectedBehavior_when_condition()`

### 5. Verification Strategy

**Prefer state verification over interaction verification**:
```java
// Good: State verification
assertThat(order.getStatus()).isEqualTo(OrderStatus.PENDING);

// Use interaction verification only when state cannot be asserted
verify(emailService).sendOrderCompletionEmail(orderId);
```

## Review Checklist

### Reality
- [ ] All tested exceptions are actually thrown in the code
- [ ] All test scenarios reflect real system behavior

### Simplicity
- [ ] No over-abstracted helper methods
- [ ] No unnecessary test base classes
- [ ] Mock setup is minimal and per-test

### Responsibility Separation
- [ ] Model tests focus on Validation
- [ ] Controller tests focus on HTTP behavior
- [ ] No cross-layer duplicate testing

### Code Quality
- [ ] Follows AAA Pattern (Arrange-Act-Assert)
- [ ] `@DisplayName` in Traditional Chinese
- [ ] Uses `@Nested` for organization
- [ ] State verification preferred

## Output Format

**IMPORTANT: All output must be in Traditional Chinese (繁體中文)**

### 測試分析
- **覆蓋率評估**：涵蓋了什麼、遺漏了什麼
- **真實性檢查**：是否有虛構的測試場景

### 發現的問題
- **問題** / **證據**（行號） / **影響** / **修正**

### 建議
- 需要新增的測試（附理由）
- 需要刪除的測試（附理由）
- 需要重構的測試（附前後對比）

## When to Apply

- 單元測試程式碼品質審查
- 測試設計討論或覆蓋率評估
- 測試 over-design 檢查

## Gotchas

<!-- 持續更新：遇到新的 Claude 常犯錯誤時加入 -->

- **Mockito void method 寫法錯誤**：`when(service.voidMethod()).thenReturn(...)` 會編譯錯誤。void method 要用 `doNothing().when(service).voidMethod()`
- **@SpringBootTest 過度使用**：大多數 unit test 只需要 `@ExtendWith(MockitoExtension.class)`，@SpringBootTest 載入整個 ApplicationContext 很慢
- **verify() 預設 times(1)**：如果方法被呼叫 0 次不會報錯，要明確寫 `verify(service, times(1)).method()`
- **@MockBean 導致 Spring Context 重建**：同一測試類別混用不同 @MockBean 組合會讓 Spring 每次都重建 context，大幅降低測試速度
- **assertThat(list).containsExactly() 優於 assertEquals**：失敗時提供更清楚的差異說明（哪個元素不符）
