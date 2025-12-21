# Bill Lin Dev Toolkit

[繁體中文](./README.zh-TW.md) | English

Enterprise-grade Java/Spring Boot development toolkit with 4 independent professional plugins that can be installed as needed.

## Quick Overview

### 4 Independent Plugins

#### 1. bill-billing-unit-test-reviewer
Focused on unit test review and best practices
- **Agent**: bill-billing-unit-test-reviewer
- **Expertise**: TDD, test design, coverage analysis, avoiding over-engineering

#### 2. bill-code-reviewer
Code quality review and PR Review
- **Agent**: bill-code-reviewer
- **Commands**:
  - `/code-review` - Code quality review (Clean Code + avoiding over-engineering)
  - `/review-pr` - PR change review (branch diff analysis)
- **Expertise**: Clean Code, avoiding over-engineering, architecture evaluation, PR Review

#### 3. bill-java-developer
Spring Boot development and database optimization expert
- **Agent**: bill-java-developer
- **Commands**:
  - `/design-solution` - Technical solution design and recommendations
  - `/optimize-query` - SQL/JPA optimization
  - `/mysql-performance` - MySQL performance optimization
- **Expertise**: Spring Boot, JPA, database performance, enterprise architecture, technical solution design

#### 4. bill-java-skills (NEW)
Java development best practices knowledge base
- **Skills** (auto-triggered, no manual invocation needed):
  - `clean-architecture` - Clean Architecture design principles
  - `effective-java` - Effective Java best practices
  - `mysql-optimization` - MySQL performance optimization and JPA tuning
- **Usage**: Automatically applies these principles during Code Review and design discussions

> **Difference between Skills, Commands, and Agents**:
> - **Commands** (`/xxx`): Require manual invocation
> - **Agents**: Automatically start based on conversation, provide interactive assistance
> - **Skills**: Knowledge base, Claude automatically references and applies based on context

## Installation

You can choose to install all 4 plugins or only the ones you need.

### Step 1: Add Marketplace

**Install from GitHub (Recommended)**:
```
/plugin marketplace add xinqilin/claude-dev-toolkit-marketplace
```

**Install from local**:
```
/plugin marketplace add /path/to/project-claude-code-plugins
```

### Step 2: Install Plugins

Choose the plugins you need:

**Install all 4 plugins**:
```
/plugin install bill-billing-unit-test-reviewer
/plugin install bill-code-reviewer
/plugin install bill-java-developer
/plugin install bill-java-skills
```

**Or install only what you need**:
```
# Only test review
/plugin install bill-billing-unit-test-reviewer

# Only code review
/plugin install bill-code-reviewer

# Only Spring Boot development tools
/plugin install bill-java-developer

# Only Java best practices Skills (recommended to pair with any plugin above)
/plugin install bill-java-skills
```

### Verify Installation

After installation, you can verify with:
```
# View installed plugins
/plugin list

# View available commands
/help
```

## Quick Start

### Using Commands

#### Java Code Reviewer Plugin

**Review code quality**:
```text
/code-review src/main/java/com/example/OrderService.java
```

**Review PR changes**:
```text
# Review GitHub PR (requires gh CLI)
/review-pr 123
/review-pr #456

# Review current branch diff against master
/review-pr

# Review feature-branch diff against master
/review-pr feature-branch

# Review feature-branch diff against develop
/review-pr feature-branch develop
```

**Note**: Reviewing GitHub PRs requires GitHub CLI (`gh`) to be installed and authenticated:
```bash
# Install gh CLI
brew install gh

# Authenticate
gh auth login
```

#### Java Spring Developer Plugin

**Technical solution design**:
```text
/design-solution
[Describe your requirements or problem]
```

**Optimize queries**:
```text
/optimize-query
[Paste your SQL or JPA code]
```

**MySQL performance optimization**:
```text
/mysql-performance
[Paste your SQL query or EXPLAIN results]
```

### Starting Agents

Agents automatically start based on your questions and conversation content. You don't need to explicitly invoke them, just:

**Start Java Developer Agent**:

```text
I need to design a system for handling high-concurrency orders
```

or

```text
This Spring Boot code has performance issues, please help me analyze
```

**Start Code Reviewer Agent**:

```text
Please review this code's quality
```

or

```text
What improvements can be made to this code?
```

**Start Unit Test Reviewer Agent**:

```text
Please review my unit test design
```

or

```text
Is this test case over-engineered?
```

Agents automatically identify your needs and provide professional advice. You can also explicitly specify by mentioning "Java Developer", "Code Reviewer", or "Unit Test Reviewer" in the conversation.

## Common Workflows

### Performance Optimization

1. `/mysql-performance` - Analyze queries
2. Discuss with Java Developer Agent - Understand implementation
3. Discuss with Code Reviewer Agent - Check code quality

### Architecture Design

1. `/review-architecture` - Evaluate design
2. Discuss with Java Developer Agent - Detailed implementation suggestions
3. Discuss with Code Reviewer Agent - Quality check

### Code Refactoring

1. `/analyze-code` - Comprehensive analysis
2. `/refactor-suggestion` - Get suggestions
3. Discuss with Code Reviewer Agent - Final review

### Test Design

1. Write initial test code
2. Discuss with Unit Test Reviewer Agent - Test design review
3. Improve test cases based on suggestions

## Plugin Details

### 1. bill-billing-unit-test-reviewer

**Standalone Installation**: If you only need test review functionality

Focused on unit test quality and best practices:
- TDD test-driven development expert
- Test design principles and best practices
- Test responsibility separation and coverage analysis
- Avoiding over-engineering and fictional scenarios
- Test strategies based on real system behavior

