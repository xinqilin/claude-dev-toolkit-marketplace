---
name: mysql-performance
description: Analyze MySQL query performance and provide optimization recommendations
argument-hint: [sql-query]
allowed-tools: Read, Grep, Glob
model: sonnet
---

# MySQL Performance

Help optimize MySQL performance and troubleshoot query issues. When assisting:

## 1. Query Optimization
- Analyze EXPLAIN output thoroughly
- Identify sequential scans on large tables
- Recommend index strategies
- Suggest query rewrites for better execution plans
- Join order optimization

## 2. Index Strategy
- Primary key and unique constraint design
- Composite index effectiveness (column order matters)
- Covering indexes for specific query patterns
- Index selectivity and cardinality analysis
- Trade-offs between query speed and insert/update performance

## 3. Schema Design
- Normalization levels and denormalization trade-offs
- Data type selection (INT vs BIGINT, VARCHAR sizing)
- NULL handling implications
- Foreign key constraints strategy
- Partitioning and sharding considerations

## 4. Query Analysis
Request and analyze:
- EXPLAIN ANALYZE output (MySQL 5.6+ extended format)
- Query execution statistics
- Table statistics and row counts
- Index usage patterns

Identify:
- Full table scans that should use indexes
- Inefficient join conditions
- Subqueries that could be materialized
- Missing or unused indexes
- Query cost implications

## 5. Connection & Buffer Tuning
- Connection pool configuration (max_connections)
- Buffer sizes (innodb_buffer_pool_size, sort_buffer_size)
- Query cache strategy
- Max allowed packet sizes

## 6. Common Patterns

**N+1 Problem**: Parent query fetches N rows, then N queries for children
Solution: JOIN FETCH in JPA or single query with grouping in SQL

**Missing Indexes**: Sequential scan on WHERE clause column
Create specific index: CREATE INDEX idx_name ON table(column)

**Inefficient Joins**: Wrong join type or join conditions using functions
Rewrite to let database optimize properly

**Covering Indexes**: Index includes all columns in SELECT and WHERE
Query doesn't need to access table data at all

## Output Format

For each optimization provide:

**Current Performance**:
- Query execution time
- Rows examined vs rows returned
- Index usage if any

**Problem Analysis**:
- What's making this slow?
- EXPLAIN output interpretation

**Solution**:
- Exact index to create or drop
- Query rewrite with rationale
- Expected improvement

**Verification**:
- How to measure improvement
- New EXPLAIN output comparison

**Warnings**:
- Impact on other queries
- Insert/update performance trade-offs
- Disk space implications

**IMPORTANT: All output must be in Traditional Chinese (繁體中文)**
