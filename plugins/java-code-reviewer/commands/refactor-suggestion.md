# Refactor Suggestion

Suggest safe, pragmatic, and value-driven refactoring improvements. Focus on refactoring that improves maintainability, readability, and testability without breaking existing functionality.

## Refactoring Philosophy

**Key Principles**:
1. **Safety First**: Every refactoring must preserve existing behavior
2. **Incremental Changes**: Small, testable steps rather than big rewrites
3. **Measurable Value**: Each refactoring should have clear benefits
4. **Context Aware**: Consider team experience, timeline, and production constraints

**When to Refactor**:
- Code is difficult to understand or modify
- Adding new features is increasingly difficult
- Code duplication is causing maintenance issues
- Tests are hard to write or brittle

**When NOT to Refactor**:
- Just before a critical release
- Code is rarely modified
- Team lacks test coverage
- Cost > benefit (legacy code that works and won't change)

## Common Refactoring Patterns

### 1. Extract Method

**When**: Method is too long or does multiple things

**Before**:
```java
public void processOrder(Order order) {
    // Validate order
    if (order == null) throw new IllegalArgumentException("Order cannot be null");
    if (order.getItems() == null || order.getItems().isEmpty()) {
        throw new IllegalArgumentException("Order must have items");
    }

    // Calculate total
    double total = 0;
    for (OrderItem item : order.getItems()) {
        total += item.getPrice() * item.getQuantity();
    }
    order.setTotal(total);

    // Apply discount
    if (order.getCustomer().isPremium()) {
        total = total * 0.9;  // 10% discount
    }
    order.setFinalTotal(total);

    // Save to database
    orderRepository.save(order);

    // Send notification
    String message = "Order #" + order.getId() + " total: $" + total;
    emailService.send(order.getCustomer().getEmail(), "Order Confirmation", message);
}
```

**After**:
```java
public void processOrder(Order order) {
    validateOrder(order);
    calculateTotal(order);
    applyDiscount(order);
    saveOrder(order);
    sendConfirmation(order);
}

private void validateOrder(Order order) {
    if (order == null) throw new IllegalArgumentException("Order cannot be null");
    if (order.getItems() == null || order.getItems().isEmpty()) {
        throw new IllegalArgumentException("Order must have items");
    }
}

private void calculateTotal(Order order) {
    double total = order.getItems().stream()
        .mapToDouble(item -> item.getPrice() * item.getQuantity())
        .sum();
    order.setTotal(total);
}

private void applyDiscount(Order order) {
    double total = order.getTotal();
    if (order.getCustomer().isPremium()) {
        total = total * 0.9;
    }
    order.setFinalTotal(total);
}

private void saveOrder(Order order) {
    orderRepository.save(order);
}

private void sendConfirmation(Order order) {
    String message = String.format("Order #%d total: $%.2f",
        order.getId(), order.getFinalTotal());
    emailService.send(order.getCustomer().getEmail(), "Order Confirmation", message);
}
```

**Benefits**:
- Each method has single responsibility
- Easier to test individual operations
- Clearer intent and flow
- Reusable components

### 2. Extract Variable

**When**: Complex expressions are hard to understand

**Before**:
```java
if (order.getCustomer().getOrderHistory().size() > 10 &&
    order.getCustomer().getTotalSpent() > 1000 &&
    order.getCustomer().getRegistrationDate().isBefore(LocalDate.now().minusYears(1))) {
    applyLoyaltyDiscount(order);
}
```

**After**:
```java
boolean isFrequentBuyer = order.getCustomer().getOrderHistory().size() > 10;
boolean isHighValueCustomer = order.getCustomer().getTotalSpent() > 1000;
boolean isLongTermCustomer = order.getCustomer().getRegistrationDate()
    .isBefore(LocalDate.now().minusYears(1));

boolean isLoyalCustomer = isFrequentBuyer && isHighValueCustomer && isLongTermCustomer;

if (isLoyalCustomer) {
    applyLoyaltyDiscount(order);
}
```

**Benefits**:
- Self-documenting code
- Easier to debug (can inspect each condition)
- Easier to test (can test conditions separately)

### 3. Replace Conditional with Polymorphism

**When**: Switch/if-else chains based on type or enum

**Before**:
```java
public double calculateShippingCost(Order order) {
    switch (order.getShippingMethod()) {
        case STANDARD:
            return order.getWeight() * 0.5;
        case EXPRESS:
            return order.getWeight() * 1.5 + 10;
        case OVERNIGHT:
            return order.getWeight() * 3.0 + 25;
        default:
            throw new IllegalArgumentException("Unknown shipping method");
    }
}
```

**After**:
```java
// Interface
public interface ShippingCalculator {
    double calculateCost(double weight);
}

// Implementations
public class StandardShipping implements ShippingCalculator {
    @Override
    public double calculateCost(double weight) {
        return weight * 0.5;
    }
}

public class ExpressShipping implements ShippingCalculator {
    @Override
    public double calculateCost(double weight) {
        return weight * 1.5 + 10;
    }
}

public class OvernightShipping implements ShippingCalculator {
    @Override
    public double calculateCost(double weight) {
        return weight * 3.0 + 25;
    }
}

// Usage
public double calculateShippingCost(Order order) {
    ShippingCalculator calculator = shippingCalculatorFactory.get(order.getShippingMethod());
    return calculator.calculateCost(order.getWeight());
}
```

**Benefits**:
- Open/Closed Principle (open for extension, closed for modification)
- Easy to add new shipping methods without modifying existing code
- Each strategy is testable independently

### 4. Introduce Parameter Object

**When**: Methods have too many parameters or same group of parameters appears repeatedly

**Before**:
```java
public Order createOrder(Long customerId, String customerName, String customerEmail,
                        List<OrderItem> items, String shippingAddress,
                        String shippingCity, String shippingZip,
                        String paymentMethod, String cardNumber) {
    // create order logic
}
```

**After**:
```java
public record CustomerInfo(Long id, String name, String email) {}
public record ShippingAddress(String street, String city, String zipCode) {}
public record PaymentInfo(String method, String cardNumber) {}

public Order createOrder(CustomerInfo customer,
                        List<OrderItem> items,
                        ShippingAddress shipping,
                        PaymentInfo payment) {
    // create order logic
}
```

**Benefits**:
- Clearer method signature
- Parameter objects can be reused
- Easier to add new fields to objects without changing method signatures
- Parameter validation can be in the object

### 5. Move Method / Extract Class

**When**: Class has multiple responsibilities or method uses another class's data more than its own

**Before**:
```java
public class Order {
    private Customer customer;
    private List<OrderItem> items;
    private double totalAmount;

    // Order methods
    public void addItem(OrderItem item) { ... }
    public void removeItem(OrderItem item) { ... }

    // Customer-related methods (Feature Envy!)
    public boolean isCustomerPremium() {
        return customer.getOrders().size() > 10;
    }

    public double getCustomerLifetimeValue() {
        return customer.getOrders().stream()
            .mapToDouble(Order::getTotalAmount)
            .sum();
    }

    public void sendCustomerWelcomeEmail() {
        if (customer.getOrders().size() == 1) {
            emailService.sendWelcome(customer.getEmail());
        }
    }
}
```

**After**:
```java
// Customer class owns its own logic
public class Customer {
    private List<Order> orders;
    private String email;

    public boolean isPremium() {
        return orders.size() > 10;
    }

    public double getLifetimeValue() {
        return orders.stream()
            .mapToDouble(Order::getTotalAmount)
            .sum();
    }

    public boolean isFirstOrder() {
        return orders.size() == 1;
    }
}

// Order class focuses on order logic
public class Order {
    private Customer customer;
    private List<OrderItem> items;
    private double totalAmount;

    public void addItem(OrderItem item) { ... }
    public void removeItem(OrderItem item) { ... }

    // Delegate to customer
    public boolean isCustomerPremium() {
        return customer.isPremium();
    }
}

// Service handles coordination
public class OrderService {
    public void completeOrder(Order order) {
        orderRepository.save(order);
        if (order.getCustomer().isFirstOrder()) {
            emailService.sendWelcome(order.getCustomer().getEmail());
        }
    }
}
```

**Benefits**:
- Each class has clear responsibility
- Customer logic is reusable across different contexts
- Easier to test customer logic independently

### 6. Replace Magic Numbers with Named Constants

**Before**:
```java
if (order.getTotal() > 1000) {
    discount = order.getTotal() * 0.1;
}

if (customer.getAge() < 18) {
    throw new IllegalArgumentException("Must be 18 or older");
}
```

**After**:
```java
private static final double BULK_ORDER_THRESHOLD = 1000.0;
private static final double BULK_ORDER_DISCOUNT_RATE = 0.1;
private static final int MINIMUM_AGE = 18;

if (order.getTotal() > BULK_ORDER_THRESHOLD) {
    discount = order.getTotal() * BULK_ORDER_DISCOUNT_RATE;
}

if (customer.getAge() < MINIMUM_AGE) {
    throw new IllegalArgumentException("Must be " + MINIMUM_AGE + " or older");
}
```

**Benefits**:
- Self-documenting code
- Single point to update values
- Type-safe (can't accidentally use 0.01 instead of 0.1)

### 7. Replace Nested Conditionals with Guard Clauses

**Before**:
```java
public double calculateDiscount(Customer customer, Order order) {
    if (customer != null) {
        if (order != null) {
            if (order.getTotal() > 100) {
                if (customer.isPremium()) {
                    return order.getTotal() * 0.2;
                } else {
                    return order.getTotal() * 0.1;
                }
            } else {
                return 0;
            }
        } else {
            throw new IllegalArgumentException("Order cannot be null");
        }
    } else {
        throw new IllegalArgumentException("Customer cannot be null");
    }
}
```

**After**:
```java
public double calculateDiscount(Customer customer, Order order) {
    if (customer == null) {
        throw new IllegalArgumentException("Customer cannot be null");
    }
    if (order == null) {
        throw new IllegalArgumentException("Order cannot be null");
    }
    if (order.getTotal() <= 100) {
        return 0;
    }

    return customer.isPremium()
        ? order.getTotal() * 0.2
        : order.getTotal() * 0.1;
}
```

**Benefits**:
- Easier to read (linear flow, not nested)
- Fail fast (errors handled early)
- Happy path is clear

### 8. Introduce Null Object Pattern

**Before**:
```java
public void processOrder(Order order) {
    Customer customer = order.getCustomer();

    if (customer != null) {
        String email = customer.getEmail();
        if (email != null) {
            sendConfirmation(email);
        }

        if (customer.getAddress() != null) {
            calculateShipping(customer.getAddress());
        }
    }
}
```

**After**:
```java
// Null Object
public class NullCustomer extends Customer {
    @Override
    public String getEmail() {
        return "";
    }

    @Override
    public Address getAddress() {
        return new NullAddress();
    }

    @Override
    public boolean isNull() {
        return true;
    }
}

// Usage
public void processOrder(Order order) {
    Customer customer = order.getCustomerOrNull();  // Returns NullCustomer if null

    if (!customer.isNull()) {
        sendConfirmation(customer.getEmail());
        calculateShipping(customer.getAddress());
    }
}
```

**Benefits**:
- Eliminates null checks
- Polymorphic handling of null cases
- Cleaner code

## Refactoring Safety Checklist

Before refactoring:
- [ ] **Tests exist**: Have automated tests for the code being refactored
- [ ] **Tests pass**: All current tests are green
- [ ] **Understand behavior**: Know exactly what the code does
- [ ] **Small steps**: Plan incremental changes, not big rewrites
- [ ] **Version control**: Commit before starting

During refactoring:
- [ ] **One change at a time**: Don't mix refactoring with new features
- [ ] **Run tests frequently**: After each small change
- [ ] **Preserve behavior**: Don't change what the code does
- [ ] **Compile continuously**: Fix compilation errors immediately

After refactoring:
- [ ] **All tests pass**: No regressions introduced
- [ ] **Code review**: Have someone review the changes
- [ ] **Performance check**: Ensure no performance degradation
- [ ] **Documentation updated**: Update comments and docs if needed

## Common Refactoring Mistakes to Avoid

### 1. Refactoring Without Tests
```
❌ BAD: Refactor complex business logic without test coverage
✅ GOOD: Write tests first, then refactor (or stop if untestable)
```

### 2. Mixing Refactoring with New Features
```
❌ BAD: Commit message: "Refactor UserService and add password reset feature"
✅ GOOD: Separate commits: 1) Refactor UserService, 2) Add password reset
```

### 3. Over-Engineering
```
❌ BAD: Extract 20 interfaces for a simple CRUD service "just in case"
✅ GOOD: Refactor when you feel pain, not prophylactically
```

### 4. Breaking Encapsulation
```
❌ BAD: Make all methods public to test them
✅ GOOD: Test through public API or refactor to make testable
```

### 5. Premature Abstraction
```
❌ BAD: Create abstraction after seeing duplication once
✅ GOOD: Follow Rule of Three - extract after third duplication
```

## Output Format

For each refactoring suggestion:

### 1. Current Issues
- **Problem**: What makes the code difficult to maintain
- **Evidence**: Specific examples (line numbers, method names)
- **Impact**: How this affects development (time, bugs, testing)

### 2. Refactoring Recommendation
- **Pattern**: Which refactoring pattern to apply
- **Priority**: High / Medium / Low (with justification)
- **Effort**: Small (< 1 hour) / Medium (1-4 hours) / Large (> 1 day)

### 3. Step-by-Step Refactoring Plan
```
1. Write/verify tests for current behavior
2. Extract validation logic to validateOrder() method
3. Run tests - should still pass
4. Extract calculation logic to calculateTotal() method
5. Run tests - should still pass
6. Extract discount logic to applyDiscount() method
7. Run tests - should still pass
8. Final cleanup: remove commented code, update docs
```

### 4. Before/After Code Comparison
Show complete, working code examples for both states.

### 5. Benefits & Trade-offs

**Benefits**:
- Improved readability (methods have clear names)
- Better testability (can test each method independently)
- Easier to modify (each method is focused)

**Trade-offs**:
- More methods (complexity moves from single method to class structure)
- Possible performance impact (additional method calls - usually negligible)

### 6. Risk Assessment
- **Low Risk**: Well-tested code, simple refactoring
- **Medium Risk**: Some test coverage, complex refactoring
- **High Risk**: No tests, core business logic, production-critical

### 7. Testing Strategy
```java
// Test original behavior
@Test
public void shouldProcessValidOrder() {
    Order order = createValidOrder();
    service.processOrder(order);

    verify(orderRepository).save(order);
    verify(emailService).send(any(), any(), any());
    assertThat(order.getTotal()).isGreaterThan(0);
}

// After refactoring, same test should still pass
// Add new tests for extracted methods if needed
```

## Refactoring Priorities

### High Priority (Do Now)
- **Security issues**: SQL injection, hardcoded credentials
- **Performance problems**: N+1 queries, unnecessary loops
- **Blocking new features**: Code is so tangled that adding features is very difficult
- **High duplication**: Same code copied 5+ times

### Medium Priority (Plan Soon)
- **Testing difficulties**: Code is hard to test
- **Moderate duplication**: Same code copied 3-4 times
- **Poor naming**: Variables/methods don't reveal intent
- **Long methods**: Methods > 30 lines doing multiple things

### Low Priority (Technical Debt)
- **Style inconsistencies**: Formatting, minor naming issues
- **Over-commenting**: Obvious comments that could be removed with better naming
- **Unused code**: Dead code that should be removed
- **Minor optimizations**: Micro-optimizations with no measurable impact

## Refactoring Tools & IDE Support

**IntelliJ IDEA**:
- Extract Method: `Ctrl+Alt+M` / `Cmd+Alt+M`
- Extract Variable: `Ctrl+Alt+V` / `Cmd+Alt+V`
- Rename: `Shift+F6`
- Move: `F6`
- Safe Delete: `Alt+Delete` / `Cmd+Delete`

**Always use IDE refactoring tools** - they handle:
- All references automatically
- Import statements
- Compile-time safety checks
- Preview before applying

## Summary

Good refactoring:
1. **Has a clear goal**: Improving specific aspect (readability, testability, performance)
2. **Is safe**: Preserves behavior, backed by tests
3. **Is incremental**: Small steps, not big rewrites
4. **Adds value**: Worth the time and risk
5. **Is timely**: Done when code is being modified, not randomly

Remember: **Refactoring is not rewriting**. If you're changing behavior or adding features, it's not refactoring - it's development.
