# Testing the Enhanced dbt CI/CD Pipeline

## 1. Local Testing Setup

### Prerequisites Check
```bash
# Verify you have the required tools
python --version  # Should be 3.8+
dbt --version     # Should be 1.8+
recce --version   # Should be latest
```

### Test Recce Configuration
```bash
# Test Recce configuration locally
recce debug

# This should show:
# ✅ Artifacts found in target/
# ✅ Base artifacts found in target-base/ (if available)
# ✅ Warehouse connection successful
```

### Test dbt Build
```bash
# Test the dbt build process
dbt deps
dbt build --target pr --vars "schema_id: test_123__abc123"

# Verify models are created successfully
```

### Test Recce Validation Locally
```bash
# Run Recce validation locally
recce run

# This should:
# ✅ Execute all preset checks from recce.yml
# ✅ Generate recce_state.json
# ✅ Show validation results in terminal
```

### Review Results
```bash
# Launch Recce server to review results
recce server --review recce_state.json

# Open http://localhost:8000 in your browser
# You should see all validation checks and results
```

## 2. GitHub Actions Testing

### Step 1: Set Up GitHub Secrets
Add these secrets to your repository settings:
- `SNOWFLAKE_ACCOUNT`
- `SNOWFLAKE_USER` 
- `SNOWFLAKE_PASSWORD`
- `SNOWFLAKE_ROLE`
- `SNOWFLAKE_WAREHOUSE`
- `SNOWFLAKE_DATABASE`
- `SNOWFLAKE_SCHEMA`
- `RECCE_STATE_PASSWORD` (new - use a secure password)

### Step 2: Create a Test PR
1. Create a new branch: `git checkout -b test-recce-validation`
2. Make a small change to a model (e.g., add a comment)
3. Commit and push: `git push origin test-recce-validation`
4. Open a PR to main branch

### Step 3: Monitor the Workflow
Watch the GitHub Actions tab for:
1. **CI workflow starts** (should trigger automatically)
2. **dbt build completes** (Slim CI should work)
3. **Recce validation runs** (new step)
4. **PR comment appears** (with validation results)
5. **Artifacts uploaded** (recce state file)

## 3. Test Scenarios

### Scenario A: First Run (No Base Artifacts)
- **Expected**: Recce runs without comparison
- **Result**: Should complete successfully with warnings about no base artifacts

### Scenario B: Subsequent Runs (With Base Artifacts)
- **Expected**: Recce compares against base artifacts
- **Result**: Should show validation results comparing current vs base

### Scenario C: Data Quality Issues
- **Test**: Modify a model to introduce a data quality issue
- **Expected**: Recce should detect and report the issue
- **Result**: PR comment should show warnings/failures

### Scenario D: Schema Changes
- **Test**: Add/remove a column from a model
- **Expected**: Schema validation should detect the change
- **Result**: Should show schema diff in validation results

## 4. Validation Checklist

### ✅ Local Testing
- [ ] `recce debug` passes
- [ ] `dbt build` completes successfully
- [ ] `recce run` executes all checks
- [ ] `recce server` launches and shows results

### ✅ GitHub Actions Testing
- [ ] CI workflow triggers on PR
- [ ] dbt build step completes
- [ ] Recce validation step runs
- [ ] PR comment appears with results
- [ ] Artifacts are uploaded
- [ ] CD workflow runs on merge

### ✅ Validation Results
- [ ] Row count checks work
- [ ] Business logic validation runs
- [ ] Schema validation detects changes
- [ ] Data quality checks execute
- [ ] Summary generation works

## 5. Troubleshooting

### Common Issues

**Recce debug fails:**
```bash
# Check warehouse connection
dbt debug --target pr

# Verify profiles.yml configuration
cat profiles.yml
```

**Validation checks fail:**
```bash
# Check recce.yml syntax
recce debug

# Test individual checks
recce server
# Add checks manually in UI, then copy YAML
```

**GitHub Actions fails:**
- Check secrets are set correctly
- Verify repository permissions
- Check workflow file syntax
- Review action logs for specific errors

### Debug Commands
```bash
# Test Recce configuration
recce debug

# Test dbt connection
dbt debug --target pr

# Test specific validation
recce run --check "Row count validation - dim_customers"

# Generate summary
recce summary recce_state.json
```

## 6. Success Criteria

The enhanced pipeline is working correctly when:

1. **Local testing passes** all validation checks
2. **GitHub Actions** runs without errors
3. **PR comments** appear with validation results
4. **Artifacts** are uploaded successfully
5. **Validation results** are meaningful and actionable
6. **State files** can be downloaded and reviewed locally

## 7. Next Steps After Testing

Once testing is complete:

1. **Customize validation checks** in `recce.yml` for your specific needs
2. **Add team-specific checks** for your business logic
3. **Set up monitoring** for validation results
4. **Train team** on reviewing validation results
5. **Document** any custom validation patterns
