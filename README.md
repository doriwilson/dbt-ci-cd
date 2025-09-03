# Enhanced dbt CI/CD with Recce Data Validation

## Overview

This repository demonstrates a comprehensive CI/CD pipeline for dbt projects using GitHub Actions, enhanced with **Recce data validation capabilities**. The pipeline provides safe, efficient, and isolated testing of dbt changes while maintaining production data integrity, plus automated data validation to catch issues before deployment.

> **🎯 What's New:** This enhanced version builds on the excellent [original dbt-ci-cd repository](https://github.com/dbt-labs/dbt-ci-cd) by adding Recce data validation, automated PR comments with validation results, and comprehensive data quality checks.

## Key Features

### Original Slim CI/CD Benefits (Preserved)
- **Faster Testing:** Only tests modified models and dependencies (minutes vs hours)
- **Cost Efficiency:** Reduces warehouse usage during testing
- **Production Safety:** Tests against real production data structures
- **Isolated Testing:** Each PR gets its own schema to prevent conflicts
- **Incremental Deployment:** Only rebuilds changed models in production

### New Data Validation Features (Added)
- **🔍 Automated Data Validation:** Recce runs comprehensive data quality checks on every PR
- **📊 PR Comment Integration:** Validation results automatically posted to PR comments
- **🎯 Business Logic Validation:** Custom checks for revenue, customer segmentation, and data quality
- **📈 Schema Change Detection:** Automatic detection of breaking schema changes
- **🔄 State File Management:** Preserves validation state for detailed review
- **⚡ Preset Validation Checks:** Pre-configured checks for common data issues

## GitHub Actions Workflows

### 1. Enhanced Continuous Integration (CI) Workflow - `ci.yml`

**Trigger:** Pull requests to the `main` branch

**Purpose:** Tests dbt changes in isolated schemas and runs comprehensive data validation before merging

**New Features Added:**
- **Recce Data Validation:** Automated data quality checks after successful dbt build
- **PR Comment Integration:** Validation results posted directly to PR comments
- **State File Management:** Uploads validation state for detailed review
- **Graceful Fallback:** Handles first runs without base artifacts

**Steps:**

1. **Setup: Install dbt and dependencies**
```yaml
- name: Install dbt
  run: pip install -r dbt-requirements.txt
```
*Installs dbt-snowflake and other required packages*

2. **Download Manifest: Get latest production manifest for state comparison**
```yaml
- name: Download latest manifest artifact
  shell: bash
  run: |
    curl -s -H "Authorization: Bearer ${{ secrets.GITHUB_TOKEN }}" \
        "https://api.github.com/repos/${{ github.repository }}/actions/artifacts" \
        -o artifacts.json
    artifact_id=$(grep -A20 '"name": "dbt-manifest"' artifacts.json | grep '"id":' | head -n1 | sed 's/[^0-9]*\([0-9]\+\).*/\1/')
    curl -sL -H "Authorization: Bearer ${{ secrets.GITHUB_TOKEN }}" \
        "https://api.github.com/repos/${{ github.repository }}/actions/artifacts/$artifact_id/zip" \
        -o artifact.zip
    unzip -q artifact.zip -d state
```
*Downloads the latest production manifest to enable state comparison and Slim CI*

3. **Generate Schema: Create unique schema using PR number and commit SHA**
```yaml
- name: Generate schema ID
  run: echo "SCHEMA_ID=${{ github.event.pull_request.number }}__${{ github.sha }}" >> $GITHUB_ENV
```
*Creates unique schema name like `pr_123__abc123def456` to isolate PR testing*

4. **Run Tests: Execute dbt build with state comparison (only modified models)**
```yaml
- name: dbt build (slim CI when state is available)
  run: |
    if [ -f "./manifest.json" ]; then
      dbt build -s 'state:modified+' --defer --state ./state --target $DBT_TARGET --vars "schema_id: $SCHEMA_ID"
    else
      dbt build --target $DBT_TARGET --vars "schema_id: $SCHEMA_ID"
    fi
```
*Uses Slim CI to only build modified models, deferring unchanged models to production*

5. **🆕 Data Validation: Run Recce validation checks**
```yaml
- name: Prepare base artifacts for Recce comparison
  run: |
    if [ -f "./state/manifest.json" ]; then
      mkdir -p target-base
      cp ./state/manifest.json ./target-base/manifest.json
      # Copy additional artifacts if available
    fi

- name: Run Recce validation
  run: |
    recce run --github-pull-request-url ${{ github.event.pull_request.html_url }}
```
*Runs comprehensive data validation using Recce preset checks*

6. **🆕 Generate Validation Summary: Create PR comment with results**
```yaml
- name: Generate Recce summary for PR comment
  run: |
    recce summary recce_state.json > recce_summary.md
    # Add next steps and handle long summaries

- name: Comment on pull request with validation results
  uses: thollander/actions-comment-pull-request@v2
  with:
    filePath: recce_summary.md
    comment_tag: recce-validation
```
*Posts validation results directly to PR comments for easy review*

7. **🆕 Upload Validation State: Save state file for detailed review**
```yaml
- name: Upload Recce state file
  uses: actions/upload-artifact@v4
  with:
    name: recce-state-pr-${{ github.event.pull_request.number }}
    path: recce_state.json
```
*Saves validation state for detailed review using Recce server*

### 2. Enhanced Continuous Deployment (CD) Workflow - `cd.yml`

**Trigger:** Pushes to the `main` branch

**Purpose:** Deploys tested changes to production environment and prepares artifacts for future validation

**New Features Added:**
- **Enhanced Artifact Management:** Uploads catalog.json and run_results.json for Recce compatibility
- **Documentation Generation:** Ensures dbt docs are generated for comprehensive validation

