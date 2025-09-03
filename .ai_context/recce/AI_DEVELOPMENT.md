# AI-Assisted Development Guide

## Overview
This guide helps AI coding assistants (Claude, Cursor, GitHub Copilot, etc.) understand the Recce integration patterns and provide better assistance when working on dbt CI/CD projects with data validation.

## Essential Context Files

When working on Recce integration, always include these context files:

### Core Integration Patterns
- **`setup-gh-actions.md`** - Complete GitHub Actions CI/CD patterns with Recce
- **`scenario-ci.md`** - CI-specific integration scenarios and workflows
- **`configure-diff.md`** - Artifact requirements and comparison setup

### Configuration & Validation
- **`preset-checks.md`** - How to create and configure validation checks
- **`recce-run.md`** - Command-line usage patterns
- **`recce-summary.md`** - Generating and formatting validation summaries

### Setup & Debugging
- **`installation.md`** - Basic installation requirements
- **`recce-debug.md`** - Debugging common issues and configuration problems
- **`state-file.md`** - Understanding and working with Recce state files

### Platform-Specific Guides
- **`get-started-jaffle-shop.md`** - DuckDB setup patterns (perfect for tutorials)
- **`getting-started-recce-cloud.md`** - Cloud-based integration patterns

## Quick AI Prompts

### For CI/CD Integration
```
"Help me debug this Recce CI setup using the context docs in recce_context/"
"Create a GitHub Actions workflow that integrates Recce validation after dbt build"
"Show me how to handle the case where base artifacts don't exist in the first run"
```

### For Configuration
```
"Create preset checks based on the documentation patterns in recce_context/preset-checks.md"
"Help me configure recce.yml for a Jaffle Shop-style project using the context docs"
"Generate validation checks for customer lifetime value and revenue metrics"
```

### For Troubleshooting
```
"Debug this Recce validation error using the patterns in recce_context/recce-debug.md"
"Help me understand why my state file isn't being generated properly"
"Fix this GitHub Actions workflow that's failing on Recce validation"
```

## Key Integration Patterns

### 1. Basic CI Workflow Enhancement
```yaml
# After dbt build, add Recce validation
- name: Run Recce validation
  run: |
    if [ -f "./target-base/manifest.json" ]; then
      recce run --github-pull-request-url ${{ github.event.pull_request.html_url }}
    else
      echo "No base artifacts found - running without comparison"
      recce run --github-pull-request-url ${{ github.event.pull_request.html_url }}
    fi
```

### 2. Artifact Management
```yaml
# Download base artifacts for comparison
- name: Download base artifacts
  run: |
    # Download manifest, catalog, run_results from previous runs
    # Place in target-base/ directory for Recce comparison
```

### 3. PR Comment Integration
```yaml
# Generate and post validation summary
- name: Comment on PR with validation results
  uses: thollander/actions-comment-pull-request@v2
  with:
    filePath: recce_summary.md
    comment_tag: recce-validation
```

## Common Configuration Patterns

### DuckDB Setup (Tutorial-Friendly)
```yaml
# profiles.yml
jaffle_shop:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: 'jaffle_shop.duckdb'
      schema: 'dev'
    pr:
      type: duckdb
      path: 'jaffle_shop.duckdb'
      schema: "pr_{{ var('schema_id') }}"
```

### Preset Validation Checks
```yaml
# recce.yml
checks:
  - name: Row count validation
    type: row_count_diff
    params:
      model: "{{ ref('dim_customers') }}"
  - name: Business logic validation
    type: query_diff
    params:
      sql_template: |
        select customer_tier, count(*) as customer_count
        from {{ ref('dim_customers') }}
        group by customer_tier
```

## Error Handling Patterns

### Graceful Fallback for Missing Base Artifacts
```bash
if [ -f "./target-base/manifest.json" ]; then
  echo "Running with base comparison"
  recce run
else
  echo "No base artifacts - running without comparison"
  recce run || {
    echo "Recce completed with warnings (expected for first run)"
  }
fi
```

### State File Management
```yaml
- name: Upload Recce state file
  uses: actions/upload-artifact@v4
  if: always()
  with:
    name: recce-state-pr-${{ github.event.pull_request.number }}
    path: recce_state.json
    retention-days: 7
```

## Best Practices for AI Assistance

### 1. Always Include Context
When asking for help, reference the specific context files:
```
"Using the patterns in recce_context/setup-gh-actions.md, help me..."
```

### 2. Specify Your Use Case
- **Tutorial/Educational**: Use DuckDB + Jaffle Shop patterns
- **Production**: Use cloud warehouse patterns
- **CI/CD**: Focus on GitHub Actions integration

### 3. Ask for Specific Patterns
- "Show me the artifact download pattern"
- "Help me create preset checks for revenue validation"
- "Debug this state file generation issue"

## Repository Structure Context

This repository demonstrates:
- **Enhanced Slim CI** with Recce validation
- **DuckDB setup** for easy local testing
- **Jaffle Shop data** for realistic examples
- **GitHub Actions integration** with PR comments
- **Comprehensive validation checks** for business logic

## Troubleshooting Common Issues

### 1. Recce Debug Fails
- Check that `recce.yml` syntax is valid
- Ensure dbt artifacts exist in `target/` and `target-base/`
- Verify warehouse connection (if using cloud)

### 2. GitHub Actions Fails
- Ensure `RECCE_STATE_PASSWORD` secret is set
- Check that `GITHUB_TOKEN` has proper permissions
- Verify workflow file syntax

### 3. Validation Checks Fail
- Review `recce.yml` configuration
- Check that referenced models exist
- Ensure SQL templates are valid

## Advanced Patterns

### Custom Validation Logic
```yaml
- name: Revenue impact analysis
  type: query_diff
  params:
    sql_template: |
      select 
        payment_method,
        sum(total_amount) as total_revenue,
        count(*) as order_count
      from {{ ref('stg_orders') }}
      group by payment_method
  view_options:
    primary_keys:
      - payment_method
```

### Schema Change Detection
```yaml
- name: Schema validation
  type: schema_diff
  params:
    model: "{{ ref('dim_customers') }}"
```

## Getting Help

1. **Check the context files** in `recce_context/` first
2. **Use specific prompts** that reference the documentation
3. **Include your use case** (tutorial vs production)
4. **Share error messages** and relevant configuration

This guide should help AI assistants provide much better assistance when working on Recce integrations!
