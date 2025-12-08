---
description: 審查系統架構設計
allowed-tools: Read, Grep, Glob
model: sonnet
---

# Review Architecture

Comprehensive architecture review focusing on production readiness, scalability, maintainability, and business alignment. Provide practical, actionable recommendations based on real-world constraints.

## Architecture Review Framework

### 1. Business Requirements Alignment

**Key Questions**:
- Does the architecture solve the actual business problem?
- Are functional requirements met?
- Are non-functional requirements (performance, availability, security) addressed?
- Can the system handle expected growth in the next 1-3 years?

**Red Flags**:
- Over-engineered solution for simple requirements
- Architecture designed for hypothetical future needs
- Missing critical business requirements
- No clear success metrics

**Example Evaluation**:
```
Requirement: Process 1000 orders/hour
Current Design: Microservices with Kafka, K8s, distributed caching
Assessment: OVER-ENGINEERED
Recommendation: Monolithic Spring Boot app with PostgreSQL can handle 10K+ orders/hour
              Start simple, decompose later if needed
```

### 2. Scalability & Performance

**Evaluation Checklist**:
- [ ] **Horizontal Scalability**: Can we add more instances to handle load?
- [ ] **Database Scalability**: Read replicas? Sharding strategy?
- [ ] **Caching Strategy**: What's cached? Cache invalidation plan?
- [ ] **Async Processing**: Long-running tasks moved to background?
- [ ] **Load Testing**: Has the system been tested under expected load?

**Common Anti-Patterns**:
```java
// Bad: Synchronous external API calls in request path
@GetMapping("/orders/{id}")
public Order getOrder(@PathVariable Long id) {
    Order order = orderService.findById(id);
    order.setShippingStatus(shippingAPI.getStatus(order.getId()));  // Blocks request!
    return order;
}

// Good: Async processing or cached data
@GetMapping("/orders/{id}")
public Order getOrder(@PathVariable Long id) {
    return orderService.findById(id);  // shipping status pre-fetched/cached
}
```

**Capacity Planning**:
```
Current Load: 500 req/sec
Expected Growth: 2x per year
Time Horizon: 2 years

Calculation:
Year 1: 1000 req/sec
Year 2: 2000 req/sec

Required Capacity: 2000 req/sec
Recommended Provisioning: 3000 req/sec (50% headroom)
```

### 3. Reliability & Resilience

**The Four Pillars**:

1. **Fault Tolerance**: System continues working despite component failures
   ```java
   // Circuit Breaker Pattern
   @CircuitBreaker(name = "paymentService", fallbackMethod = "paymentFallback")
   public PaymentResult processPayment(Payment payment) {
       return paymentService.charge(payment);
   }

   public PaymentResult paymentFallback(Payment payment, Exception ex) {
       // Degrade gracefully: queue for retry, use backup payment processor
       return PaymentResult.queued(payment.getId());
   }
   ```

2. **Graceful Degradation**: Core functionality works even if auxiliary features fail
   ```
   Example: E-commerce checkout
   - Payment processing: CRITICAL (must work)
   - Recommendation engine: NON-CRITICAL (can fail without blocking checkout)
   - Email notification: NON-CRITICAL (retry asynchronously)
   ```

3. **Retry Logic**: Transient failures are retried with backoff
   ```java
   @Retryable(
       value = {TransientException.class},
       maxAttempts = 3,
       backoff = @Backoff(delay = 1000, multiplier = 2)
   )
   public void updateInventory(Long productId, int quantity) {
       inventoryService.update(productId, quantity);
   }
   ```

4. **Monitoring & Alerting**: Know when things go wrong
   ```
   Required Metrics:
   - Error rate (% of failed requests)
   - Latency (p50, p95, p99)
   - Saturation (CPU, memory, disk, connection pools)
   - Traffic (requests/second)
   ```

**Reliability Checklist**:
- [ ] Single points of failure identified and mitigated
- [ ] Database failover tested
- [ ] Dependency failures handled gracefully
- [ ] Timeouts configured for all external calls
- [ ] Retries implemented for transient failures
- [ ] Circuit breakers for unreliable dependencies

### 4. Security Architecture

**Security Layers**:

1. **Authentication & Authorization**
   ```java
   // Good: Role-based access control
   @PreAuthorize("hasRole('ADMIN') or @orderSecurity.isOwner(#orderId, principal)")
   @PutMapping("/orders/{orderId}")
   public Order updateOrder(@PathVariable Long orderId, @RequestBody OrderUpdate update) {
       return orderService.update(orderId, update);
   }
   ```

