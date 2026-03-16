---
name: clean-architecture
description: Clean Architecture design guide for Spring Boot. Use when reviewing code architecture, designing solutions, discussing layer separation, dependency rules, or project structure. Applies Uncle Bob's Clean Architecture principles.
user-invocable: false
allowed-tools: Read, Grep, Glob
model: sonnet
---

# Clean Architecture for Spring Boot

IMPORTANT: All output must be in Traditional Chinese.

## Core Principle: The Dependency Rule

**Dependencies point inward only.** Inner layers know nothing about outer layers.

```
┌─────────────────────────────────────────────┐
│              Presentation                    │  ← Controllers, DTOs
│   ┌─────────────────────────────────────┐   │
│   │          Infrastructure              │   │  ← Repositories Impl, External APIs
│   │   ┌─────────────────────────────┐   │   │
│   │   │        Application           │   │   │  ← Use Cases, Ports
│   │   │   ┌─────────────────────┐   │   │   │
│   │   │   │      Domain          │   │   │   │  ← Entities, Value Objects
│   │   │   └─────────────────────┘   │   │   │
│   │   └─────────────────────────────┘   │   │
│   └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
```

---

## Layer Responsibilities

### 1. Domain Layer (Core)

The heart of the application. **No framework dependencies.**

```java
// Entity - business identity
public class Order {
    private OrderId id;
    private CustomerId customerId;
    private Money totalAmount;
    private OrderStatus status;

    public void confirm() {
        if (this.status != OrderStatus.PENDING) {
            throw new IllegalOrderStateException("Only pending orders can be confirmed");
        }
        this.status = OrderStatus.CONFIRMED;
    }
}

// Value Object - immutable, equality by value
public record Money(BigDecimal amount, Currency currency) {
    public Money {
        if (amount.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Amount cannot be negative");
        }
    }

    public Money add(Money other) {
        validateSameCurrency(other);
        return new Money(this.amount.add(other.amount), this.currency);
    }
}
```

### 2. Application Layer

Orchestrates use cases. Defines **Ports** (interfaces).

```java
// Input Port - what the application can do
public interface CreateOrderUseCase {
    OrderId execute(CreateOrderCommand command);
}

// Output Port - what the application needs
public interface OrderRepository {
    void save(Order order);
    Optional<Order> findById(OrderId id);
}

// Use Case implementation
@Service
@Transactional
public class CreateOrderService implements CreateOrderUseCase {
    private final OrderRepository orderRepository;
    private final CustomerRepository customerRepository;

    @Override
    public OrderId execute(CreateOrderCommand command) {
        Customer customer = customerRepository.findById(command.customerId())
            .orElseThrow(() -> new CustomerNotFoundException(command.customerId()));

        Order order = Order.create(customer, command.items());
        orderRepository.save(order);

        return order.getId();
    }
}
```

### 3. Infrastructure Layer

Implements ports. Contains framework-specific code.

```java
// Repository implementation (Adapter)
@Repository
public class JpaOrderRepository implements OrderRepository {
    private final OrderJpaRepository jpaRepository;
    private final OrderMapper mapper;

    @Override
    public void save(Order order) {
        OrderEntity entity = mapper.toEntity(order);
        jpaRepository.save(entity);
    }

    @Override
    public Optional<Order> findById(OrderId id) {
        return jpaRepository.findById(id.value())
            .map(mapper::toDomain);
    }
}
```

### 4. Presentation Layer

Handles HTTP requests. Maps between DTOs and domain.

```java
@RestController
@RequestMapping("/api/orders")
public class OrderController {
    private final CreateOrderUseCase createOrderUseCase;

    @PostMapping
    public ResponseEntity<OrderResponse> createOrder(@Valid @RequestBody CreateOrderRequest request) {
        CreateOrderCommand command = request.toCommand();
        OrderId orderId = createOrderUseCase.execute(command);
        return ResponseEntity.created(URI.create("/api/orders/" + orderId.value()))
            .body(new OrderResponse(orderId.value()));
    }
}
```

---

## Spring Boot Project Structure

```
src/main/java/com/example/order/
├── domain/
│   ├── model/
│   │   ├── Order.java
│   │   ├── OrderId.java
│   │   ├── OrderStatus.java
│   │   └── Money.java
│   ├── service/
│   │   └── OrderDomainService.java
│   └── exception/
│       └── IllegalOrderStateException.java
├── application/
│   ├── port/
│   │   ├── in/
│   │   │   └── CreateOrderUseCase.java
│   │   └── out/
│   │       └── OrderRepository.java
│   ├── service/
│   │   └── CreateOrderService.java
│   └── dto/
│       └── CreateOrderCommand.java
├── infrastructure/
│   ├── persistence/
│   │   ├── entity/
│   │   │   └── OrderEntity.java
│   │   ├── repository/
│   │   │   ├── OrderJpaRepository.java
│   │   │   └── JpaOrderRepository.java
│   │   └── mapper/
│   │       └── OrderMapper.java
│   └── config/
│       └── PersistenceConfig.java
└── presentation/
    ├── controller/
    │   └── OrderController.java
    ├── request/
    │   └── CreateOrderRequest.java
    └── response/
        └── OrderResponse.java
```

---

## Code Review Checklist

| Check | Correct | Violation |
|-------|---------|-----------|
| Domain has no Spring annotations | `public class Order` | `@Entity public class Order` |
| Controller has no business logic | Delegates to UseCase | Contains validation/calculation |
| UseCase depends on ports only | `OrderRepository` (interface) | `JpaOrderRepository` (impl) |
| DTOs don't leak to domain | Maps to Command/Entity | Passes DTO to UseCase |
| Entities have behavior | `order.confirm()` | Anemic model with only getters |

---

## Common Anti-Patterns

### 1. Framework Coupling in Domain

```java
// BAD - Domain depends on JPA
@Entity
public class Order {
    @Id @GeneratedValue
    private Long id;
}

// GOOD - Domain is pure
public class Order {
    private OrderId id;
}
// Separate JPA entity in infrastructure
```

### 2. Fat Controllers

```java
// BAD - Business logic in controller
@PostMapping
public Order createOrder(@RequestBody Request req) {
    if (req.getItems().isEmpty()) throw new BadRequestException();
    Order order = new Order();
    order.setCustomerId(req.getCustomerId());
    order.setTotal(calculateTotal(req.getItems())); // Business logic!
    return orderRepository.save(order);
}

// GOOD - Delegate to use case
@PostMapping
public OrderResponse createOrder(@RequestBody CreateOrderRequest req) {
    OrderId id = createOrderUseCase.execute(req.toCommand());
    return new OrderResponse(id);
}
```

### 3. Anemic Domain Model

```java
// BAD - No behavior, just data holder
public class Order {
    private OrderStatus status;
    public void setStatus(OrderStatus s) { this.status = s; }
}
// Service does all the work
orderService.confirmOrder(order);

// GOOD - Encapsulated behavior
public class Order {
    public void confirm() {
        validateCanConfirm();
        this.status = OrderStatus.CONFIRMED;
    }
}
```

---

## When to Apply

- New feature development requiring clear boundaries
- Refactoring legacy code with tangled dependencies
- Code review for architectural compliance
- Designing microservice boundaries

## Additional Resources

For detailed guidance:
- **references/layer-dependencies.md** - Dependency rules and violation examples
- **references/spring-boot-implementation.md** - Complete project templates
- **references/testing-strategy.md** - Testing each layer
