---
description: 進行全面的 Java 程式碼品質分析
argument-hint: [file-or-directory]
allowed-tools: Read, Grep, Glob, Bash
model: sonnet
---

# Analyze Code

Perform comprehensive analysis of Java code with focus on enterprise-grade quality, maintainability, and production readiness.

## 1. Structure & Design Analysis

### Single Responsibility Principle
- Does each class have one clear purpose?
- Are there God objects handling too many concerns?
- Can classes be decomposed into smaller, focused units?

### Dependency Management
- Are dependencies injected or hard-coded?
- Is dependency direction correct (high-level -> low-level)?
- Are there circular dependencies?
- Is the dependency graph clean and testable?

### Abstraction Levels
- Do abstractions hide implementation details properly?
- Are interfaces meaningful or just structural?
- Is there proper layering (presentation, business, data)?

## 2. Code Quality Metrics

### Naming Conventions
- Are names self-documenting and intention-revealing?
- Do boolean variables use is/has/can prefixes?
- Are magic numbers extracted to named constants?
- Are abbreviations avoided (except common ones)?

### Cyclomatic Complexity
- Are methods under 10 decision points?
- Can nested conditions be extracted to helper methods?
- Are switch statements candidates for polymorphism?

### Cohesion & Coupling
- High cohesion: Do related things stay together?
- Low coupling: Can modules change independently?
- Are there feature envy code smells?

## 3. Java Best Practices

### Null Safety
```java
// Bad: Prone to NullPointerException
public String getUsername() {
    return user.getName().toUpperCase();
}

// Good: Defensive with Optional
public Optional<String> getUsername() {
    return Optional.ofNullable(user)
        .map(User::getName)
        .map(String::toUpperCase);
}
```

### Exception Handling
```java
// Bad: Swallowing exceptions
try {
    processOrder(order);
} catch (Exception e) {
    log.error("Error processing");
}

// Good: Proper context and propagation
try {
    processOrder(order);
} catch (PaymentException e) {
    log.error("Payment failed for order {}: {}", order.getId(), e.getMessage(), e);
    throw new OrderProcessingException("Failed to process order: " + order.getId(), e);
}
```

### Resource Management
```java
// Bad: Manual cleanup
InputStream input = new FileInputStream("data.txt");
try {
    // process
} finally {
    input.close();
}

// Good: Try-with-resources
try (InputStream input = new FileInputStream("data.txt")) {
    // process automatically closed
}
```

## 4. Performance Considerations

### Algorithmic Complexity
- What is the Big O notation for critical methods?
- Are there nested loops that could be optimized?
- Can data structures be improved (List -> Set, sequential -> indexed)?

### Database Access Patterns
```java
// Bad: N+1 Problem
List<Order> orders = orderRepository.findAll();
for (Order order : orders) {
    List<Item> items = itemRepository.findByOrderId(order.getId()); // N queries
}

// Good: Eager fetch or batch load
@Query("SELECT o FROM Order o LEFT JOIN FETCH o.items")
List<Order> findAllWithItems();
```

### Collection Operations
```java
// Bad: Multiple iterations
list.stream().filter(x -> x > 0).collect(toList())
    .stream().map(x -> x * 2).collect(toList());

// Good: Single pass
list.stream()
    .filter(x -> x > 0)
    .map(x -> x * 2)
    .collect(toList());
```

## 5. Testing Concerns

### Testability Issues
- Are dependencies hard-coded making testing difficult?
- Are methods too large to test effectively?
- Is business logic mixed with infrastructure?
- Can components be tested in isolation?

### Coverage Gaps
- Are edge cases tested (null, empty, boundary)?
- Are error paths tested?
- Are integration points verified?

### Test Smells
- Are tests brittle and break on refactoring?
- Do tests have excessive setup (too many mocks)?
- Are assertions clear and meaningful?

## 6. Security Analysis

### Input Validation
```java
// Bad: SQL Injection risk
String sql = "SELECT * FROM users WHERE id = " + userId;

// Good: Parameterized query
@Query("SELECT u FROM User u WHERE u.id = :userId")
User findById(@Param("userId") Long userId);
```

### Authentication & Authorization
- Are endpoints properly secured?
- Is authentication checked before authorization?
- Are sensitive operations audited?

### Data Exposure
- Are passwords/secrets properly encrypted?
- Is sensitive data logged or exposed in errors?
- Are API responses filtering internal data?

## 7. Spring Boot Specific

### Configuration Management
```java
// Bad: Hard-coded values
private static final String API_URL = "https://prod-api.com";

// Good: Externalized configuration
@Value("${api.url}")
private String apiUrl;
```

### Transaction Management
```java
// Bad: Missing transaction boundary
public void processOrder(Order order) {
    orderRepository.save(order);
    inventoryService.reduceStock(order.getItems()); // Different transaction
}

// Good: Single transaction
@Transactional
public void processOrder(Order order) {
    orderRepository.save(order);
    inventoryService.reduceStock(order.getItems());
}
```

### Bean Scope Issues
- Are stateful beans properly scoped?
- Are prototype beans used where needed?
- Is singleton scope appropriate for the use case?

## Output Format

Provide analysis in this structured format:

### Current Code Assessment
- **Complexity Score**: Method/class complexity metrics
- **Code Smells Detected**: List of anti-patterns found
- **Dependencies**: External and internal coupling analysis

### Strengths
- What is done well in this code
- Good patterns and practices observed
- Areas that demonstrate solid engineering

### Critical Issues (Priority 1)
For each issue:
- **Problem**: Clear description with line references
- **Impact**: Why this matters (performance, security, maintainability)
- **Solution**: Code example showing the fix
- **Effort**: Estimated complexity (Low/Medium/High)

### Improvements (Priority 2)
- Refactoring opportunities
- Code quality enhancements
- Performance optimizations

### Minor Issues (Priority 3)
- Style inconsistencies
- Documentation gaps
- Naming improvements

### Testing Recommendations
- **Unit Tests**: What should be unit tested
- **Integration Tests**: What needs integration coverage
- **Test Cases**: Specific scenarios to verify

### Refactoring Roadmap
1. Quick wins (low effort, high impact)
2. Medium-term improvements
3. Long-term architectural changes

### Overall Assessment
- **Maintainability**: 1-10 score with justification
- **Production Readiness**: Concerns and prerequisites
- **Technical Debt**: Estimated effort to address issues
- **Confidence Level**: How thorough is this analysis

## Common Code Smells to Check

1. **Long Method**: Method > 20 lines, should be decomposed
2. **Large Class**: Class > 300 lines, likely violates SRP
3. **Primitive Obsession**: Using primitives instead of domain objects
4. **Feature Envy**: Method uses another class's data more than its own
5. **Data Clumps**: Same group of parameters passed together
6. **Shotgun Surgery**: Single change requires many class modifications
7. **Divergent Change**: Class changes for multiple different reasons
8. **Comments**: Excessive comments often indicate unclear code

## Analysis Principles

1. **Be Specific**: Reference actual line numbers and method names
2. **Show Examples**: Provide before/after code snippets
3. **Prioritize**: Focus on high-impact issues first
4. **Be Pragmatic**: Balance ideal vs practical solutions
5. **Consider Context**: Production constraints, team experience, timeline
6. **Measure Impact**: Estimate performance, security, or maintainability gains