**Use Cases**: Test code review, TDD practices, test refactoring

### 2. bill-code-reviewer

**Standalone Installation**: If you primarily need code quality review

Code quality, architecture design, and refactoring expert:
- Clean Code principles expert
- Refactoring and Design Pattern proficiency
- Performance analysis and algorithm optimization
- Pragmatic and balanced code quality assessment
- Architecture design and system maintainability

**Use Cases**: Code Review, refactoring suggestions, architecture evaluation

### 3. bill-java-developer

**Standalone Installation**: If you primarily need development and performance optimization

Spring Boot development and database optimization expert:
- 15+ years production environment experience
- Spring Boot, JPA, Hibernate proficiency
- MySQL query optimization and indexing strategies
- System design, distributed systems
- Provides complete production-grade code solutions

**Use Cases**: Spring Boot development, database performance optimization, system design

### 4. bill-java-skills

**Standalone Installation**: If you want automated Java best practices guidance

Java development best practices knowledge base with 3 Skills:

#### clean-architecture
- Clean Architecture / Hexagonal Architecture design principles
- Layer dependency rules and violation detection
- Spring Boot project structure templates
- Layered testing strategy

**Trigger Conditions**: Automatically applies when discussing architecture design, layering structure, dependency rules

#### effective-java
- Joshua Bloch's Effective Java best practices
- Object creation (Static Factory, Builder Pattern)
- Class design (immutability, composition over inheritance)
- Stream API and concurrent programming

**Trigger Conditions**: Automatically applies when reviewing Java code quality, discussing design patterns

#### mysql-optimization
- Index design principles (composite indexes, covering indexes)
- Query optimization patterns (N+1, pagination optimization)
- JPA/Hibernate performance tuning
- EXPLAIN analysis guide

**Trigger Conditions**: Automatically applies when discussing database performance, N+1 issues, JPA optimization

**Use Cases**: Pair with other plugins, automatically improve Code Review and design solution quality

> **How Skills Work**:
> Skills don't need manual invocation. When the conversation involves related topics, Claude automatically loads core principles from SKILL.md.
> For more detailed information, Claude automatically references detailed documentation in the `references/` directory.

## Directory Structure

```plaintext
project-claude-code-plugins/
├── .claude-plugin/
│   └── marketplace.json              # Marketplace definition
└── plugins/
    ├── bill-billing-unit-test-reviewer/      # Plugin 1: Unit test review
    │   ├── .claude-plugin/
    │   │   └── plugin.json
    │   └── agents/
    │       └── bill-billing-unit-test-reviewer.md
    │
    ├── bill-code-reviewer/           # Plugin 2: Code review
    │   ├── .claude-plugin/
    │   │   └── plugin.json
    │   ├── agents/
    │   │   └── bill-code-reviewer.md
    │   └── commands/
    │       ├── code-review.md
    │       └── review-pr.md
    │
    ├── bill-java-developer/          # Plugin 3: Spring Boot development
    │   ├── .claude-plugin/
    │   │   └── plugin.json
    │   ├── agents/
    │   │   └── bill-java-developer.md
    │   └── commands/
    │       ├── design-solution.md
    │       ├── mysql-performance.md
    │       └── optimize-query.md
    │
    └── bill-java-skills/             # Plugin 4: Java best practices Skills
        ├── .claude-plugin/
        │   └── plugin.json
        └── skills/
            ├── clean-architecture/
            │   ├── SKILL.md                    # Core principles
            │   └── references/                 # Detailed reference docs
            │       ├── layer-dependencies.md
            │       ├── spring-boot-implementation.md
            │       └── testing-strategy.md
            ├── effective-java/
            │   ├── SKILL.md
            │   └── references/
            │       ├── object-creation.md
            │       ├── classes-and-interfaces.md
            │       ├── lambdas-streams.md
            │       └── concurrency.md
            └── mysql-optimization/
                ├── SKILL.md
                └── references/
                    ├── index-design.md
                    ├── query-patterns.md
                    └── jpa-hibernate-tuning.md
```

## Why Choose This Marketplace?

### Modular Design
4 independent plugins, install as needed:
- **Only need test review?** Install bill-billing-unit-test-reviewer
- **Only need code review?** Install bill-code-reviewer
- **Only need development optimization?** Install bill-java-developer
- **Need best practices guidance?** Install bill-java-skills
- **Need the full toolkit?** Install all at once

### Professional Depth
Each plugin is designed by senior experts:
- 15+ years enterprise development experience
- Real production environment best practices
- Pragmatic, actionable advice

### Continuous Updates
- Regular updates with latest development practices
- Improvements based on community feedback
- Support for latest Java/Spring Boot versions

## Best Practices

### Provide Complete Context

Clearly state your problem, environment, and constraints:

```text
Good: My query takes 3 seconds, table has 5 million rows, EXPLAIN result is...
Bad: Why is this slow?
```

### Clearly State Constraints

Help the Agent understand your specific needs:

```text
Good: Table has 5 million records, expected QPS is 1000/sec, prioritize query speed
Bad: Can you help me optimize?
```

### Continuous Conversation

You can continue asking questions based on previous analysis, building deeper discussion.

### Compare Solutions

Ask the Agent to compare different implementation approaches, understand the trade-offs of various solutions.

### Specific Details

Request specific code rather than theory, get executable solutions directly.

## GitHub Repository

[https://github.com/xinqilin/claude-dev-toolkit-marketplace](https://github.com/xinqilin/claude-dev-toolkit-marketplace)

## License

MIT License - See [LICENSE](LICENSE) file for details
