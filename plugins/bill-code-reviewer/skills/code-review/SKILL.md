---
name: code-review
description: Use PROACTIVELY when reviewing Java/Spring Boot code quality, Clean Code compliance, or over-design concerns.
argument-hint: [file-or-directory]
allowed-tools: Read, Grep, Glob, Bash
model: sonnet
---

# Code Review

Review code with senior Java developer (15+ years experience) standards, focusing on Clean Code and avoiding over-design.

## Core Philosophy

1. **Clean Code** — The next person should understand it quickly
2. **NEVER Over-design** — Solve the current problem only; don't predict the future
3. **Pragmatic** — Battle-tested, consider actual maintenance cost

## Review Focus Areas

### 1. Avoiding Over-design (Most Important)

**Don't abstract too early** (Rule of Three):
```java
// Bad: Abstract after seeing it once
interface PaymentProcessor { ... }
class CreditCardPaymentProcessor implements PaymentProcessor { ... }
// Only supports credit card anyway

// Good: Wait until multiple payment methods are actually needed
class PaymentService {
    public void processCreditCardPayment(...) { ... }
}
```

**YAGNI — No hypothetical design**:
```java
// Bad: Fields for "might need later"
class Order {
    private PaymentStrategy paymentStrategy;  // Might change later?
    private ShippingStrategy shippingStrategy; // Might change later?
}

// Good: Solve current problem
class Order {
    private String paymentMethod; // Enough for now
}
```

**Avoid meaningless interfaces** (single-implementation interfaces add zero value):
```java
// Bad: UserServiceImpl only has one implementation
interface UserService { ... }
class UserServiceImpl implements UserService { ... }

// Good: Extract interface when multiple implementations are needed
class UserService { ... }
```

### 2. Spring Boot Anti-Patterns

- `@Transactional` self-invocation trap: calling an `@Transactional` method from within the same class bypasses the proxy
- `@Transactional` on controller or repository (should be service layer only)
- `@Autowired` field injection instead of constructor injection
- Business logic in controllers

### 3. Other Quality Checks

- Names clearly express intent (no abbreviations)
- Methods are short and do one thing
- Nesting depth ≤ 3
- No swallowed exceptions (catch with no context)
- No I/O operations in loops

## Review Checklist

### Avoiding Over-design
- [ ] No premature abstraction (Rule of Three)
- [ ] No hypothetical design (YAGNI)
- [ ] No meaningless single-implementation interfaces
- [ ] Complexity matches the problem

### Naming and Readability
- [ ] Variable/method names clearly express intent
- [ ] Boolean uses is/has/can prefix

### Method Design
- [ ] Methods are short, do one thing
- [ ] Nesting levels ≤ 3
- [ ] Parameters ≤ 4

### Exception Handling
- [ ] No swallowed exceptions
- [ ] Exception messages have sufficient context
- [ ] Specific exception types

### Spring Boot
- [ ] Constructor injection
- [ ] `@Transactional` on service layer only
- [ ] No `@Transactional` self-invocation

### Performance
- [ ] No N+1 problems
- [ ] No I/O in loops

## Output Format

**IMPORTANT: All output must be in Traditional Chinese (繁體中文)**

### 程式碼評估
- **複雜度評分**：Low / Medium / High
- **可維護性**：1-10 分
- **Over-design 程度**：無 / 輕微 / 嚴重

### 優點
列出程式碼做得好的地方

### 需要改進（依優先順序）

#### Priority 1 - 必須修正
| 問題 | 位置 | 影響 | 修正方式 |
|------|------|------|----------|
| [問題描述] | [檔案:行號] | [影響] | [修正方式] |

#### Priority 2 - 建議改進
| 問題 | 位置 | 影響 | 修正方式 |
|------|------|------|----------|
| [問題描述] | [檔案:行號] | [影響] | [修正方式] |

### 重構建議
如果有較大的重構建議，提供 Before/After 程式碼對比

### 總結
一句話總結程式碼品質和主要改進方向

## Gotchas

<!-- 持續更新：遇到新的 Claude 常犯錯誤時加入 -->

- **讀完整上下文再下結論**：不要只看 diff 就說「這個方法太長」，先確認整個類別的職責
- **「建議抽 interface」之前先確認多實作需求**：單一實作的 interface 是 over-design，不是最佳實踐
- **Lombok @Data 在 Entity 上有問題**：自動生成的 `equals`/`hashCode` 包含所有欄位，導致 Hibernate proxy 比較失敗，應改用 `@Getter @Setter`
- **小心 reviewer bias**：不要把「我習慣的寫法」當成「正確的寫法」，提建議前想清楚為什麼
- **@Transactional self-invocation 不觸發代理**：同一 class 內部呼叫不會走 Spring AOP proxy，這是常見的 bug 來源
