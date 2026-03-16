---
name: mysql-optimization
description: MySQL performance optimization guide for Spring Boot/JPA. Use when reviewing database code, discussing index design, query optimization, N+1 problems, JPA/Hibernate tuning, or analyzing EXPLAIN plans. Complements /optimize-query command.
user-invocable: false
allowed-tools: Read, Grep, Glob
model: sonnet
---

# MySQL Performance Optimization

IMPORTANT: All output must be in Traditional Chinese.

## Index Design Principles

### 1. Composite Index Column Order

**Rule: Equality first, Range last, ORDER BY in between**

```sql
-- Query pattern
SELECT * FROM orders
WHERE customer_id = ?      -- Equality
  AND status = ?           -- Equality
  AND created_at > ?       -- Range
ORDER BY total DESC;

-- Optimal index
CREATE INDEX idx_orders_customer_status_created_total
ON orders (customer_id, status, created_at, total);
--         ↑ equality   ↑ equality  ↑ range   ↑ for sorting
```

**Index stops working after range condition:**
```sql
-- This index: (a, b, c, d)
WHERE a = 1 AND b > 10 AND c = 5
--    ✓ uses a  ✓ uses b  ✗ c not used (after range)
```

### 2. Covering Index

**Include all columns in SELECT to avoid table lookup:**

```sql
-- Query
SELECT order_id, total, status FROM orders
WHERE customer_id = ? AND created_at > ?;

-- Covering index (includes all needed columns)
CREATE INDEX idx_covering
ON orders (customer_id, created_at, order_id, total, status);

-- EXPLAIN shows "Using index" = covering index used
```

### 3. Index Selectivity

**High selectivity = more distinct values = better index**

```sql
-- Check selectivity
SELECT
    COUNT(DISTINCT customer_id) / COUNT(*) AS customer_selectivity,
    COUNT(DISTINCT status) / COUNT(*) AS status_selectivity
FROM orders;

-- Result: customer_id = 0.85, status = 0.001
-- customer_id is better for leading column
```

---

## Query Optimization Patterns

### N+1 Problem

**The Problem:**
```java
// BAD - N+1 queries
List<Order> orders = orderRepository.findByCustomerId(customerId);
for (Order order : orders) {
    List<OrderItem> items = order.getItems();  // Lazy load = 1 query per order!
}
// Total: 1 + N queries
```

**Solutions:**

```java
// Solution 1: JOIN FETCH (JPQL)
@Query("SELECT o FROM Order o JOIN FETCH o.items WHERE o.customerId = :customerId")
List<Order> findByCustomerIdWithItems(@Param("customerId") String customerId);

// Solution 2: @EntityGraph
@EntityGraph(attributePaths = {"items", "items.product"})
List<Order> findByCustomerId(String customerId);

// Solution 3: Batch fetching (application.yml)
spring:
  jpa:
    properties:
      hibernate:
        default_batch_fetch_size: 100
```

### Pagination Optimization

**Problem: OFFSET becomes slow with large pages**

```sql
-- Slow for page 10000
SELECT * FROM orders ORDER BY id LIMIT 20 OFFSET 200000;
-- MySQL must scan 200,020 rows!
```

**Solution: Keyset Pagination**

```java
// Instead of page number, use last seen ID
@Query("SELECT o FROM Order o WHERE o.id > :lastId ORDER BY o.id LIMIT :size")
List<Order> findNextPage(@Param("lastId") Long lastId, @Param("size") int size);

// Usage
Long lastId = 0L;
List<Order> page;
do {
    page = repository.findNextPage(lastId, 20);
    process(page);
    lastId = page.isEmpty() ? lastId : page.get(page.size() - 1).getId();
} while (!page.isEmpty());
```

### COUNT Optimization

```sql
-- Slow: exact count
SELECT COUNT(*) FROM orders WHERE status = 'PENDING';

-- Fast: approximate count (for UI "1000+ results")
SELECT COUNT(*) FROM orders WHERE status = 'PENDING' LIMIT 1001;
-- If returns 1001, display "1000+"
```

### JOIN vs Subquery

```sql
-- Subquery (often slower)
SELECT * FROM orders
WHERE customer_id IN (SELECT id FROM customers WHERE region = 'ASIA');

-- JOIN (often faster, check EXPLAIN)
SELECT o.* FROM orders o
INNER JOIN customers c ON o.customer_id = c.id
WHERE c.region = 'ASIA';

-- EXISTS (good for checking existence)
SELECT * FROM customers c
WHERE EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.id);
```

---

## JPA/Hibernate Tuning

### Fetch Strategy

```java
// Default: LAZY for collections, EAGER for single
@Entity
public class Order {
    @ManyToOne(fetch = FetchType.LAZY)  // Single entity - consider LAZY
    private Customer customer;

    @OneToMany(fetch = FetchType.LAZY)   // Collection - always LAZY
    private List<OrderItem> items;
}
```

### Batch Operations

```yaml
# application.yml
spring:
  jpa:
    properties:
      hibernate:
        jdbc:
          batch_size: 50
          batch_versioned_data: true
        order_inserts: true
        order_updates: true
```

```java
// Batch insert
@Transactional
public void saveAll(List<Order> orders) {
    int batchSize = 50;
    for (int i = 0; i < orders.size(); i++) {
        entityManager.persist(orders.get(i));
        if (i % batchSize == 0) {
            entityManager.flush();
            entityManager.clear();
        }
    }
}
```