2. **Data Protection**
   - Sensitive data encrypted at rest and in transit
   - PII (Personally Identifiable Information) masked in logs
   - Secrets stored in secure vault (not in code/config)

3. **Input Validation**
   ```java
   // Bad: Vulnerable to injection
   String sql = "SELECT * FROM users WHERE email = '" + email + "'";

   // Good: Parameterized query
   @Query("SELECT u FROM User u WHERE u.email = :email")
   User findByEmail(@Param("email") String email);
   ```

4. **API Security**
   - Rate limiting to prevent abuse
   - CORS configuration for web clients
   - HTTPS enforced for all endpoints
   - OWASP Top 10 vulnerabilities addressed

**Security Checklist**:
- [ ] Authentication mechanism secure (JWT, OAuth2, etc.)
- [ ] Authorization enforced at service layer (not just UI)
- [ ] Sensitive data encrypted (passwords, credit cards, PII)
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (input sanitization)
- [ ] CSRF protection for state-changing operations
- [ ] Security audit trail (who did what, when)

### 5. Data Architecture

**Database Design Evaluation**:

1. **Schema Design**
   - Normalization appropriate for use case?
   - Indexes on frequently queried columns?
   - Partitioning strategy for large tables?

2. **Data Consistency**
   ```java
   // Transaction boundaries clear?
   @Transactional
   public void transferFunds(Long fromAccount, Long toAccount, BigDecimal amount) {
       accountRepository.debit(fromAccount, amount);   // Both must succeed
       accountRepository.credit(toAccount, amount);     // or both must fail
   }
   ```

3. **Data Migration Strategy**
   - Schema evolution plan (Flyway, Liquibase)?
   - Zero-downtime deployment support?
   - Data backup and recovery tested?

4. **Data Retention & Archival**
   - Old data archived or purged?
   - Compliance requirements met (GDPR, etc.)?

**Data Architecture Checklist**:
- [ ] Database type appropriate (RDBMS, NoSQL, time-series)?
- [ ] Read/write patterns analyzed and optimized
- [ ] Backup strategy defined and tested
- [ ] Data migration scripts versioned and automated
- [ ] Data consistency guarantees clear (ACID, eventual consistency)
- [ ] Data volume growth plan

### 6. Integration Design

**External Integration Patterns**:

1. **Synchronous vs Asynchronous**
   ```
   Synchronous (REST, gRPC):
   - Use when: Immediate response needed, low latency, simple request/response
   - Risk: Tight coupling, cascade failures, latency amplification

   Asynchronous (Message Queue, Events):
   - Use when: Fire-and-forget, high throughput, decoupling
   - Risk: Complexity, eventual consistency, debugging difficulty
   ```

2. **API Design Quality**
   ```
   Good API:
   - Versioned (/api/v1/orders)
   - RESTful conventions followed
   - Pagination for list endpoints
   - Consistent error format
   - Documentation (OpenAPI/Swagger)

   Bad API:
   - Breaking changes without versioning
   - Inconsistent naming (getOrder, fetch_user, retrieveProduct)
   - No pagination (returns all 1M records)
   - Generic error messages ("Error occurred")
   ```

3. **Third-Party Dependency Management**
   - Vendor lock-in assessed?
   - Fallback plan if service is down?
   - Cost implications understood?

**Integration Checklist**:
- [ ] Integration patterns appropriate (sync vs async)
- [ ] API contracts documented and versioned
- [ ] Timeout and retry policies configured
- [ ] Circuit breakers for external dependencies
- [ ] Third-party API rate limits respected
- [ ] Error handling comprehensive

### 7. Operational Concerns

**Production Readiness**:

1. **Observability**
   ```
   Three Pillars:
   - Logs: Structured JSON logs, centralized (ELK, Splunk)
   - Metrics: Time-series data (Prometheus, Datadog)
   - Traces: Distributed tracing (Jaeger, Zipkin)
   ```

2. **Deployment**
   - CI/CD pipeline in place?
   - Blue-green or canary deployment?
   - Rollback procedure tested?
   - Database migration automation?

3. **Configuration Management**
   ```java
   // Bad: Hard-coded config
   private static final String API_URL = "https://prod.api.com";

   // Good: Externalized config
   @Value("${api.url}")
   private String apiUrl;
   ```

4. **Cost Optimization**
   - Infrastructure costs monitored?
   - Auto-scaling configured?
   - Resource usage optimized?

**Operational Checklist**:
- [ ] Logging comprehensive and searchable
- [ ] Metrics and alerts configured
- [ ] Distributed tracing for microservices
- [ ] Health check endpoints implemented
- [ ] Deployment automation (CI/CD)
- [ ] Infrastructure as code (Terraform, CloudFormation)
- [ ] Disaster recovery plan documented and tested

