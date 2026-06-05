# Salesforce CI/CD Pipeline

![Deploy to Production](https://github.com/rsantiago76/Salesforce-cicd-pipeline/actions/workflows/deploy-main.yml/badge.svg)

A production-grade CI/CD pipeline for Salesforce metadata deployments using GitHub Actions, Salesforce CLI, and PMD static analysis. Demonstrates automated testing, code quality enforcement, and deployment automation at an enterprise level.

---

## Architecture Overview
Developer Push → GitHub Actions → PMD Static Analysis → Apex Tests → Deploy to Org
↓                    ↓
Fail on violations    Fail if < 75%
coverage

---

## Features

- **Automated Deployments** — Triggers on every push to `main` that touches `force-app/`
- **Static Code Analysis** — PMD scans Apex code against a custom ruleset before deployment
- **Test Enforcement** — Runs specified Apex test classes and enforces coverage thresholds
- **Deployment Summaries** — Posts branch, commit, actor, and status to the GitHub Actions job summary
- **Pull Request Validation** — Separate `validate-pr.yml` workflow validates PRs without deploying
- **Secure Authentication** — Uses SFDX Auth URL stored as a GitHub Actions secret (never hardcoded)

---

## Tech Stack

| Tool | Purpose |
|------|---------|
| GitHub Actions | CI/CD orchestration |
| Salesforce CLI (`sf`) | Metadata deployment & test execution |
| PMD | Apex static analysis |
| SFDX Auth URL | Secure org authentication |
| Apex / OrderService | Business logic under test |

---

## Project Structure
sf-cicd-pipeline/
├── .github/
│   └── workflows/
│       ├── deploy-main.yml       # Deploy on push to main
│       └── validate-pr.yml       # Validate on pull requests
├── force-app/
│   └── main/default/
│       ├── classes/
│       │   ├── OrderService.cls          # Business logic
│       │   └── OrderServiceTest.cls      # Test class (100% coverage)
│       └── triggers/
├── pmd/
│   └── ruleset.xml               # Custom PMD rules
└── scripts/                      # Utility scripts

---

## Workflows

### `deploy-main.yml` — Deploy to Production
Triggers on push to `main` when `force-app/**` files change.

**Steps:**
1. Checkout code
2. Install Salesforce CLI
3. Authenticate to org via `SFDX_AUTH_URL` secret
4. Deploy metadata with `RunSpecifiedTests`
5. Verify deployment with code coverage report
6. Post deployment summary to job output

### `validate-pr.yml` — Pull Request Validation
Triggers on pull requests targeting `main`. Runs a check-only deploy (no actual deployment) to validate metadata and tests before merge.

---

## Setup & Usage

### Prerequisites
- Salesforce org (Developer, Sandbox, or Production)
- GitHub repository with Actions enabled
- Salesforce CLI installed locally

### 1. Generate Auth URL
```bash
sf org display --verbose --target-org <your-org-username>
```
Copy the `Sfdx Auth Url` value.

### 2. Add GitHub Secret
Go to **Settings → Secrets and variables → Actions → New repository secret**

| Name | Value |
|------|-------|
| `SFDX_AUTH_URL` | `force://PlatformCLI::...@your-instance.salesforce.com` |

### 3. Push to Main
Any push to `main` that modifies files under `force-app/` will automatically trigger the pipeline.

---

## OrderService — Business Logic

The deployed Apex class demonstrates enterprise-grade service layer patterns:

```apex
public with sharing class OrderService {
    // Query orders by account with status filter
    public static List<Order> getOrdersByAccount(Id accountId) { ... }

    // Count open/draft orders org-wide
    public static Integer countOpenOrders() { ... }

    // Activate an order (requires active contract + products)
    public static void activateOrder(Id orderId) { ... }
}
```

**Test Coverage:** 3 test methods covering all execution paths, including Pricebook, Product, and Contract activation setup — achieving 100% class coverage.

---

## PMD Static Analysis

Custom ruleset enforces Apex best practices:
- No empty catch blocks
- No SOQL inside loops
- Proper exception handling
- Naming conventions

Pipeline fails if any PMD violations are found at the configured priority level.

---

## Key Engineering Decisions

**Why `RunSpecifiedTests` instead of `RunLocalTests`?**
The org contains triggers from other projects with separate test classes. Using `RunSpecifiedTests` scopes coverage to this project's classes, avoiding false failures from unrelated org-wide coverage gaps.

**Why SFDX Auth URL over Connected App?**
For a developer portfolio org, SFDX Auth URL is simpler to configure and rotate. In production enterprise environments, a Connected App with JWT Bearer flow is preferred for non-interactive CI/CD.

---

## Author

**Richard Santiago** — Senior Salesforce Developer
[Portfolio](https://rsantiago76.github.io/Salesforce-Developer-Portfolio/) · [GitHub](https://github.com/rsantiago76) · [LinkedIn](https://linkedin.com/in/richard-santiago)