### Connection Pool (HikariCP)

```yaml
spring:
  datasource:
    hikari:
      maximum-pool-size: 10      # CPU cores * 2 + disk spindles
      minimum-idle: 5
      connection-timeout: 30000   # 30 seconds
      idle-timeout: 600000        # 10 minutes
      max-lifetime: 1800000       # 30 minutes
```

---

## EXPLAIN Analysis Quick Guide

```sql
EXPLAIN SELECT * FROM orders WHERE customer_id = ? AND status = ?;
```

| Column | Good | Bad |
|--------|------|-----|
| type | const, eq_ref, ref | ALL, index |
| rows | Low number | High number |
| Extra | Using index | Using filesort, Using temporary |

### Type Values (Best to Worst)

1. `const` - Single row (primary key lookup)
2. `eq_ref` - One row per join (unique index)
3. `ref` - Multiple rows (non-unique index)
4. `range` - Index range scan
5. `index` - Full index scan (better than ALL)
6. `ALL` - Full table scan (**Bad!**)

### Red Flags in Extra

- `Using filesort` - Sorting without index
- `Using temporary` - Creating temp table
- `Using where` with high rows - Filter after scan

---

## Code Review Checklist

| Issue | Detection | Solution |
|-------|-----------|----------|
| N+1 Query | Multiple SELECT in logs for one request | JOIN FETCH, @EntityGraph, batch_fetch_size |
| Full Table Scan | EXPLAIN type = ALL | Add appropriate index |
| Large OFFSET | LIMIT x OFFSET large_number | Keyset pagination |
| SELECT * | Fetching unused columns | Select only needed columns |
| Missing Index | Slow query log, EXPLAIN | Analyze query pattern, add index |
| Cartesian Join | Missing JOIN condition | Add proper ON clause |
| OR on different columns | Each OR branch = separate scan | UNION or redesign |

---

## Quick Wins

### 1. Enable Slow Query Log

```sql
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 1;  -- Log queries > 1 second
SET GLOBAL log_queries_not_using_indexes = 'ON';
```

### 2. Add Missing Indexes

```sql
-- Find missing indexes
SELECT * FROM sys.schema_unused_indexes;
SELECT * FROM sys.schema_redundant_indexes;

-- Find queries without indexes
SELECT * FROM sys.statements_with_full_table_scans
ORDER BY no_index_used_count DESC LIMIT 10;
```

### 3. Query Hints

```java
@QueryHints(@QueryHint(name = "org.hibernate.readOnly", value = "true"))
List<Order> findByStatus(OrderStatus status);
```

---

## Schema Design

### Normalization vs Denormalization

- **3NF baseline**: Start normalized, denormalize only when read performance demands it
- **Denormalization trade-offs**: Faster reads, slower writes, data duplication risk
- **Common denormalization**: Store calculated totals, duplicate frequently joined columns

### Data Type Selection

```sql
-- Use smallest sufficient type
INT vs BIGINT           -- INT (4 bytes) if max 2.1B is enough
VARCHAR(255) vs TEXT    -- VARCHAR for indexed columns, TEXT for large content
DECIMAL vs FLOAT        -- DECIMAL for money, FLOAT for scientific
DATETIME vs TIMESTAMP   -- TIMESTAMP (4 bytes, UTC) vs DATETIME (8 bytes, no TZ)
```

### NULL Handling

- Nullable columns add 1 byte overhead per row
- NULL values complicate index usage and comparisons
- Use `NOT NULL DEFAULT ''` or `NOT NULL DEFAULT 0` when possible
- `COUNT(nullable_col)` excludes NULLs — use `COUNT(*)` for total rows

### Partitioning Considerations

```sql
-- Range partition by date (common for time-series data)
CREATE TABLE orders (
    id BIGINT NOT NULL,
    created_at DATETIME NOT NULL,
    -- ...
) PARTITION BY RANGE (YEAR(created_at)) (
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026),
    PARTITION pmax  VALUES LESS THAN MAXVALUE
);
```

- Partition when table exceeds 50M+ rows
- Partition key must be part of every unique index
- Useful for archiving old data (drop partition instead of DELETE)

---

## MySQL Server Tuning

### Buffer & Memory Configuration

```ini
# InnoDB buffer pool: 70-80% of available RAM for dedicated DB server
innodb_buffer_pool_size = 4G

# Sort buffer: per-connection, increase for complex ORDER BY
sort_buffer_size = 4M

# Join buffer: per-connection, increase for joins without indexes
join_buffer_size = 4M

# Temp table: in-memory before spilling to disk
tmp_table_size = 64M
max_heap_table_size = 64M
```

### Connection Configuration

```ini
# Max connections: monitor Threads_connected, set 20-30% headroom
max_connections = 200

# Max allowed packet: increase for large BLOBs or bulk inserts
max_allowed_packet = 64M

# Wait timeout: close idle connections (default 28800 = 8h, often too long)
wait_timeout = 600
interactive_timeout = 600
```

---

## Additional Resources

For detailed guidance:
- **references/index-design.md** - B+Tree internals, composite index strategies
- **references/query-patterns.md** - Common patterns and anti-patterns
- **references/jpa-hibernate-tuning.md** - Cache, batch, connection pool tuning