### 8. Team & Skills Considerations

**Team Readiness**:
- Does team have skills to maintain this architecture?
- Is architecture complexity justified by team size and experience?
- Training plan for new technologies?
- On-call rotation and runbook documentation?

**Example**:
```
Proposed: Kubernetes + Kafka + Cassandra + gRPC microservices
Team: 3 developers, 1 junior
Assessment: TOO COMPLEX for team size
Recommendation: Start with Spring Boot monolith + PostgreSQL + RabbitMQ
              Migrate to microservices when team grows to 8-10 developers
```

## Architecture Review Output Format

### Executive Summary
```
System: Order Management System
Review Date: 2024-01-15
Reviewer: Senior Architect

Overall Assessment: MODERATE CONCERNS
- Current system can handle near-term growth (next 12 months)
- Several architectural risks require attention within 6 months
- Security improvements needed before production launch
```

### Strengths
- Well-defined domain models with clear boundaries
- Comprehensive test coverage (85% line coverage)
- Effective use of caching reduces database load
- Clean REST API design with proper versioning

### Critical Risks (Address Immediately)
1. **No Database Failover** (Risk: System Downtime)
   - Impact: Single database failure causes complete outage
   - Solution: Configure read replicas and automatic failover
   - Effort: 2 weeks
   - Priority: P0

2. **Hardcoded Secrets** (Risk: Security Breach)
   - Impact: API keys and passwords in source code
   - Solution: Migrate to AWS Secrets Manager / HashiCorp Vault
   - Effort: 1 week
   - Priority: P0

### Medium-Term Concerns (Address in 3-6 Months)
1. **Monolithic Architecture Reaching Limits**
   - Current: Single Spring Boot application
   - Problem: Deployment coupling, long build times (15 minutes)
   - Solution: Extract payment processing to separate service
   - Effort: 1 month
   - Priority: P1

2. **No Distributed Tracing**
   - Problem: Difficult to debug cross-service calls
   - Solution: Implement Jaeger/Zipkin
   - Effort: 2 weeks
   - Priority: P1

### Recommendations
1. Implement database replication (High Priority)
2. Move secrets to secure vault (High Priority)
3. Add distributed tracing (Medium Priority)
4. Create disaster recovery runbook (Medium Priority)
5. Implement API rate limiting (Low Priority)

### Scalability Assessment
```
Current Capacity: 500 req/sec
Expected Load: 1000 req/sec (peak)
Bottleneck: Database connection pool (max 20 connections)

Short-term fix: Increase pool size to 50
Long-term fix: Implement read replicas for read-heavy queries
```

### Unanswered Questions
1. What is the RTO (Recovery Time Objective) for database failure?
2. Are there compliance requirements (PCI-DSS, HIPAA, GDPR)?
3. What is the budget for infrastructure?
4. What is the expected data retention period?

### Timeline & Priorities

**Month 1** (Critical):
- Database failover setup
- Secrets management migration
- Security audit

**Month 2-3** (Important):
- Distributed tracing implementation
- Performance optimization
- Load testing

**Month 4-6** (Nice to Have):
- Microservices extraction
- Advanced monitoring
- Cost optimization

## Architecture Decision Records (ADRs)

Document key architectural decisions:
```markdown
# ADR-001: Use PostgreSQL as primary database

## Status
Accepted

## Context
Need to choose database for order management system.
Requirements: ACID transactions, complex queries, 1000 req/sec.

## Decision
Use PostgreSQL

## Consequences
Positive:
- Mature, battle-tested
- Excellent transaction support
- Rich query capabilities

Negative:
- Scaling requires read replicas (vertical scaling has limits)
- More complex than NoSQL for simple key-value access

## Alternatives Considered
- MongoDB: Good for flexibility, but weak transaction support
- MySQL: Similar to PostgreSQL, but less advanced features
```

## Common Architecture Smells

1. **Resume-Driven Development**: Using technologies because they're trendy
2. **Premature Optimization**: Microservices for 3-person team
3. **Not Invented Here**: Rebuilding what already exists
4. **Gold Plating**: Adding features "just in case"
5. **Analysis Paralysis**: Designing forever, never building

## Summary

Good architecture:
1. **Solves real problems** (not hypothetical ones)
2. **Fits the team** (skills, size, experience)
3. **Fits the timeline** (pragmatic, not perfect)
4. **Fits the budget** (cost-effective)
5. **Is evolvable** (can change as requirements change)

**Remember**: The best architecture is the simplest one that meets current requirements with room to grow.