**Steps:**

1. **Setup: Install dbt and dependencies**
```yaml
- name: Install dbt
  run: pip install -r dbt-requirements.txt
```
*Installs dbt-snowflake and other required packages*

2. **Download Manifest: Get previous deployment manifest for incremental builds**
```yaml
- name: Download latest manifest artifact
  shell: bash
  run: |
    curl -s -H "Authorization: Bearer ${{ secrets.GITHUB_TOKEN }}" \
        "https://api.github.com/repos/${{ github.repository }}/actions/artifacts" \
        -o artifacts.json
    artifact_id=$(grep -A20 '"name": "dbt-manifest"' artifacts.json | grep '"id":' | head -n1 | sed 's/[^0-9]*\([0-9]\+\).*/\1/')
    curl -sL -H "Authorization: Bearer ${{ secrets.GITHUB_TOKEN }}" \
        "https://api.github.com/repos/${{ github.repository }}/actions/artifacts/$artifact_id/zip" \
        -o artifact.zip
    unzip -q artifact.zip -d state
```
*Downloads the previous production manifest to enable incremental deployment*

3. **Deploy: Run dbt build with state comparison (only changed models)**
```yaml
- name: Deploy to production
  run: |
    if [ -f "./state/manifest.json" ]; then
      cp ./state/manifest.json ./manifest.json
      dbt build -s 'state:modified+' --state ./ --target prod
    else
      dbt build --target prod
    fi
```
*Deploys only modified models and dependencies to production using state comparison*

4. **Upload Artifact: Save new manifest for future deployments**
```yaml
- name: Upload new manifest artifact
  uses: actions/upload-artifact@v4
  with:
    name: dbt-manifest
    path: ./target/manifest.json
    retention-days: 7
```
*Saves the new production manifest for future incremental deployments*

### 3. CI Teardown Workflow - `ci_teardown.yml`

**Trigger:** Pull request closure (merged, closed, or abandoned)

**Purpose:** Automatically cleans up temporary CI schemas

**Steps:**

1. **Setup: Install dbt and dependencies**
```yaml
- name: Install dbt
  run: pip install -r dbt-requirements.txt
```
*Installs dbt-snowflake and other required packages*

2. **Cleanup: Drop all schemas created for the specific PR**
```yaml
- name: Cleanup PR schemas
  run: |
    dbt run-operation drop_pr_schemas \
      --target pr \
      --args '{"database": "'"$SNOWFLAKE_DATABASE"'", "schema_prefix": "pr", "pr_number": "'"$PR_NUM"'"}'
```
*Drops all temporary schemas created during PR testing to free up resources*

3. **Logging: Record cleanup operations and results**
```yaml
- name: Log cleanup results
  run: echo "✅ Cleanup completed for PR #$PR_NUM"
```
*Records successful cleanup completion for audit purposes*

## Using Other Platforms

The workflows in this repository are designed for Snowflake but can be easily adapted for other dbt-supported platforms. Here's what you need to change:

1. **Update dbt Requirements** - Replace `dbt-snowflake` with your platform's adapter (e.g., `dbt-bigquery`, `dbt-postgres`, `dbt-redshift`, `dbt-databricks`)

2. **Update Environment Variables** - Change the environment variables according to your data platform's connection requirements

3. **Update profiles.yml** - Modify your profiles configuration to use the new environment variables and platform type

4. **Update Cleanup Operations** - Modify the cleanup macro to work with your platform's resource management approach

The core CI/CD logic remains the same - only the connection details and resource management need to be updated for your specific platform.

## Quick Start

### 1. Fork This Repository
This repository is ready to use with DuckDB and Jaffle Shop data - no external database setup required!

### 2. Add GitHub Secret
Add this single secret to your repository settings:
```
RECCE_STATE_PASSWORD=your-secure-password
```

### 3. Create a Test PR
Make any small change and open a PR to see the validation in action.

## What You'll See

When you open a PR, you'll get an automated comment like this:

```markdown
# Recce Validation Summary

## ✅ Validation Results
- **Row count validation - dim_customers**: ✅ PASSED
- **Customer Lifetime Value validation**: ✅ PASSED  
- **Order status distribution validation**: ✅ PASSED
- **Schema validation - fct_orders**: ✅ PASSED

## 📊 Key Metrics
- Total customers: 10 (no change)
- Total revenue: $1,234.56 (no change)
- Order count: 14 (no change)
```

## Key Files

- **`recce.yml`** - Pre-configured validation checks for Jaffle Shop models
- **`.github/workflows/ci.yml`** - Enhanced CI workflow with Recce validation
- **`profiles.yml`** - DuckDB configuration (no external credentials needed)
- **`models/`** - Jaffle Shop dbt models (customers, orders, products)
- **`seeds/`** - Sample data for testing validation
- **`.ai_context/recce/`** - Complete Recce documentation for AI assistance

## For AI-Assisted Development

If you're using Claude, Cursor, or similar AI coding tools, check out **`.ai_context/recce/AI_DEVELOPMENT.md`** for:
- Essential context files to include
- Quick prompts for common tasks
- Integration patterns and best practices
- Troubleshooting guidance

## Credits and Acknowledgments

This enhanced repository builds upon the excellent work from the [original dbt-ci-cd repository](https://github.com/dbt-labs/dbt-ci-cd). The original repository provided:

- Slim CI implementation for efficient testing
- GitHub Actions workflows for CI/CD
- GitHub artifacts for manifest storage
- Automatic schema cleanup

**What we added:**
- Recce data validation integration
- Automated PR comment generation
- Comprehensive preset validation checks
- Enhanced artifact management for validation
- Business logic validation for Jaffle Shop models



